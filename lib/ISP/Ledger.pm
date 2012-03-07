package ISP::Ledger;

use strict;
use warnings;

use vars qw( $VERSION @ISA );
use base qw( ISP::Object );

use ISP::Billing;

$VERSION = sprintf "%d", q$Revision: 184 $ =~ /(\d+)/;

BEGIN {
# config accessors

        my @config_vars = qw (
            LINES_TO_STDOUT
                       );

        for my $member ( @config_vars ) {
	        no strict 'refs';
                                                               
            *{ $member } = sub {                              
                my $self = shift;                       
				return $self->{ config }{ $member };        
            }                                               

		}
} # end BEGIN

sub write_ledger {

	use DateTime;
	use DateTime::Format::MySQL;

	my $self			= shift;
	my $params			= shift;

	$self->function_orders();
	
	my $client			= $params->{ client };
	my $transaction		= $params->{ transaction };


	my $present_date	= DateTime->now( time_zone => 'America/New_York' );
	my $ledger_date		= DateTime::Format::MySQL->format_datetime( $present_date );

	my $username		= $client->username();	
	my $tax_exempt = ( $client->tax_exempt() =~ /y/i )
		? $client->tax_exempt()
		: 0;

	my $invoice_number 	= $self->invoice_number();
	$self->invoice_number( $invoice_number );

	my @gledger_entries;
	my @uledger_comments;
	my $payment_method;
	my $payment;
	my $tax_price;
	my $tax_total;
	my $grand_total;
	my $payment_total;

	for my $line_item ( @{ $transaction } ) {

		$payment_method		= $line_item->{ payment_method };
		$payment			= $line_item->{ payment };
		my $comment			= $line_item->{ comment };
		my $item_name		= $line_item->{ item_name };
		my $quantity		= $line_item->{ quantity };
		my $amount			= $line_item->{ amount };

		$tax_price			= $line_item->{ tax };

		my $total_price     = sprintf ('%.2f', ( $quantity * $amount ));
        $grand_total        += $total_price;
        $tax_total          += sprintf ('%.2f', ($tax_price * $total_price));

		$payment_total		+= $payment;  

		if ( $payment_method eq 'invoice' ) {
			$payment = 0;
		}

        push (@uledger_comments, $comment);

		my %gledger_entry = (
					
					username		=> $username,
					amount			=> $amount,
					payment			=> $payment,
					quantity		=> $quantity,
					payment_method	=> $payment_method,
					comment			=> $comment,
					invoice_number	=> $invoice_number,
					item_name		=> $item_name,
					total_price		=> $total_price,
					date			=> $ledger_date,

				);

		push @gledger_entries, \%gledger_entry;

	}
	

	if ( ! $tax_exempt and $tax_price ) {
		
		if ( $payment_method eq 'invoice' ) {
			$payment	= 0;
		}
		else {
			$payment	= $tax_total;
		}

		my %tax_gledger_entry = (

				username		=> $username,
				amount			=> $tax_total,
				payment			=> $payment,
				quantity		=> 0,
				payment_method	=> $payment_method,
				comment			=> 'Tax',
				invoice_number	=> $invoice_number,
				item_name		=> 'Tax',
				total_price		=> $tax_total,
				date			=> $ledger_date,

			);

		push @gledger_entries, \%tax_gledger_entry;
	}
	
	my $schema = $self->schema();

	my $gledger_rs = $schema->resultset( 'Gledger' );
	$gledger_rs->populate( \@gledger_entries );

	# do the uledger stuff

	push @uledger_comments, " via $payment_method";
	my $uledger_comment	= join ( '--', @uledger_comments );

	my $uledger_payment;

	if ( $payment_method eq 'invoice' ) {
		$uledger_payment = 0;
	}
	else {

		$uledger_payment = $payment_total; 
	
		# if payment is 0, it's a purchase, and payment must eq amount
		# so the ledger balances!

		if ( $uledger_payment == 0 ) {
			$uledger_payment = ( $grand_total + $tax_total );
		}
		$uledger_payment = sprintf ( '%.2f', $uledger_payment );
	}

	my $uledger_amount 	= ( $grand_total + $tax_total );	
	$uledger_amount = sprintf ( '%.2f', $uledger_amount );

	if ( $uledger_amount < 0 ) {
		$uledger_amount = 0;
	}

	my %uledger_entry 	= (
				
				username		=> $username,
				date			=> $ledger_date,
				invoice_number	=> $invoice_number,
				comment			=> $uledger_comment,
				amount			=> $uledger_amount,
				payment			=> $uledger_payment,
			);
	
	my $uledger_rs 
		= $schema->resultset( 'Uledger' )->create( \%uledger_entry );
	$uledger_rs->update();

	my $current_balance = $self->balance({ username => $username });

	my $invoice_balance = ( $uledger_payment - $uledger_amount );
	
	$invoice_balance *= -1;

	my $new_balance		
		= ( $invoice_balance + $current_balance );
	
	$self->balance({ username => $username, balance => $new_balance });

	my $send_bill = ISP::Billing->new();
	$send_bill->email_bill({ invoice => $invoice_number });

	return $invoice_number;

}
sub gledger_add {
    
    use DateTime;

    my $self        = shift;
   	my $params		= shift;

    $self->function_orders();
   	
	my $client		= $params->{ client };
    my $transaction	= $params->{ transaction };    # array ref of hash refs
    

    my $present_date     = DateTime->now(time_zone => 'America/New_York');
    my $date_string      = $present_date->month_abbr . " " . $present_date->day . ", " . $present_date->year;
    my $date_ymd         = $present_date->ymd('-');

    my $username   = $client->username();
	my $tax_exempt = ( $client->tax_exempt() =~ /yes/i )
		? $client->tax_exempt()
		: 0;

    my @gledger_entry;
    my @uledger_comments;
    my $payment_method;
    my $payment;
    my $tax_price;
    my $tax_total;
    my $grand_total;

    my $invoice_number = $self->invoice_number();
	$self->invoice_number($invoice_number);

	for my $line_item ( @{ $transaction } ) {

        $payment_method     = $line_item->{ payment_method };
        $payment        	= $line_item->{ payment };
        my $comment         = $line_item->{ comment };
        my $item_name       = $line_item->{ item_name };
        my $quantity        = $line_item->{ quantity };
        my $amount          = sprintf ( '%.2f', $line_item->{ amount } );

        $tax_price        	= $line_item->{ tax };

        my $total_price     = sprintf ('%.2f', ($quantity * $amount));
        $grand_total        += $total_price;
        $tax_total          += sprintf ('%.2f', ($tax_price * $total_price));

        push (@uledger_comments, $comment);

        # if it's a payment, we need to adjust accordingly for the legacy
        # ledger storage mechanism

        $amount     	= $payment * -1 if $payment;
        $total_price    = $payment * -1 if $payment;

        push (@gledger_entry, "$payment_method&$date_string&$invoice_number&$username&$quantity&$item_name&$comment&$amount&$total_price");

    }
    if (! $tax_exempt and $tax_price) {
        push (@gledger_entry, "$payment_method&$date_string&$invoice_number&$username&&Tax&&&$tax_total");
        $grand_total = $tax_total + $grand_total;
    }    

    # tally up the info, create the u and g ledger entries, and write
    # them out

    $grand_total = sprintf ('%.2f', $grand_total);
    $grand_total = 0 if $payment;

    my %uledger_entry = (
            date    => $date_string,
            invoice => $invoice_number,
            comment => \@uledger_comments,
            amount  => $grand_total,
            payment => $payment,
            
    );

    # write the ledgers

    $self->_gledger_write_legacy($client, $present_date, \@gledger_entry);
    $self->_uledger_write_legacy($client, $present_date, \%uledger_entry);

    return ($invoice_number);

} # end gledger_add()
sub _gledger_write_legacy {

    # this is an internal call, and should only be
    # called by other module subs

    my $self         = shift;
    my $client       = shift;    # EagleUser object
    my $date     	 = shift;    # DateTime (current) object
    my $ledger_entry = shift;    # aref

    $self->function_orders();

    my $username = $client->username();
    my $prefix   = $client->prefix();
    my $month    = $date->month_abbr;
    my $year     = $date->year;

    my $ledger_name = "gledger.${month}";
    my $ledger_dir  = "/usr/adm/accounting/${year}";
    my $ledger    	= "${ledger_dir}/${ledger_name}";

    open (my $gledger_file, '+>>', $ledger) or die "Can't open the gledger, $ledger: $!";

    for (@{$ledger_entry}) {
        print $gledger_file "$_\n";
        print "$_\n" if $self->LINES_TO_STDOUT();
    }
    close $gledger_file;

} # end gledger_write_legacy
sub bank_receipt {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $bank_receipt	= $params->{ bank_receipt };
	my $invoice_number	= $params->{ invoice_number };

	my $schema = $self->schema();

	if ( $bank_receipt ) {
		
		# setter

		my $data	= {
				record			=> $bank_receipt,
				invoice_number	=> $invoice_number,
			};	
	
		my $receipt_rs = $schema->resultset( 'Bank' )->create( $data );
		$receipt_rs->update();
		
		return;
	}
	else {
		
		# getter

		my $receipt_rs = $schema->resultset( 'Bank' )->find({
														invoice_number => $invoice_number,
													});

		my $bank_receipt = $receipt_rs->record();
		
		return $bank_receipt;
	}

}
sub _uledger_write_legacy {

    use Tie::File;

    my $self         = shift;
    my $client       = shift;
    my $date     	 = shift;     # DateTime object
    my $ledger_entry = shift;    # href

    $self->function_orders();

    my $username = $client->username();
    my $prefix   = $client->prefix();
    my $month    = $date->month_abbr;
    my $year     = $date->year;

    my $date_string = $ledger_entry->{date};
    my $invoice     = $ledger_entry->{invoice};
    my $comment     = $ledger_entry->{comment};    # aref
    my $amount      = $ledger_entry->{amount};
    my $payment     = $ledger_entry->{payment};

    my $ledger_name = "${username}.${month}.db";
    my $ledger_dir  = "/usr/adm/accounting/${prefix}/${year}/${month}";
    my $ledger      = "${ledger_dir}/${ledger_name}";

    my $comments 	= join ('--', @{$comment});

    # tie the ledger, and get the balance

    tie my @balance_line, 'Tie::File', $ledger;
    my $balance = (split (/&/, ($balance_line[-1])))[5];
    $balance    = sprintf ('%.2f', $balance += ($amount - $payment));

    open (my $uledger_file, '>>', $ledger) or die "Can't open the uledger, $ledger: $!";
    print $uledger_file "$date_string&$invoice&$comments&$amount&$payment&$balance";
    print "$date_string&$invoice&$comments&$amount&$payment&$balance" 
        if $self->LINES_TO_STDOUT();
    close $uledger_file;

} # end _uledger_write_legacy()

sub get_invoice_number_legacy {
                
    my $self = shift;

    $self->function_orders();

    open (my $invoice_file, "<", "/usr/adm/accounting/invoice_number.dat")
        or die "Can't open the invoice number file!: $!";

    my $invoice_number = <$invoice_file>;
        close $invoice_file; 

    return ($invoice_number);

} # end get_invoice_number_legacy()
sub invoice_number {
	
	my $self 	= shift;
	my $inv_num	= shift;
	my $date	= shift;

	$self->function_orders();

	my $schema	= $self->schema();

	if ( defined $date && ! defined $inv_num ) {

		# user wants all inv nums for date specified

		my $inv_num_rs	= $schema->resultset( 'Receipt' )->search(
										{ date => $date },
									);
		my @inv_nums;

		while ( my $inv_num_db_row = $inv_num_rs->next ) {
			push @inv_nums, $inv_num_db_row->inv_num;
		}
		
		return \@inv_nums;
	}

	if ( ! defined $inv_num ) {
	
		# this is a getter call for the next available inv_num

		my $invoice_number_rs	= $schema->resultset( 'Receipt' );
		my $invoice_number		= $invoice_number_rs->count();
		$invoice_number++;
		
		return $invoice_number;
	}
	else {

		# we're adding a new one

		$date = ( $date )
			? $date
			: $self->date({ get => 'day' });

		my $inv_num_rs	= $schema->resultset( 'Receipt' );
		$inv_num_rs->create({
			   				inv_num	=> $inv_num,
							date	=> $date,
						});	
	}

	return 0;
}
sub set_invoice_number_legacy {

    my $self 			= shift;
    my $invoice_number 	= shift;

    $self->function_orders();
	
	$invoice_number++;

    open (my $invoice_file, ">", "/usr/adm/accounting/invoice_number.dat")
        or die "Can't open the invoice number file!: $!";
    print $invoice_file $invoice_number;

    close $invoice_file;

} # end set_invoice_number_legacy()

sub get_uledger {

    my $self	= shift;
	my $params	= shift;

	my $invoice_number	= $params->{ invoice_number } || undef;
	my $username		= $params->{ username } || undef;

    $self->function_orders();

	my $schema = $self->schema();
	my $doc_rs = $schema->resultset( 'Uledger' );

	# if looking for an individual invoice, do the work and return

	if ( $invoice_number ) {

		my $document = $doc_rs->search({ invoice_number => $invoice_number });
		my $invoice	 = $self->schema({ result => $document, extract => 'href' })->first();

		return $invoice;
	}
	else {	# were searching by username
	
		my $document_list = $doc_rs->search(
										{ username => $username },
										{ order_by => 'invoice_number DESC' },
									);
		my @uledger_entries;

		while ( my $entry_ref = $self->schema({ result => $document_list, extract => 'href' })->next() ) {

			push @uledger_entries, $entry_ref;

		}

		return ( ref $uledger_entries[0] ) ? \@uledger_entries : 1;
	}
}
sub get_gledger {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $invoice_number	= $params->{ invoice_number };

	my $schema = $self->schema();
	my $doc_rs = $schema->resultset( 'Gledger' );

	my $document_list = $doc_rs->search(
										{ invoice_number => $invoice_number } ,
										{ order_by => 'invoice_number' },
									);

	my @gledger_entries;

	while ( my $entry = $self->schema({ result => $document_list, extract => 'href' })->next() ) {
		push @gledger_entries, $entry;
	}
	
	return \@gledger_entries;
}
sub ledger_field {

	my $self 	= shift;
	my $params	= shift;

	$self->function_orders();

	my $entry	= $params->{ entry };
	my $fields	= $params->{ fields }; # aref

	my %data;

    for my $field ( @$fields ) {
		$data{ $field } = $entry->{ $field };
	}

	return \%data;
}
sub balance {

	my $self 	 	= shift;
	my $params		= shift;

	$self->function_orders();

	my $username 	= $params->{ username };
	my $new_balance = $params->{ balance };

	my $schema		= $self->schema();


	my $balance_rs	= $schema->resultset( 'Balance' )->find({
														username => $username,
													});
	return if ! $balance_rs;

	if ( defined $new_balance ) {

		my $sanity	= ISP::Sanity->new();
		my $error	= ISP::Error->new();

		$sanity->validate_value({ tag => 'balance', value => $new_balance, error => $error });
	
		return if $error->exists();
		
		$balance_rs->balance( $new_balance );
		
		return 0 if $balance_rs->update();

		return;
	}

	return $balance_rs->balance();

}
sub sum {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $date	= $params->{ date };
	my $add		= $params->{ total };	# column to total for the items
	my $for		= $params->{ for };		# column with items to add totals for

	my $schema	= $self->schema();
	
	my $items	= $self->item_count({
							date	=> $date,
							table	=> 'Gledger',
							column	=> $for,
						});

	my @item_names = keys %$items;

	my $return;

	for my $item_name ( @item_names ) {
					
	my $rs
	  		= $schema->resultset( 'Gledger' )->search(
		  								{ date		=> { -like => "$date%" } ,
										 item_name	=> $item_name },
									);

			my $item_revenue;

			while ( my $entry = $rs->next ) {
				$item_revenue += $entry->$add();
			}
		
			$return->{ $item_name } = $item_revenue;
	}

	return $return;
}


sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}











# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__


















# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

ISP::Ledger - Perl module for ISP accounting user/general ledger operations.

=head1 SYNOPSIS

  use ISP::Ledger;
  my  $ledger = ISP::Ledger->new();

=head1 DESCRIPTION

This module handles all ledger operations for the ISP accounting system. It
will be used for legacy text-file based ledger/accounting files, and the new
db system.

=head1 MODULES

=head2 new()

Instantiates a new ISP::Ledger object. Returns undef upon failure.

This method is inhereted from the base class.



=head2 write_ledger({ client => USER, transaction => TRANSAC )

Use this method to write the finalized transaction to the general and user
ledgers, and updates the clients balance.

Both parameters are mandatory, and are passed in within a hash reference.

USER is an ISP::User object, and TRANSAC is an ISP::Transac object.

Returns the invoice number of this transaction  upon success.




=head2 gledger_add(USER, TRANSACTION)

* This method will be deprecated once we go into production.

Prepares the appropriate legacy-style ledger strings, and inserts them into the
ISP accounting ledgers.

USER is an ISP::User object, and TRANSACTION is an ISP::Transac object. No
error checking is performed here, as the data verification is done via ISP::Transac.

Uses _gledger_write_legacy() and _uledger_write_legacy() to write out the 
ledger data.

Returns the invoice number of the current process as an $int.



=head2 _gledger_write_legacy(USER, DATE, ENTRY)

* This method will be deprecated once we go into production.

Writes the transaction data to the legacy style general ledger. USER is an ISP::User
object. DATE is a DateTime (now()) object, and ENTRY is an array reference that
contains one ledger line per array element.



=head2 _uledger_write_legacy(USER, DATE, ENTRY)

* This method will be deprecated once we go into production.

Writes the transaction data to the legacy style user ledger. USER is an ISP::User
object. DATE is a DateTime (now()) object, and ENTRY is a hash reference that
contains the entry items.
 


=head2 bank_receipt({ bank_receipt => RECEIPT, invoice_number => INVNUM })

This method stores a bank receipt if a transaction was done via credit card.

The parameters are passed in within a hash reference.

If only the INVNUM is passed in, the bank receipt will be returned as a scalar.

If both RECEIPT and INVNUM are passed in, the RECEIPT will be stored in the
database and associated with the invoice containing INVNUM document number.

Returns undef if storing a document, or if the retrieval of a document is
not successful.



=head2 get_invoice_number_legacy() 
 
* This method will be deprecated once we go into production.

Retrieves the legacy style invoice number. Takes no parameters.

Returns the invoice number as an $int.



=head2 invoice_number( INVNUM, DATE )

DATE is an optional parameter, and must be in the form '2010-09-08'. If
passed in, the return will be an array reference of all the invoice numbers
that were created on that particular day. Note that INVNUM and DATE can not
be passed in simultaneously, so the call will look like this:

	$ledger->invoice_number( undef, '2010-09-08' );

INVNUM is a scalar integer.

If INVNUM is passed in, we will claim the next available invoice number
as taken.

If INVNUM is not passed in, we return the next available invoice number
that can be used.




=head2 get_uledger({ username => USERNAME, invoice_number => INVNUM })

Parameters are passed in within a hash reference.

If USERNAME is passed in, we will return an array reference of that
user's invoices, or 1 if no invoices are found.

If INVNUM is passed in, will return a hash reference of that particular
invoice.

If both parameters are passed in, the INVNUM will take precedence.



=head2 get_gledger({ invoice_number => INVNUM })

Parameters are passed in within a hash reference.

INVNUM is a mandatory integer parameter.

Returns an array reference containing all ledger entries related to the
invoice number.

If no entries can be found, the aref will be empty.



=head2 set_invoice_number_legacy(INVOICE_NUMBER)

* This method will be deprecated once we go into full production.

Stores an updated invoice number to the legacy file-based system.

INVOICE_NUMBER is an $int. Will die() if the invoice file can not be opened.
There is no return.



=head2 balance ({ username => USERNAME, balance => BALANCE })

Manages a client account financial balance. Parameters are passed in
within a hash reference.

USERNAME is a mandatory parameter, BALANCE is optional.

If the optional decimal parameter BALANCE is supplied, will update the
client account balance and set it to BALANCE, and return 0 if
successful and undef upon failure.

If BALANCE is not passed in, the users current balance is returned.




=head2 ledger_field({ entry => ENTRY, fields => FIELDS })

Used to extract specific fields from the user or general ledger.

ENTRY is a mandatory parameter, and is a hash reference of a single row
of a ledger item.

FIELDS is a mandatory parameter. It is an array reference, containing
the ledger fields that you want returned.

Returns a hash reference of the field and value pairs.


=head2 sum({ date => DATE, for => FOR, total => TOTAL })

This method will add up all of the entries in the TOTAL column for each of
the unique entries in the FOR column in the general ledger table.

DATE is a mandatory string parameter in the form YYYY, YYYY-MM or YYYY-MM-DD.

FOR is a string that represents the column name that you want to get a sum for.

TOTAL is a string that represents the column name that you want to create the
sum of.

Returns a hash reference of the unique items in FOR, who's values are the summarized
numbers in TOTAL.





=head1 AUTHOR

Steve Bertrand, steveb@cpan.org

=head1 SEE ALSO

perl(1).

=cut
