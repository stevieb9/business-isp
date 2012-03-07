package ISP::Billing;

use warnings;
use strict;

use ISP::User;
use ISP::Sanity;
use ISP::Error;
use ISP::Ledger;
use ISP::Email;
use ISP::Reports;

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

sub new {

    my $class       = shift;
    my $params      = shift;

    my $self = {};
    bless $self, $class;

    $self->configure();
    $self->function_orders();

    return $self;
}

sub email_bill {

    my $self    = shift;
    my $params  = shift;

    my $inv_num = $params->{ invoice };

    my $ledger  = ISP::Ledger->new();
    my $invoice = $ledger->get_gledger({ invoice_number => $inv_num });

    my $invoice_data;   # href
    my $loop_data;      # aref

    my $date            = $invoice->[0]->{ date };
    my $payment_method  = $invoice->[0]->{ payment_method };
    my $username        = $invoice->[0]->{ username };
    my $payment;

    my $user        = ISP::User->new({ username => $username });

    my $billto_addr = ( $user->billing_email_address() ne '' )
        ? $user->billing_email_address()
        : ( $username .= '@example.com' );

    my ( $tax, $sub_total, $grand_total, $is_poa );

    for my $line_item ( @$invoice ) {
        
        # grab out the GST/Tax line item

        if ( $line_item->{ item_name } eq 'GST' or $line_item->{ item_name } eq 'Tax' ) {
            $tax    += $line_item->{ total_price };
            next;
        }
        
        if ( $line_item->{ item_name } eq 'ROA' && ! $is_poa ) {
            $is_poa = 1;
            $invoice_data->{ is_poa } = $is_poa;
            $line_item->{ is_poa } = $is_poa;
        }

        # delete the hash items we don't need anymore
        
        foreach ( qw( date id username payment_method invoice_number ) ) {
            delete $line_item->{ $_ };
        }

        $payment   += $line_item->{ payment };
        $sub_total += $line_item->{ total_price };

        push @$loop_data, $line_item;
    }

    $sub_total      = ( sprintf ( '%.2f', $sub_total ) );
    $tax = 0 if ! $tax;
    $tax            = ( sprintf ( '%.2f', $tax ) );
    $grand_total    = ( sprintf ( '%.2f', ( $sub_total + $tax )) );

    # FIXME: dirty check for payment

    if ( $grand_total eq '0.00' ) {
        $grand_total = ( sprintf( '%.2f', $payment ) );
    }

    my $transac_type;
    
    if ( $payment_method eq 'invoice' ) {
        $transac_type = 'Invoice';
    }
    else {
        $transac_type = 'Receipt';
    }

    $invoice_data->{ invoice_number }   = $inv_num;
    $invoice_data->{ username }         = $username;
    $invoice_data->{ type }             = $transac_type;
    $invoice_data->{ items }            = $loop_data;
    $invoice_data->{ tax }              = $tax;
    $invoice_data->{ date }             = $date;
    $invoice_data->{ payment_method }   = $payment_method;
    $invoice_data->{ sub_total }        = $sub_total;
    $invoice_data->{ grand_total }      = $grand_total;

    my $mailer  = ISP::Email->new();
    my $tmpl    = $self->TEMPLATE_DIR() . "/email_bill.tpl";

    $mailer->email({
                to          => $billto_addr,
                subject     => "$transac_type #$inv_num",
                tmpl        => $tmpl,
                data        => $invoice_data,
            }); 

}
sub renewal_notice {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $account_type    = $params->{ account_type };

    # die off if a type is not passed in

    if ( ! $account_type ) {
        my $error = ISP::Error->new();
        $error->add_trace();
        $error->bad_api( "account_type parameter is missing or incorrect. Values are 'month' or 'hour' ");
    }

    my $user_object = ISP::User->new();

    my @renewals;
    my @notices;

    # do the hourly clients

    if ( $account_type eq 'hour' ) {

        my $plan_ids
          = $user_object->plan_members({ 
                                    plan_name   => 'plana',
                                    status      => 'active',
                                    return_id   => 1,
                                });


        for my $plan_id ( @$plan_ids ) {

            my $plan        = $user_object->get_plan( $plan_id );
            my $username    = $plan->{ username };
            my $client      = ISP::User->new({ username => $username });

            my $error   = ISP::Error->new();

            my $hours_balance = $client->plan_hours({
                                                id          => $plan_id,
                                                quantity    => 0,
                                                error       => $error,
                                            });

            $error->dump_all() if $error->exists;
            
            next if $hours_balance < -15;

            if ( ( $hours_balance <= -10 ) && ( $hours_balance >= -15 ) ) {
                    
                    # NOTICE
                    
                    $hours_balance = abs( $hours_balance ) . " hours remaining";
            
                    push @notices, { username => $username, hours => $hours_balance, };
            }
            else {
                    
                    # RENEWAL

                    if ( abs( $hours_balance ) != $hours_balance ) {
                        $hours_balance = abs( $hours_balance ) . " hours remaining";
                    }
                    else {
                        $hours_balance = "$hours_balance hours over";
                    }
            
                    push @renewals, { username => $username, hours => $hours_balance, };
            }   
        }
    }
    elsif ( $account_type eq 'month' ) {

        # monthly plans

        my $cur_dt          = $self->date();
        my $next_month_dt   = $cur_dt->clone()->add( months => 1 );

        my $cur_month       = $self->date({ get => 'month', datetime => $cur_dt });
        my $next_month      = $self->date({ get => 'month', datetime => $next_month_dt });

        my $schema = $self->schema();

        my $expiry_info_rs
                = $schema->resultset( 'Plans' )->search(
                                            { expires => { -like => "$next_month%" }},
                                    );

        while ( my $m = $expiry_info_rs->next() ) {
            my $un = $m->username();
            my $ex = $m->expires();

            print "$un :: $ex\n";
        }
    
    }


    # prep the report data

    my %sent;
    $sent{ notices }    = \@notices;
    $sent{ renewals }   = \@renewals;

    my $report = ISP::Reports->new();
    $report->renewal_notices({
                            data    => \%sent,
                        });

    use Data::Dumper;
    print Dumper \%sent;
}



sub _nothing{} # vim fold placeholder
1;

__END__

=head1 NAME

ISP::Billing - Billing system for the ISP:: system.

=head1 VERSION

=cut

=head1 SYNOPSIS

    use ISP::Billing;

    # create a billing object

    my $billing = ISP::Billing->new();

    # email an invoice/receipt

    $billing->email_bill({ invoice => 3 })


=head1 DESCRIPTION

This is module performs all client billing functions.

=head1 METHODS


=head2 new

Instantiates a new ISP::Billing object



=head2 email_bill({ invoice_number => INV_NUM })

Emails an invoice to a client. INV_NUM is mandatory, and is an integer.





=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steveb at cpan.org> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISP::Billing

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
