package ISP::Conversion;

use warnings;
use strict;

use ISP::User;
use ISP::Sanity;
use ISP::Error;
use ISP::Ledger;
use Storable;

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

sub current_plan_password_to_db {

	# convert current radius pw to the info db

	my $self	= shift;
	my $user_db	= ISP::User->new();
	my $radius	= ISP::RADIUS->new();

	my @client_list = $user_db->get_client_list();

	for my $username ( @client_list ) {

		my $client = ISP::User->new({ username => $username });
		
		my @plan_ids = $client->get_plan_ids();
		my $current_pw	= $client->radius_password();
		
		next if ! $current_pw;

		for my $plan ( @plan_ids ) {
			print "$username: $current_pw, $plan\n";
			$client->plan_password({ plan_id => $plan, new_password => $current_pw });
		}
	}
	
	return 0;
}

sub client_inf_to_db {
   
	use EagleUser;
	use ISP::Error;
	use Data::Dumper;

	my $self		= shift;
	my $user		= ISP::User->new();
	my $inf_user	= EagleUser->new();
	
	my @userlist	= $inf_user->get_inf_user_list();
				
	for (@userlist) {
		
		$inf_user->build_inf_user($_);
		
		
		my %client_info = (
					id				=> '',
					last_update		=> '',
					status			=> '',
				);

		while ( my ($key, $value) = each (%$inf_user)) {
 
			next if ref $value;
			next if $key =~ /Plan/;
			next if $key =~ /version/i;
			next if $key =~ /operating_system/i;
			next if $key =~ /^first_name$/i;
			next if $key =~ /^last_name$/i;
			next if $key =~ /^salutation$/;
			next if $key =~ /login_name/;

			$key =~ s/s_/shipping_/;
			$key =~ s/b_/billing_/;

			$client_info{$key} = $value;
		}

		delete $client_info{ b_salutation };
		delete $client_info{ s_salutation };
		delete $client_info{ billing_salutation };
		delete $client_info{ shipping_salutation };

		my $error = ISP::Error->new();

		$user->add_client({ error => $error, client_info => \%client_info });

		print Dumper $error if $error->exists();

		undef %client_info;
	}

	print scalar (@userlist) . "\n";
	return 0;
}

sub plans_inf_to_db {		 

	use EagleUser;
	
	my $self			= shift;  
	my $client_db		= ISP::User->new();
	my $error			= ISP::Error->new();

	my @userlist		= $client_db->get_client_list();

	for my $username (@userlist) {				  

		my $user		= ISP::User->new({ username => $username });
   
		my $inf_data	= EagleUser->new();		
		$inf_data->build_inf_user($username);
	
		my %plan_info	= ();

		for my $plan_num (1..5) {
	
			next if ! exists $inf_data->{"Plan${plan_num}name"};
			next if $inf_data->{ "Plan${plan_num}status" } eq 'delete';

			my $login_name = ( $inf_data->{ login_name } )
				? $inf_data->{ login_name }
				: $inf_data->{ "Plan${plan_num}username" };

			%plan_info = ();

			my $expiry_date;

			my $legacy_expiry = $inf_data->{ "Plan${plan_num}expire_date" };

			#print "$legacy_expiry :: $username\n";

			if ( $legacy_expiry ne '' && $legacy_expiry !~ /none/i ) {
				$expiry_date = $self->string_to_date( $legacy_expiry );
			}
			else {
				$expiry_date = '0000-00-00';
			}

			my $legacy_pap_date = $inf_data->{ "Plan${plan_num}pap_date" };

			my $pap_date;

			if ( $legacy_pap_date ne '' ) {
				$pap_date = $legacy_pap_date;
			}
			else {
				$pap_date = '';
			}

			# Get the plana hours remaining

			if ( $inf_data->{"Plan${plan_num}name"} =~ /plana/i ){
		
				last if $inf_data->{"Plan${plan_num}status"} !~ /active/i;

				my $prefix = $user->prefix();

				my $hours_remaining;

				# create a sub here to make critic happy. I don't know
				# if I really like this idea

				my $work_on_plana_file = sub {
				
						my $entry = shift;	
						$hours_remaining = ( split( /&/, $entry ))[1];
						$hours_remaining = ( ($hours_remaining / 60) /60 );
						$plan_info{hours_balance} = sprintf( '%.2f', $hours_remaining );
					};

				open my $plana_file, '<', "/usr/adm/accounting/$prefix/$username.plana"
					or warn "Can't open the plana file for $username: $!";

				while (<$plana_file>) {
					$work_on_plana_file->( $_ );
					last;
				}
				close $plana_file;

			}
			else {
				$plan_info{hours_balance} = 0;
			}

			my $plan_name = $inf_data->{"Plan${plan_num}name"};
			if ( $plan_name =~ m{ \A plan[abcd] \z }xmsi ) {
				$plan_info{classification} = 'dialup';
			}
			elsif ( $plan_name =~ m{ dsl }xmsi ) {
				$plan_info{classification} = 'highspeed';
			}
			elsif ( $plan_name =~ m{ (slipstream|blast) }xmsi ) {
				$plan_info{classification} = 'slipstream';
			} 
			elsif ( $plan_name =~ m{ hotspot }xmsi ) {
				$plan_info{classification} = 'hotspot';
			}
			else {
				$plan_info{classification} = 'unknown';
			}

			$plan_info{id}					= '';
			$plan_info{plan_status}			= $inf_data->{"Plan${plan_num}status"};
			$plan_info{next_billing_date}	= '';
			$plan_info{username}			= $username; 
			$plan_info{login_name}			= $login_name;
			$plan_info{password}			= $inf_data->{"Plan${plan_num}password"};
			$plan_info{server}				= '';
			$plan_info{email}				= $inf_data->{"Plan${plan_num}email"};
			$plan_info{dob}					= $inf_data->{"Plan${plan_num}dob"};
			$plan_info{last_update}			= '';
			$plan_info{plan}				= $inf_data->{"Plan${plan_num}name"};
			$plan_info{description}			= $inf_data->{"Plan${plan_num}description"};
			$plan_info{rate}				= $inf_data->{"Plan${plan_num}rate"};
			$plan_info{hours}				= $inf_data->{"Plan${plan_num}hours"};
			$plan_info{over_rate}			= $inf_data->{"Plan${plan_num}over_rate"};
			$plan_info{billing_period}		= '';
			$plan_info{expires}				= $expiry_date;
			$plan_info{started}				= $inf_data->{"Plan${plan_num}start_date"};
			$plan_info{pap_date}			= $pap_date;
			$plan_info{pap_method}			= $inf_data->{"Plan${plan_num}pap_method"};
			$plan_info{billing_method}		= $inf_data->{"Plan${plan_num}billing_method"};
			$plan_info{os}					= '';
			$plan_info{dsl_number}			= '';
			$plan_info{comment}				= $inf_data->{"Plan${plan_num}comment"};

			my $legacy_start = $inf_data->{"Plan${plan_num}start_date"};
			my $start_date;

			if ( $legacy_start ne '' ) {		
				$start_date = $self->string_to_date( $legacy_start );
			}
			else {
				$start_date = '0000-00-00';
			}

			$user->add_plan({ plan_info => \%plan_info, error => $error, start_date => $start_date });
		
			my $failure = $error->exists();

			if ($failure) {
				$error->dump_messages();
			}
		}

	}

	return 0;
}

sub gledger_inf_to_db {

	use DBIx::Recordset;

	my $self		= shift;

	my $start_year	= shift;
	my $end_year	= 2010;

	# used to contain, store the resetting of invoice
	# numbers

	my %inv_num_map;
	my $new_inv_num = 1;

	for my $year ($start_year..$end_year) {

		my $dir = "/usr/adm/accounting/${year}";

		opendir ( DIR, $dir ) || die "Can't open directory $dir: $!";

		chdir ($dir);
		

		while ( my $file = readdir( DIR )) {

			next if $file !~ /gledger/;

			my @key_names = qw (
						payment_method
						date
						invoice_number
						username
						quantity
						item_name
						comment
						amount
						payment
					   );

			my $work_on_ledger_file = sub {

				my $entry = shift;
				chomp $entry;

				my $i = 0;
		
				my %ledger_info = map { $key_names[$i++] => $_ } split (/&/, $entry);
				$ledger_info{id} = '';
			
				# map and reset the inv_num

				if ( exists $inv_num_map{ $ledger_info{ invoice_number } } ){
					$ledger_info{ invoice_number } = $new_inv_num;
				}
				else {
					$inv_num_map{ $ledger_info{ invoice_number } } = $new_inv_num;
					$ledger_info{ invoice_number } = $new_inv_num;
					$new_inv_num++;
				}

				$ledger_info{total_price} = $ledger_info{ payment };
				if ( defined $ledger_info{ payment } ) {

					$ledger_info{ payment } = '0.00'
					  if $ledger_info{ payment_method } eq 'Accounts Receiveable';
				}

				if ( $ledger_info{ item_name } eq 'Accounts Receiveable' ) {
					$ledger_info{ amount } = '0.00';
					$ledger_info{ payment } =~ s/-//;
					$ledger_info{ total_price } =~ s/-//;
				}

				$ledger_info{date} = $self->string_to_date($ledger_info{date});

				my %dsn = $self->dsn({ table => 'gledger' });

				DBIx::Recordset->Insert({%dsn, %ledger_info});
				
			};
			
			open (my $ledger_file, "<", $file) || die "Can't open the file: $!";
			
			while ( <$ledger_file> ) {
				$work_on_ledger_file->( $_ );
			}
			
			close $ledger_file;
		}
	}

	store \%inv_num_map, '/tmp/inv_num_map';

	return 0;
}

sub uledger_inf_to_db {

	use DBIx::Recordset;

	my $self		= shift;
	my $start_year	= shift;
	my $end_year	= 2010;

	my $file_count	= 0;
	my $entry_count = 0;

	# we need to retrieve the file that contains the old-to-new
	# invoice number mappings

	my $inv_num_map = retrieve( '/tmp/inv_num_map' );

	for my $prefix ('a'..'z') {

		for my $year ($start_year..$end_year) {

			my @months = qw ( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

			for my $month (@months) {

				my $dir = "/usr/adm/accounting/${prefix}/${year}/${month}";

				opendir ( DIR, $dir ) || warn "Can't open directory $dir: $!";
				chdir ($dir);

				while ( my $file = readdir( DIR )) {

					next if $file !~ /\.db/;

					my $username = (split (/\./, $file))[0];

					open (my $uledger_file, "<", $file) || warn "Can't open the file: $!";

					my @key_names = qw (
									date
									invoice_number
									comments
									amount
									payment
									balance
									);
								
					while ( my $entry = <$uledger_file> ) {

						chomp $entry;
										
						my %ledger_info;
						$ledger_info{id}	 = '';
						$ledger_info{date}	   = (split (/&/, $entry))[0];
						$ledger_info{username}	   = $username;
	
						# we need to do some trickery to convert to the
						# new style of inv_nums

						$ledger_info{comment}	  = (split (/&/, $entry))[2];
						
						my $old_inv_num	 		= (split (/&/, $entry))[1];
						my $new_inv_num			= $inv_num_map->{ $old_inv_num };
						$ledger_info{ invoice_number } = $new_inv_num;	

						$ledger_info{amount}	= (split (/&/, $entry))[3];
						$ledger_info{payment}	 = (split (/&/, $entry))[4];
						$ledger_info{payment} 	= 0 if ! $ledger_info{payment};
						$ledger_info{balance}	  = (split (/&/, $entry))[5];

						
						$ledger_info{date} = $self->string_to_date($ledger_info{date});
						
						if (! defined $ledger_info{amount} && ! defined $ledger_info{payment}) {
							next;
						}
						if (! defined $ledger_info{payment}) {
							$ledger_info{payment} = '0.00';
					    }
					
						$entry_count++;

						my $ledger = ISP::Ledger->new();

						if ( ! defined $ledger->balance({ username => $username }) ){

 							# create a new record in the balance table
							
					 		$ledger_info{ balance } = sprintf( '%.2f', $ledger_info{ balance } );

							my %balance_info = (
								id		 => '',
								username => $username,
								balance	 => $ledger_info{ balance },
							);
						
							my %bal_dsn = $self->dsn({ table => 'balance' });
	
							DBIx::Recordset->Insert({%bal_dsn, %balance_info});
						}
						else {

							$ledger->balance({ username => $username, balance => $ledger_info{ balance } });
						}

						# don't want to write a ledger entry for the balance
						# forward entries!

						next if $ledger_info{ comment } eq 'Balance Forward';
						my %ledger_dsn = $self->dsn({ table => 'uledger' });

						DBIx::Recordset->Insert({%ledger_dsn, %ledger_info});


						my $date_frag = ( split( /\s+/, $ledger_info{ date } ))[0]; 
						$ledger->invoice_number( $ledger_info{ invoice_number }, $date_frag );
					 }
				}
			}
		}
	}
	
	return 0;
}

1;	

=head1 NAME

ISP::Conversion - ISP specific conversion module.

=head1 VERSION

=cut

our $VERSION = sprintf ("%d", q$Revision: 165 $ =~ /(\d+)/);

=head1 SYNOPSIS

	use ISP::Vars;
	my $vardb = ISP::Vars->new();

	# Retrieve the different payment methods avaiable
	my %payment_options = $vardb->payment_methods();

=head1 DESCRIPTION

NOTE: You don't need this module, it was specific to my particular
environment. It will be removed.

This module provides the resources to migrate information from the old
.inf style information base to a MySQL database system.

=head1 METHODS

=head2 client_inf_to_db

Converts .inf style information base records into MySQL style, and 'INSERT's them.

This ONLY applies to the info section of the user's .inf db.

Takes no parameters, there is no return.

=head2 plans_inf_to_db

Converts .inf style information base records into MySQL style, and 'INSERT's them.

This ONLY applies to the plans section of the user's .inf db.

Takes no parameters, there is no return.

=head2 gledger_inf_to_db(YEAR)

Converts .inf-style General Ledger into MySQL style, and 'INSERT's them.

This ONLY applies to the General Ledger, and not the User Ledger.

YEAR is a mandatory parameter. It is the year you want to begin the translation process.
It must be specified in YYYY integer format. There is no return.

=head2 uledger_inf_to_db(YEAR)

Converts .inf-style User Ledger into MySQL style, and 'INSERT's them.

This ONLY applies to the User Ledger, and not the General Ledger.

YEAR is a mandatory parameter. It is the year you want to begin the translation process.
It must be specified in YYYY integer format. There is no return.

=head2 convert_account_balance

Aggregates the total payments and amounts in each user's User Ledger, and 
compiles an account balance for each one.

The aggregate account balance is INSERTed into the MySQL database, into a
'balance' table.

Takes no parameters, there is no return.


=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steve at ibctech.ca> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc ISP::Conversion

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
