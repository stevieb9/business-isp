#!/usr/bin/perl

use strict;
use warnings;
no warnings 'redefine';
#use diagnostics;

use DBI;
use DBIx::Recordset;
use Cwd 'abs_path';

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

use Test::More qw(no_plan);
use Data::Dumper;

print "\n\n***** Init *****\n\n";
  use_ok('ISP::User');
  use_ok('ISP::Sanity');
  use_ok('ISP::Vars');
  use_ok('ISP::Error');
  use_ok('ISP::Transac');

my $user;
my $sanity;
my $vardb;
my $error;
my $transac;

my %line_item = (
   
                  payment_method    => 'cheque',
                  amount        => '22.22',
                  comment       => 'This is a comment',
                  payment       => '22.22',
                  tax			=> '.13',
				  quantity      => '1',
                  item_name     => 'sohodsl',
		  );

my %payment_on_acct = (

				  payment_method    => 'cheque',
                  amount        =>	0, 
                  comment       => 'This is a comment',
                  payment       => '22.22',
				  tax			=> 0,
                  quantity      => '1',
                  item_name     => 'POA',
        );

{ # create_transaction

	_reset();
	my $test_transac = ISP::Transac->create_transaction({ data => \%line_item, error => $error });
	isa_ok ( $test_transac, 'ISP::Transac', "create_transaction called with valid data return" );
}

{ # calculate_invoice_amount

	_reset();

	my $test_transac = ISP::Transac->create_transaction({ data => \%line_item, error => $error });

	my $amount = $test_transac->calculate_invoice_amount({ 
								username => $user->username(), 
								data => { 
											$line_item{ quantity } => $line_item{ amount },
										}
								});

	ok( $amount == '25.11', "calculate_invoice_amount properly adds correctly for non tax exempt" );

	my $client_info = $user->client_info();
	
	$client_info->{ tax_exempt } = 'Y';

	$user->client_info({ client_info => $client_info });

	my $exempt = $user->tax_exempt();

	my $tax_exempt_amount = $test_transac->calculate_invoice_amount({ 
								username => $user->username(), 
								data => { 
											$line_item{ quantity } => $line_item{ amount },
										}
								});

	ok( $tax_exempt_amount == '22.22', "calculate_invoice_amount properly adds each item correctly for tax exempt" );

	$client_info->{ tax_exempt } = 'N';

	$user->client_info({ client_info => $client_info });
}


{ # insert transactions for later tests

	_reset();

	my %item = %line_item;

	my @pmt_meth = qw( cash cheque debit );
	my @payment	 = qw( 5.99 47.99 24.99 );

	for my $pmt_meth ( @pmt_meth ) {

		my $payment = shift @payment;
		
		$item{ payment_method }	= $pmt_meth;
		$item{ payment }		= $payment;
		$item{ amount }			= $payment;

		my $transac = ISP::Transac->create_transaction({ data => \%item, error => $error });

		my $return = $transac->purchase({ client => $user, error => $error });

		ok( $return =~ /\d+/, "the test transactions were inserted correctly" );
	}
}

{ # renew

	_reset();

	can_ok ( 'ISP::Transac', ( 'renew' ) );

	my @renewals = (
					{ 
						plan_id 	=> 25832,
						quantity	=> 5,
					},
					{
						plan_id		=> 25831,
						quantity	=> 1,
					}
				);

	#my $return = $transac->renew( \@renewals, $error );
	#is_ok ( $return, 0, "ISP::Transac->renew({ new({ config => 'ISP.conf-dist' }) }) returns success if all params are valid" );
}

SKIP: {

	eval { require Exact::Transaction };
	skip "Exact::Transaction not installed" if $@;

	my $config_check	= ISP::Object->new();
	my $enable_bank		= $config_check->ENABLE_BANK_PROCESSING();

	skip "Bank processing is not enabled" if ! $enable_bank;

	{ # credit card payment

	_reset();

	can_ok( 'ISP::Transac', 'credit_card_payment' );

	my $amount		= '29.99';
	my $card_number	= '4111111111111111';
	my $card_expiry	= '0912';
	my $card_holder	= 'Perl Testing';

	my %transaction_data = (
			DollarAmount		=> $amount,
			Card_Number			=> $card_number,
			Expiry_Date			=> $card_expiry,
			CardHoldersName		=> $card_holder,
		);

	my @return
		= $transac->credit_card_payment ({
							error				=> $error,
							transaction_data 	=> \%transaction_data,
						});

	is ( $return[0], '00',  "ISP::Transac->credit_card_payment response code " .
							"is 00 on success"
	);

	# INVALID CARD NUMBER

	$card_number	= '411';

	%transaction_data = (
			DollarAmount		=> $amount,
			Card_Number			=> $card_number,
			Expiry_Date			=> $card_expiry,
			CardHoldersName		=> $card_holder,
		);


	@return
		= $transac->credit_card_payment ({
							error				=> $error,
							transaction_data 	=> \%transaction_data,
						});

	is ( $return[0], '22', "response code is 22 for invalid credit card" ); 				

	$card_number = '4111111111111111';
	}

} # end skip banking

{ # transaction return

	my $transac_payment = ISP::Transac->create_transaction({ data => \%line_item, error => $error });
	my $return = $transac_payment->payment({ client => $user, error => $error });
	isa_ok ( $return, 'ISP::Error', "ISP::Transac->payment() with invalid data, return" );  

}

{ # payment
	
	_reset();

	my $transac_payment = ISP::Transac->create_transaction({ data => \%payment_on_acct, error => $error });
	my $return = $transac_payment->payment({ client =>  $user, error => $error });
	like ( $return, qr/\d+/, "ISP::Transac->payment() returns success with valid data" );
}

{ # purchase

	_reset();

	my $transac_purchase = ISP::Transac->create_transaction({ data => \%line_item, error => $error });
	my $return = $transac_purchase->purchase({ client => $user, error => $error });
	like ( $return, qr/\d+/, "ISP::Transac->purchase() returns success with valid data" );
}

{ # bad transac data

	_reset();

	my %bad_data = (
				  payment_method    => 'Cheque',
                  amount        => 'blah',
                  comment       => 'This is a comment',
                  payment       => '22.22',
                  quantity      => '1',
                  tax       	=> '.13',
                  item_name     => 'sohodsl',
        );

	my $bad_transac = ISP::Transac->create_transaction({ data => \%bad_data, error => $error }); 
}

{ # hst test

	_reset();

	my %tax_item = (
				  payment_method    => 'Cheque',
                  amount        => '1.22',
                  comment       => 'This is a comment',
                  payment       => '1.22',
                  quantity      => '1',
                  tax	        => 0,
                  item_name     => 'Tax',
        );

	my $transac = ISP::Transac->create_transaction({ data => \%tax_item, error => $error }); 

	ok ( $transac =~ /\d{2,12}/, "HST/Tax passes all checks" );
}

sub _clean 
{
 
	undef $transac;
	undef $user;
	undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

	$transac	= ISP::Transac->new();

	$user  	= ISP::User->new({ username => 'steveb' });
	$vardb	= ISP::Vars->new();
	$sanity	= ISP::Sanity->new();
    $error 	= ISP::Error->new();
}
