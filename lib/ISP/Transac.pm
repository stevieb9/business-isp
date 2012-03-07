package ISP::Transac;

use warnings;
use strict;

use vars qw( @ISA );
use base qw( ISP::Object );

BEGIN {
# config accessors
	my @config_vars = qw (
                        );
    for my $member ( @config_vars ) {
        no strict 'refs';
        *{ $member } = sub {                              
            my $self = shift;
            return $self->{ config }{ $member };        
        }                                               
    }                                                       
} # end BEGIN  

sub create_transaction {

    use ISP::Sanity;

    my $class	= shift;
	my $params	= shift;

	my $data	= $params->{ data };
    my $error	= $params->{ error };

    unless ( defined $error ) {
        $error = ISP::Error->new();
        $error->bad_api();
    }

	my $self = {};
   	bless $self, $class;
   	$self->configure();

    $self->function_orders();

    my $sanity = ISP::Sanity->new;

    $sanity->validate_data({ 
				type	=> 'transaction_data', 
				data	=> $data, 
				error	=> $error,
			});

    my $failure = $error->exists();

    if ( $failure ) {
        $error->add_trace();
	    return( $error );
    }

	push @{ $self->{ line_items } }, $data;

    return $self;
}
sub add_transaction_line {

    use ISP::Sanity;
    
    my $self	= shift;
	my $params	= shift;

    $self->function_orders();

	my $data	= $params->{ data };
    my $error	= $params->{ error };

    unless (defined $error) {
        $error = ISP::Error->new();
        $error->bad_api();
    }

    my $sanity = ISP::Sanity->new;
    $sanity->validate_data({
					type	=> 'transaction_data', 
					data	=> $data, 
					error	=> $error
				});

    my $failure = $error->exists;

    if ($failure) {
        $error->add_trace;
        return $error;
    }

	push @{ $self->{ line_items } }, $data;

	return 0;
}
sub purchase {

    use ISP::Sanity;
    use ISP::Ledger;

    my $sanity = ISP::Sanity->new();
    my $ledger = ISP::Ledger->new();

    my $self     = shift;
	my $params	 = shift;

    $self->function_orders();

	my $client			= $params->{ client };
	my $bank_receipt	= $params->{ bank_receipt };
	my $error			= $params->{ error };

    # check for mandatory $error param

    unless (defined $error) {
        $error = ISP::Error->new();
        $error->bad_api();
    }

    # last resort kill if the $error param exists, but the operator hasn't
    # done anything with it yet.
    
    my $failure = $error->exists;

    if ($failure) {
        die     "There were errors, but you neglected to check them." .
                "Please review 'perldoc ISP::Transac' for proper usage: $!";
    }


	return $error if $error->exists();

	my $transac_invoice_number
		= $ledger->write_ledger({
					transaction 	=> $self->{ line_items },
					client			=> $client,
				});
	
	if ( $bank_receipt ) {
		$ledger->bank_receipt({
						invoice_number	=> $transac_invoice_number,
						bank_receipt	=> $bank_receipt,
					});
	}

	return $transac_invoice_number;

} # end sub purchase


sub payment {

    use ISP::Sanity;
    use ISP::Ledger;

    my $sanity = ISP::Sanity->new;
    my $ledger = ISP::Ledger->new;

    my $self		= shift;
    my $params		= shift;

    $self->function_orders();

	my $client			= $params->{ client };
	my $bank_receipt	= $params->{ bank_receipt };
	my $error			= $params->{ error };

    # check for mandatory $error param

    unless (defined $error) {
        $error = ISP::Error->new();
        $error->bad_api();
    }

    # last resort kill if the $error param exists, but the operator hasn't
    # done anything with it yet.
        
    my $failure = $error->exists();
        
    if ($failure) {
        die     "There were errors, but you have not used the API properly." .
                "Please review 'perldoc ISP::Transac' for proper usage: $!";
    }

	# do sanity checking on the payment
	$sanity->validate_payment({
		   		transaction	=> $self->{ line_items },
				error		=> $error 
			});

	return $error if $error->exists();

	my $transac_invoice_number
		= $ledger->write_ledger({
					transaction 	=> $self->{ line_items },
					client			=> $client,
				});
	
	# save the bank receipt

	if ( $bank_receipt ) {	
		
		$ledger->bank_receipt({
						invoice_number	=> $transac_invoice_number,
						bank_receipt	=> $bank_receipt,
					});
	}

	return $transac_invoice_number;

} # end sub payment


sub renew {

	use ISP::Ledger;
	use ISP::User;
	use ISP::Sanity;

	my $self		= shift;
	my $params		= shift;

	$self->function_orders();

	my $client			= $params->{ client };
	my $bank_receipt	= $params->{ bank_receipt };
	my $error			= $params->{ error };

	# check for mandatory $error param
	unless (defined $error) {
		$error = ISP::Error->new;
		$error->bad_api();
	}
	
	#my $failure	= $error->exists();
	#if ($failure) {
#		die	"There were errors, but you have not used the API properly." .
#			"Please review 'perldoc ISP::Transac for proper usage: $!";
#	}

	my $ledger = ISP::Ledger->new();

	my $transac_invoice_number
		= $ledger->write_ledger({
					client			=> $client,
					transaction	=> $self->{ line_items },
				});

	if ( $bank_receipt ) {
	
		$ledger->bank_receipt({
					invoice_number		=> $transac_invoice_number,
					bank_receipt		=> $bank_receipt,
				});
	}

	if ($error->exists()) {
        $error->add_trace;
        return;
    }

	return $transac_invoice_number;
}
sub credit_card_payment {

	use Exact::Transaction;

	my $self 	= shift;
	my $params	= shift;

	$self->function_orders();

	my $transaction_data_ref 	= $params->{ transaction_data };
	my $error					= $params->{ error };

	my $bank_info_ref			= $self->bank_info();

	my $bank_connection	= Exact::Transaction->new( %$bank_info_ref );

	$bank_connection->TransactionReset();
	$bank_connection->SetPurchaseType();
	$bank_connection->SendToServer( %$transaction_data_ref );

	my ( $response_code, $response_message ) 
		= $bank_connection->get( 'Exact_Resp_Code', 'Exact_Message' );
	
	while ( $bank_connection->{ InSending } ) {}
	$bank_connection->CommitTransaction();

	my $bank_connection_result = $bank_connection->CTR();

	if ( $bank_connection->get( 'Transaction_Approved' )) {
		return ( $response_code, $response_message, $bank_connection_result );
	}
	else {
		return ( $response_code, $response_message );
	}
}
sub calculate_invoice_amount {

	my $self 	= shift;
	my $params	= shift;

	$self->function_orders();

	my $username		= $params->{ username };
	my $transac_data	= $params->{ data }; # href

	my $user = ISP::User->new({ username => $username });
	my $tax_exempt	= $user->tax_exempt();

	my $total_amount;

	while ( my ( $qty, $amt ) = each ( %$transac_data )) {
		$total_amount += ( $qty * $amt );
	}

	if ( $tax_exempt !~ /y/i ) {
		my $tax_rate	= $self->tax_rate( 'hst' );
		my $tax			= ( $total_amount * $tax_rate );
		$total_amount  += $tax;
	}

	return sprintf( '%.2f', $total_amount );

}
sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}


=head1 NAME

ISP::Transac - Perl module for ISP accounting system.

=cut
our $VERSION = sprintf "%d", q$Revision: 188 $ =~ /(\d+)/;


=head1 SYNOPSIS

    use ISP::Transac;

    # Create a new transaction, and populate it with some initial data
    my $transaction = ISP::Transac->create_transaction({
												data	=> \%data, 
												error	=> $error
											});

    # Add more items to the transaction
    $transaction->add_transaction_line({ data => \%data, error => $error });

    # Purchase something
    $transation->purchase($user, $error);

    # Make a payment
    $transaction->payment($user, $error);

=head1 DESCRIPTION

This module provides the financial functions (purchase, renewal, payment) etc
for the ISP accounting system applications. This is the intermediary layer
between the applications and the ledgers.

This is the ONLY module that should ever have direct access to the write functions
in ISP::Ledger.

=head1 METHODS

=head2 new()

Creates a new ISP::Transac object, and if possible, will set $self->{config} to
$config->{transac}. This method is inherited from the base class. More often than not,
you will want to use create_transaction() to initialize an ISP::Transac object.

Initializes a new empty transaction object. This method is inhereted from the base
class. More often than not, you will want to use create_transaction() instead
of new().

Returns undef if an object can not be created.



=head2 create_transaction({ data => TRANSAC_INFO, error => ERROR })

Creates a new ISP::Transac object.

Parameters are passed in as a hash reference.

The data parameter MUST contain a hash reference with the following keys: quantity,
payment_method, item_name, comment, amount, payment, gst and pst. The error
parameter is an ISP::Error object. ERROR MUST be present.

Uses ISP::Sanity to validate the data, and updates ERROR accordingly.

Returns ERROR if an error has been flagged, else returns itself as a hash
reference.




=head2 add_transaction_line({ data => TRANSAC_INFO, error => ERROR })

Appends a new item into the transaction for transactions requiring more
than a single line item.

Parameters must be passed in as a hash reference.

TRANSAC_INFO format is consistent with that in create_transaction().

ERROR is an ISP::Error object. ERROR MUST be supplied.

Returns 0 upon success and the ERROR upon failure.




=head2 purchase({ NAME => VALUE })

Sends the Transac object to ISP::Ledger for processing. Will die if errors
are present, and the caller has not done error trapping/processing.

Valid parameters are as follows:

	client		=> $client 		# ISP::User object
	cc_receipt	=> $cc_receipt	# bank receipt string
	error		=> $error		# ISP::Error object

Both error and client are mandatory. Returns the invoice number of the
transaction upon success.



=head2 payment({ NAME => VALUE, NAME => VALUE })

Same as purchase(), but performs special math for legacy ledger operations.




=head2 renew({ NAME => VALUE }) 

#FIXME: I don't think this sub is ever used!

Updates the ledger and account plan status for account renewals.

RENEWALS is a mandatory array reference parameter. Each element must contain
a hashref, where each hashref is in the format plan_id => int, quantity => int.

ERROR is a manadory ISP::Error object parameter.

FIXME: This sub is incomplete, so we don't know what it will return yet.




=head2 credit_card_payment({ transaction_data => DATA, error => ERROR })

There are two mandatory parameters that must be supplied within a hash
reference.

ERROR is an ISP::Error object, and DATA must be supplied as a hashref in the
following format:

	my $transaction_data = {                        
			DollarAmount    => $amount,                        
			Card_Number     => $card_number,                        
			Expiry_Date     => $card_expiry,                        
			CardHoldersName => $card_holder,                    
		};

Returns the payment statement from the bank upon approval, or the bank response code
upon failure.




=head2 calculate_invoice_amount({ username => USERNAME, data => DATA })

This method tallys up the total amount of all the line items in a transaction.

USERNAME is self explainitory. DATA is a hashref where the key is the item quantity, and
the value is the dollar amount of this particular transaction.

Returns the total amount for this transaction.

=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<steve at ibctech.ca>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISP::Transac


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of ISP::Transac
