#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw( no_plan );

use Data::Dumper;

use_ok('ISP::Object');
use_ok('ISP::Reports');

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

{ # income_by_payment_type  

	can_ok( 'ISP::Reports', ('income_by_payment_type') );

	my $rep = ISP::Reports->new();

	my $date = $rep->date({ get => 'day' });

	my $result = $rep->income_by_payment_type({ date => $date });

	isa_ok( $result, 'ARRAY', "income_by_payment_type() returns an array ref" );
	isa_ok( $result->[0], 'HASH', "each income_by_payment_type() array element" );

	# test the actual data

	isn't( exists $result->[0]{ nothing }, 1, "exists baseline test for income_by_payment_type()" );
	is( exists $result->[0]{ payment_method }, 1, "each item in income_by_payment_type() return contains a pmt_type field" );
	is( exists $result->[0]{ entries }, 1, "each item in income_by_payment_type() return contains an entries field" );
	isa_ok( $result->[0]{ entries }->[0], 'HASH', "each entry in the 'entries' section of income_by_payment_type()" );

	my @fields = qw(
					payment_method
					total_price
					comment
					item_name
					invoice_number
					username
					fullname
				);

	# check for all fields in each entry

	for my $field ( @fields ) {
		is( exists $result->[0]{ entries }->[0]{ $field }, 1, "each entry in income_by_payment_type() contains a *** $field *** field." );
	}

	# check for extra fields in each entry

	my @keys = keys %{ $result->[1]{ entries }->[0] };

	my $ok_count;

	for my $key ( @keys ) {

		$ok_count++ if grep $_ eq $key, @fields;
	}

	ok( $ok_count == scalar( @fields ), "the proper number of fields were returned in a income_by_payment_type() entry" );
}

{ # income_by_item

	can_ok( 'ISP::Reports', ('income_by_item') );

	my $rep = ISP::Reports->new();

	my $date = $rep->date({ get => 'day' });

	my $res = $rep->income_by_item({ date => $date });

	isa_ok( $res, 'ARRAY', "income_by_item() return" );
	isa_ok( $res->[0], 'HASH', "each income_by_item() list element" );
	ok( scalar( @$res ), "each income_by_item() return can have multiple elements" );

	$res = {};
	$res = $rep->income_by_item({ date => $date, item => 'sohodsl' });

	ok( scalar ( @$res ), "when called item param, the return of income_by_item() contains only a single element" );
}

{ # unused service

	can_ok( 'ISP::Reports', ('unused_service') );

	my $rep = ISP::Reports->new();

	my $ret = $rep->unused_service();

	isa_ok( $ret, 'ARRAY', "unused_service() return" );
	isa_ok( $ret->[0], 'ARRAY', "first element of unused_service() retval" );
	isa_ok( $ret->[1], 'ARRAY', "second element of unused_service() retval" );
	isa_ok( $ret->[0][0], 'HASH', "the first element returned in unused_service() first element" );
	isa_ok( $ret->[1][0], 'HASH', "the first element returned in unused_service() second element" );

	ok( exists $ret->[0][0]{ months }, "unused_service() has 'months' in the totals hash elem when called with no params" );
	ok( exists $ret->[1][0]{ expires }, "unused_service() has 'months' in the data hash elem when called with no params" );	

	my $error = ISP::Error->new();

	$ret = $rep->unused_service({ hours => 1, error => $error });

	ok( exists $ret->[0][0]{ hours }, "unused_service() has 'hours' in the totals hash elem when called with 'hours' param" );
	ok( exists $ret->[1][0]{ hours }, "unused_service() has 'hours' in the data hash elem when called with 'hours' param" );	

}
