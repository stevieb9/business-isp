#!/usr/bin/perl 

use strict;
#use diagnostics;

use DBI;
use DBIx::Recordset;
use Cwd 'abs_path';

use Test::More qw(no_plan);
use Data::Dumper;

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
  use_ok('ISP::User');
  use_ok('ISP::Sanity');
  use_ok('ISP::Vars');
  use_ok('ISP::Error');

my $user;
my $sanity;
my $vardb;
my $error;

my %plan_info;

_reset();

is ( $vardb->is_type( 'plan_info' ), 1, "is_type() returns true if the type is known" );
is ( $vardb->is_type( 'undefined' ), 0, "is_type() returns false if the type is not known" );

my @types = $vardb->is_type();

isa_ok ( \@types, 'ARRAY', "is_type() returns an array of types if called in list context" );


undef @types;
_reset();

@types = $vardb->return_types();

isa_ok ( \@types, 'ARRAY', "return_types() returns an array of types" );

undef @types;

@types = $vardb->return_types('blah');

isa_ok ( \@types, 'ARRAY', "return_types() returns an array of types, even when called with a param" );

undef @types;
_reset();

#
# struct
#

my $struct = $vardb->struct( 'plan_info' );
isa_ok ( $struct, 'HASH', "struct() returns a hash when asked for a known type" );

undef $struct;
_reset();

eval { $vardb->struct( 'asdfasdf' ) } ;
like (  $@,
		qr/No such data type/,
		"struct() is murdered by ISP::Error->bad_data() if asked for an unknown data type"
	);

_reset();

my @struct_ret = $vardb->struct( 'credit_card' );
isa_ok ( \@struct_ret, 'ARRAY', "When calling struct() in list context, a ref of the return," );

# individual tests

_reset();

my @cards = qw ( visa mastercard amex );
my $bad_card = 'asdf';

for my $card ( @cards ) {
	
	# we're only checking for card validity without processing
	# anything, so we can enable, then disable this
	
	my $bank_config = $vardb->ENABLE_BANK_PROCESSING();

	$vardb->ENABLE_BANK_PROCESSING( 1 ) if ! $bank_config;

	is ( $vardb->is_credit_card( $card ), 1, "$card is a credit card" );

	$vardb->ENABLE_BANK_PROCESSING( 0 ) if ! $bank_config;

}
is ( $vardb->is_credit_card( $bad_card ), 0, "$bad_card is not a credit card" );

my @known_cards = $vardb->struct( 'credit_card' );

my $cc_compare_ret = ( scalar( @cards ) == scalar( @known_cards ) );
is ( $cc_compare_ret, 1, "we are testing the availability of all cards" );

push @cards, 'unknown';

my $cc_scalar_cmp_ret;

if ( ( scalar( @cards ) == scalar ( @known_cards ) )) {
	$cc_scalar_cmp_ret = 1;
}
else {
	$cc_scalar_cmp_ret = 0;
}


is ( $cc_scalar_cmp_ret,
	0,
	"We know in a negative sense that we are testing all cards",
);



#
# compare()
#

_reset();

my $compare_ret = $vardb->compare({ type => 'plan_info', data => \%plan_info, error => $error });
is ( $compare_ret, 0, "compare() returns 0 upon success" );

$plan_info{ bad_attribute } = 'blah'; 

eval { $vardb->compare({ type => 'plan_info', data => \%plan_info, error => $error }) };
like ( $@,
	 '/is defined, but it has invalid attribute/',
	 "compare() dies with an ISP::Error when a struct has invalid attrs",
	);

_reset();

delete $plan_info{ username };
eval { $vardb->compare({ type => 'plan_info', data => \%plan_info, error => $error }) };
like ( $@,
	 '/defined, but is missing required attributes/',
	 "compare() dies with an ISP::Error when a struct is missing attrs" 
	);

_reset();

$vardb->FORGIVE_MISSING_ATTRS( 1 );

delete $plan_info{ username };

my $compare_w_attrs_disabled_ret = $vardb->compare({ type => 'plan_info', data => \%plan_info, error => $error });

is ( $compare_w_attrs_disabled_ret, 
	 0, 
	 "compare() returns success if FORGIVE_MISSING_ATTRS is enabled " .
	 "and there are attrs missing, as long as there aren't illegal attrs",
	);

$vardb->FORGIVE_MISSING_ATTRS( 0 );

eval { $vardb->compare({ type => 'plan_info', data => \%plan_info, error => $error }) };
like ( $@,
	 '/defined, but is missing required attributes/',
	 "compare() dies with an ISP::Error when a struct is missing attrs " .
	 "and FORGIVE_MISSING_ATTRS() has been re-enabled",
	);


#
# sanity_value_skip_permitted
#

_reset();

my $skip_permitted_ret = $vardb->sanity_value_skip_permitted();

isa_ok( $skip_permitted_ret, 'HASH', "sanity_value_skip_permitted() return" );

sub _clean 
{
 
        undef $user;
	undef $sanity;
        undef $error;
}

sub _reset {

        _clean();

    $user  	= ISP::User->new({ username => 'steveb' });
	$vardb	= ISP::Vars->new();
	$sanity	= ISP::Sanity->new();
    $error 	= ISP::Error->new();

	# we need to enable merchant processing internally
	# ...I don't have any other ideas currently

    %plan_info = (      
          'pap_date' => '',         
          'last_update' => '2009-07-28',
          'os' => '',
          'rate' => '0.00',
          'email' => 'isp@example.com',
          'dsl_number' => '905-885-4911',
          'plan_status' => 'active',
          'password' => '^[bbeJ>;H;',
          'billing_period' => '',   
          'plan' => 'goldenDSL',
          'id' => '', 
          'login_name' => 'steveb',
          'server' => '',
          'billing_method' => 'email',
          'hours' => '',
          'description' => '',
          'username' => 'steveb',
          'dob' => '',
          'over_rate' => '0.00',
          'comment' => '',
          'started' => 'August 1 20',
          'pap_method' => 'None',
          'next_billing_date' => '2009-08-22',
          'expires' => '2009-10-31',
		  'hours_balance' => '',
		  'classification' => '',
	  );
}

