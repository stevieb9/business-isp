package ISP::Reports;

use warnings;
use strict;

use ISP::User;
use ISP::Sanity;
use ISP::Error;
use ISP::Ledger;
use ISP::Email;

use vars qw(@ISA);
use base qw(ISP::Object);

BEGIN {
# config accessors
    my @config_vars = qw (
                            );
	for my $member (@config_vars) {
        no strict 'refs';
        *{$member} = sub {                              
            my $self = shift;                       
			return $self->{config}{$member};        
        }                                               
    }                                                       
} # end BEGIN  

sub income_by_payment_type {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	# which ledger to use

	my $type	= ( $params->{ type } )
		? $params->{ type }
		: 'gledger';

	# which distribution account to search

	my $account	= ( $params->{ account } )
		? $params->{ account }
		: '';

	# we need to use a custom DateTime obj, so we can pass it in with
	# the subtracted day, if the date wasn't passed in
	
	my $datetime = DateTime->now( time_zone => $self->TIMEZONE() )->subtract( days => 1);

	my $date	= ( $params->{ date } )
		? $params->{ date } 
		: $self->date({ get => 'day', datetime => $datetime });

	my $ledger = ISP::Ledger->new();

	my $doc_nums = $ledger->invoice_number( undef, $date ); # aref

	my %payment_type;

	for my $doc_num ( @$doc_nums ) {

		my $subcall = 'get_' . $type;
		my $ledger_entry = $ledger->$subcall({ invoice_number => $doc_num });
		
		for my $line_item ( @$ledger_entry ) {

			if ( $account && $line_item->{ payment_method } ne $account ) {
				next;
			}

			my @ledger_fields = qw( username
									invoice_number
									item_name
									comment
									total_price
									payment_method
								);

			my $entry_info = $ledger->ledger_field({ 
													entry => $line_item, 
													fields => \@ledger_fields,
											});

			my $client = ISP::User->new({ username => $entry_info->{ username } });
			$entry_info->{ fullname } = $client->fullname();

			my $payment_method 		= $entry_info->{ payment_method };

			push ( @{ $payment_type{ $payment_method }{ entries } }, $entry_info );
			$payment_type{ $payment_method }{ payment_method } = $payment_method;
		}

	}

	my @outer_array;

	for my $key ( keys %payment_type ) {
		push @outer_array, $payment_type{ $key };
	}

	# tally up totals

	for my $acct ( @outer_array ) {

		my $account_total;

		for my $entry ( @{ $acct->{ entries } } ) {
			$account_total += $entry->{ total_price };
		}

		$account_total = sprintf( '%.2f', $account_total );
		$acct->{ account_total } = $account_total;
	}
	return \@outer_array;
}	
sub income_by_item {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $single_item = $params->{ item };

	my $ledger	= ISP::Ledger->new();

	# we need to use a custom DateTime obj, so we can pass it in with
	# the subtracted day, if the date wasn't passed in
	
	my $datetime = DateTime->now( time_zone => $self->TIMEZONE() )->subtract( days => 1);

	my $date	= ( $params->{ date } )
		? $params->{ date } 
		: $self->date({ get => 'day', datetime => $datetime });

	my $income_data = $ledger->sum({
								date	=> $date,
								for		=> 'item_name',
								total	=> 'payment',
							});

	my @template_item_loop;

	for my $item ( keys %$income_data ) {

		my %income_items;
		$income_items{ name }	= $item;
		$income_items{ amount }	= $income_data->{ $item };

		$income_items{ amount } = sprintf( '%.2f', $income_items{ amount } );

		if ( $single_item && $item !~ /$single_item/i ) {
			next;
		}
		push @template_item_loop, \%income_items;
	}

	return \@template_item_loop;
}
sub unused_service {

	use DateTime::Format::Strptime;

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $error = $params->{ error };
	my $count = $params->{ count };

	my $report_hours = ( $params->{ hours } )
		? $params->{ hours }
		: 0;

	my $schema	= $self->schema();
	my $plan_rs;

	if ( ! $report_hours ) {
		$plan_rs	= $schema->resultset( 'Plans' )->search({
													expires => { '!=' => '0000-00-00' },
												});
	}
	else {
		$plan_rs	= $schema->resultset( 'Plans' )->search({
													hours => { '>' => 0 },
												});
	}

	my @loop_data;
	my %totals;

	my $manual_terminate = 1 if $count;

	while ( my $plan = $plan_rs->next ) {

		if ( $manual_terminate ) {
		    last if $count == 0;
			$count--;
	 	}		
		my %data; # the actual plan data

		my $client = ISP::User->new({ username => $plan->username });

		my $service_remaining;

		if ( ! $report_hours ) {

			# we've been called to perform a months remaining
			# report

			next if $plan->plan =~ /plana/i;

			$data{ expires } = $plan->expires;

			# we'll do the date comparison first, as there is
			# no sense doing all sorts of work if the user
			# doesn't have any months left

			my $date_format
				= new DateTime::Format::Strptime( pattern => '%Y-%m-%d', );

			my $current_datetime
			  	= $date_format->parse_datetime( $self->date({ get => 'day' }) );

			my $expiry_datetime
				= $date_format->parse_datetime( $plan->expires );

			my $remaining_datetime
				= $expiry_datetime->subtract_datetime( $current_datetime );

			my $months_remaining = $remaining_datetime->months();

			next if abs( $months_remaining ) != $months_remaining;
			next if ! $months_remaining;

			$service_remaining = $months_remaining;

			$totals{ users }++;
			$totals{ months } += $months_remaining;
			
			$totals{ outstanding } += ( $plan->rate * $months_remaining );
		}
		else {

			# we're doing plana hours report

			next if $plan->plan !~ /plana/i;

			$data{ hours } = $plan->hours;

			my $hours_remaining 
				= $client->plan_hours({
									id			=> $plan->id,
									quantity	=> 0,
									error		=> $error,
								});

			if ( $error->exists() ){
				$error->add_trace();
				$error->add_message( "ISP::User::plan_hours() triggered an error" );
				return $error;
			}

			next if abs( $hours_remaining ) == $hours_remaining;

			$service_remaining = abs( $hours_remaining );

			$totals{ users }++;
			$totals{ hours } += $service_remaining;
			
			$totals{ outstanding } += ( $plan->rate * $service_remaining );
		}

		$data{ username } = $plan->username;
		
		$data{ fullname } = $client->fullname();

		# hours for plana
		# expires for non-plana

		$data{ email } 		= $plan->email;
		$data{ rate }		= $plan->rate;
		$data{ unused }		= $service_remaining;
		$data{ outstanding }	= sprintf( '%.2f', ( $data{ rate } * $service_remaining ));

		push @loop_data, \%data;

	}

    $totals{ outstanding } = sprintf( '%.2f', $totals{ outstanding } );

	my @outer_loop;

	push @outer_loop, [ \%totals ];
	push @outer_loop, \@loop_data;
	return \@outer_loop;
}
sub renewal_notices {

	# this is an email Report, not a typical HTML
	# one

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $data	= $params->{ data };

	my $template_dir = $self->TEMPLATE_DIR();
	my $template	 = $template_dir . "/renewal_notice_report.tpl";

	my $email	= ISP::Email->new();

	$email->email({
				tmpl	=> $template,
				data	=> $data,
				subject	=> "Clients sent renewals/notices",
			});
}


sub _nothing{} # vim placeholder

1;
__END__

=head1 NAME

ISP::Reports - Reporting system for the ISP:: system.

=head1 VERSION

=cut

=head1 SYNOPSIS

	# instantiate a new Report object

	my $report = ISP::Reports->new();

=head1 DESCRIPTION

This module contains the structure and function for most all reporting
that happens within the ISP:: System.

=head1 METHODS

=head2 income_by_payment_type({ type => TYPE, date => DATE })

Retrieves the data used for displaying financial reports aggregated by
payment type.

TYPE is an optional parameter, where the valid values are uledger (for
user ledger), and gledger (for general ledger). If not supplied, defaults
to gledger.

DATE is an optional parameter, the day you want the data for, in the form
YYYY-MM-DD. If not specified, yesterday's date will be used by default.

The parameters must be passed in within a hash reference if supplied.

Returns an array ref of hash references, each hash reference containing
a single text field (payment_method) along with an array reference (entries),
which contains a hash reference. Perfectly suitable for a nested
TMPL_LOOP in the templating system.



=head2 income_by_item({ date => DATE, item => ITEM })

Sorts total revenue based on items.

DATE is an optional string scalar parameter in the form YYYY, YYYY-MM or
YYYY-MM-DD. This is the timeframe that the aggregated totals will be for.
If not passed in, yesterday's date will be used.

ITEM is an optional string scalar parameter. If supplied, only the total
for this item will be included in the report data.

Returns an array reference that contains hash references, ideal for passing
along into a template TMPL_LOOP.



=head2 unused_services({ hours => BOOL, error => ERROR, count => INT })

Reports on how many months or hours that the clients have purchased, but
have not yet used.

If wanting a report on the clients who purchase blocks of hours, both
the 'hours' and 'error' parameters are mandatory, passed in within a hash
reference. BOOL must be set to a true value, and ERROR is an ISP::Error
object.

Otherwise, if reporting on the number of months outstanding to
monthly clients, no parameters are necessary.

The 'count' parameter is mainly for testing. INT is an integer that
represents the number of lines you want in the report.

In both cases, the return is an array reference, which contains two
array references, each of those contain a single hash reference. This
allows for easy integration into the templating system.



=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steveb at cpan.org> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISP::Reports

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
