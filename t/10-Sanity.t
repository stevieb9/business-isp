#!/usr/bin/perl 

use strict;
#use diagnostics;


use DBI;
use DBIx::Recordset;

use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
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

sub _clean {
 
    undef $vardb;
    undef $user;
    undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

    $user   = ISP::User->new({ config => $conf, username => 'steveb' });
    $vardb  = ISP::Vars->new({ config => $conf });
    $sanity = ISP::Sanity->new({ config => $conf });
    $error  = ISP::Error->new({ config => $conf });
}

sub plan_info {

        my %plan_info = (

          'pap_date' => '0',
          'last_update' => '0000-00-00',
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
          'description' => '1',
          'username' => 'steveb',
          'dob' => '',
          'over_rate' => '0.00',
          'comment' => '',
          'started' => 'August 1, 20',
          'pap_method' => 'None',
          'next_billing_date' => '',
          'expires' => '0000-00-00',
          'hours_balance' => 0,
          'classification' => '',
      );

    return %plan_info;
}

sub process {

    my %process = (

            plana_deduction => '',

        );

    return %process;
}

sub user_info {

    my %user_info = (

          home_phone => '905-885-5363',
          billing_address1 => '101 Phillips Rd.',
          shipping_address2 => '',
          billing_company_name => '',
          shipping_address1 => '101 Phillips Rd.',
          last_update => '0000-00-00',
          shipping_email_address => '',
          billing_first_name => 'Steve',
          shipping_company_name => '',
          id => '4118',
          shipping_first_name => 'Steve',
          work_phone => '',
          billing_last_name => 'Bertrand',
          billing_address2 => '',
          tax_exempt => 'N',
          billing_email_address => 'isp@example.com',
          shipping_town => 'Port Hope',
          shipping_postal_code => 'L1A 3Z8',
          username => 'steveb',
          billing_postal_code => 'L1A 3Z8',
          comment => 'EagleStaff Account DSL: 905-885-4911',
          billing_province => 'Ont',
          shipping_province => 'Ont',
          shipping_last_name => 'Bertrand',
          billing_town => 'Port Hope',
          fax_phone => '905-372-',
    );
    
    return %user_info;
}

sub testplan {

    my $self = shift;

    my %plan = (

            'sohodsl' => 'SohoDSL',
            'plane' => 'PlanE',
            'pland' => 'PlanD',
            'dom_reg' => 'Domain Registration',
            'planc' => 'PlanC',
            'planb' => 'PlanB',
            'residsl' => 'ResiDSL',
            'slipstream' => 'SlipStream',
            'plana' => 'PlanA',
            'bizdsl' => 'BizDSL',
            'extra_hours' => 'Extra Hours'
    );

    return %plan;
}

sub payment_method {

    my $self = shift;

    my %payment_methods = (

                amex            => 'Amex',
                baddebt         => 'BadDebt',
                cheque          => 'Cheque',
                cash            => 'Cash',
                contra          => 'Contra',
                debit           => 'Debit Card',
                free            => 'Free',
                giftc           => 'Gift Card',
                mastercard      => 'Mastercard',
                netbank         => 'Internet Banking',
                other           => 'Other',
                telebank        => 'Telephone Banking',
                visa            => 'Visa',

    );

    return %payment_methods;
}

sub billing_method {

    my $self = shift;

    my %billing_methods = (

                email           => 'Email',
                fax             => 'Fax',
                mail            => 'Mail',

    );

    return %billing_methods;

}

sub pap_date {

        my $self = shift;

        my %pap_dates = (

                0  => '',
                1  => '1st',
                15 => '15th',
        );

    return %pap_dates;
}

sub plan_status {

        my $self = shift;        

        my %plan_status = (

                active  => 'Active',
                hold    => 'On Hold',
                erase   => 'Erase',
                flag    => 'Flag',
        );

        return %plan_status;
}

sub pap_method {
                
                my $self = shift;
        
                my %pap_methods = (
        
                        none    => '',
                        bank    => 'Bank',
                        visa    => 'Visa',
                        mc      => 'Mastercard',
                        amex    => 'Amex',                
        );
}

sub credit_cards {

    my $self = shift;

    my %credit_cards = (

            visa        => 1,
            mastercard  => 1,
            amex        => 1,
    );
}

sub transaction_data {

        my $self = shift;

        my %transaction_data = (

                  payment_method    => 'Visa',
                  amount        => '22.00',
                  comment       => 'This is a comment',
                  payment       => 0,
                  quantity      => '1',
                  tax           => '.13',
                  item_name     => 'sohodsl',
        );
}

sub note_classification {

    my $self = shift;

    my %note_classification = (

                system          => 1,
                technical       => 1,
                accounting      => 1,
                non_payment     => 1,
                password_change => 1,
                resolved        => 1,
            );
}
sub _nothing{}; # placeholder so vim folds at beginning of tests

my %typedefs = (
    
        process             => \&process,
        credit_card         => \&credit_cards,
        plan_info           => \&plan_info,
        user_info           => \&user_info,
        plan                => \&testplan,
        payment_method      => \&payment_method,
        billing_method      => \&billing_method,
        pap_date            => \&pap_date,
        plan_status         => \&plan_status,
        pap_method          => \&pap_method,
        transaction_data    => \&transaction_data,
        note_classification => \&note_classification,
    );


print Dumper \$typedefs{plan};
print "************************************\n\n\n\n*******************\n";
#
# Sanity
#

print "\n\n***** Public Tests *****\n\n";

can_ok('ISP::Sanity', ('validate_data'));
can_ok('ISP::Sanity', ('unsafe_string'));
can_ok('ISP::Sanity', ('unsafe_word'));
can_ok('ISP::Sanity', ('validate_renew'));

print "\n\n***** Core Tests *****\n\n";

can_ok('ISP::Sanity', ('check_type'));

#
# DATA VALIDATION
#

print "\n\n*****Data typing and content validation *****\n\n";

_reset();

my @known_types = $vardb->is_type();
my @missing_types;
my %data;

for my $known_type (@known_types) {

    _clean();

    unless (exists $typedefs{$known_type} ) {
        push (@missing_types, $known_type);
        next();
    }

    %data = &{ $typedefs{$known_type} };

    eval { $sanity->check_type({ 
                        type    => $known_type, 
                        data    => \%data, 
                        error   => $error 
                    }) 
    } ;
    
    unlike ( $@, 
         '/not a defined datatype/', 
         "$known_type is a valid and available data type" 
        );

}

print "\n";

is (    
    scalar(@missing_types), 
    0, 
    "All known data types have been tested for existence" 
);

print "\n";
print "============================================================\n" .
    "MISSING TEST DATATYPE DEFINITIONS FOR THE FOLLOWING TYPES:\n\n" .
    "\t ${ \( join (', ',  @missing_types) ) }\n\n" .
    "HALTING TEST OF ISP:Sanity " .
    "UNTIL ALL TYPES ARE INCLUDED!\n\n" .

    "To fix this issue, add the type into a sub like the others at " .
    "the top of this file, and then add the type to the %typedefs " .
    "dispatch table near the top of this file as well." .
    "============================================================\n\n" and 
      exit() if @missing_types;

print "\n";

#FIXME: unknown data type

# field value check

_reset();

my @bad_fields;

for my $known_type (@known_types) {


    %data = &{ $typedefs{$known_type} };        

    eval { $sanity->validate_data({ 
                        type    => $known_type, 
                        data    => \%data, 
                        error   => $error, 
                    }) 
    } ;

    unlike ( $@,
         '/no Sanity check/',
         "All fields in '$known_type' have validation methods in Sanity" 
        );
}

print "\n*****Testing invalid fields inserted into data types*****\n\n";

_reset();

# test malformatted types

for my $type (@known_types) {

    my %data = &{ $typedefs{$type} };
    $data{blah} = 'badkey';
    eval { $sanity->validate_data({ 
                        type    => $type, 
                        data    => \%data, 
                        error   => $error, 
                    }) 
    } ;
    like ( $@,
        qr/invalid attributes/,
        "Sanity barfs if the passed-in '$type' datatype has invalid attributes"
         );
}

print "\n*****Testing fields removed from data types*****\n\n";

_reset();
$vardb->FORGIVE_MISSING_ATTRS(0);
        
# test malformed types

for my $type (@known_types) {

    my %data = &{ $typedefs{$type} };

    while ( my ($key, $value) = each (%data)) {
        delete $data{$key};
        last();
    }
        eval { $sanity->validate_data({ 
                            type    => $type, 
                            data    => \%data, 
                            error   => $error, 
                        }) 
        } ;
        like ( $@,
                qr/missing required attributes/,
                "Sanity barfs if the passed-in '$type' datatype is lacking mandatory attributes"
             );
}

_reset;

#my $object = ISP::Object->new({ config => $conf });
#print join ("\n", $object->GET_CODEFLOW());

print "\n*****Testing validate_renew*****\n\n";

_reset();

eval { $sanity->validate_renew() } ;
like (  $@, 
        '/Bad API/',
        "Calling validate_renew() with no params is " .
        "mutilated by ISP::Error->bad_api()"
    );      

eval { $sanity->validate_renew({ error => $error, }) } ;
like (  $@,
        '/Invalid or missing plan_id parameter/',
        "Calling validate_renew() with a bad plan_id " .
        "dies by ISP::Error->bad_data()"
    );

eval { $sanity->validate_renew({ error => $error, plan_id => '1', }) } ;
like (  $@,
        '/Quantity must/',
        "Calling validate_renew() with a good plan_id but bad quantity " .
        "dies by ISP::Error->bad_data()"
    );


my $return = $sanity->validate_renew({
                            error       => $error,
                            plan_id     => '1',
                            quantity    => 300,
                            amount      => '2asdf99.00' 
                        });
isa_ok ( $return, 'ISP::Error', "Passing a bad amount param to validate_renew() return value" );

undef $return;

_reset();

$return = $sanity->validate_renew({
                        error       => $error,
                        plan_id     => '1',
                        quantity    => 2,
                        amount      => '299.00' 
                    });
is ( $return, 0, "validate_renew returns success (0) when all params are within spec" );


undef $return;
_reset();

#
# unsafe*
#

print "\n*****Testing unsafe_word and unsafe_string*****\n\n";

$return = $sanity->unsafe_word( '@$' );
is ( $return, '@', "unsafe_word() returns the bad char" );

undef $return;

$return = $sanity->unsafe_string( '.' );
is ( $return, '.', "unsafe_string() returns the bad char" );

#
# individual checks
#

print "\n*****Testing the individual check_* methods*****\n\n";

# check_phone

print "\n# check_phone()\n\n";

_reset();

my $check_phone_good_ret = $sanity->check_phone( 'phone', '905-373-9313', $error );
is ( $check_phone_good_ret, 0, "check_phone() returns 0 upon success" );
is ( $error->exists(), 0, "...and no error is set" );

my @phone_nums = qw ( a 905 905-373 905-373-931 905.373.9313 1-905-373-9313 ! --- 0 );

for my $bad_num ( @phone_nums ) {

    _reset();

    $sanity->check_phone( 'phone', $bad_num, $error );
    is ( $error->exists(), 1, "$bad_num passed to check_phone results in an ISP::Error being flagged" );

}   

# check_username

print "\n# check_username()\n\n";

_reset();

my $check_username_ret = $sanity->check_username( 'user', 'steveb', $error );
is ( $check_username_ret, 0, "check_username() returns 0 on success" );
is ( $error->exists(), 0, "...and no error is set" );

my @good_users = qw ( aaaa a_aaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 1aaa a1aa aa a.a aa 11 a1 1a );

for my $good_user ( @good_users ) {

    _reset();

    my $ret = $sanity->check_username( 'un', $good_user, $error );

    is ( $ret, 0, "$good_user passed to check_username() returns success" );
    is ( $error->exists(), 0, "...and no error is set" );


}

my @bad_users  = qw ( _aaa !aaa -aaa aaa. .aa a aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 1 ~5aaa =aaa );

for my $bad_user ( @bad_users ) {

    _reset();

    $sanity->check_username( 'username', $bad_user, $error );

    is ( $error->exists(), 1, "$bad_user passed to check_username() results in an ISP::Error being flagged" );
}

# check_password

print "\n# check_password()\n\n";

_reset();

my $check_pass_ret = $sanity->check_password( 'password', 'good_pw', $error );
is ( $check_pass_ret, 0, "check_password() returns 0 upon success" );
is ( $error->exists(), 0, "...and no error is set" );

my @bad_pass = qw ( aaa aaa. aaa/ aaa\ aaa& aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa );

for my $bad_pw ( @bad_pass ) {

    _reset();
    
    $sanity->check_password( 'pw', $bad_pw, $error );

    is ( $error->exists(), 1, "$bad_pw passed to check_password() results in an ISP::Error being flagged" );

}

# check_int

print "\n# check_int()\n\n";

_reset();

my $check_int_ret = $sanity->check_int( 'int', 290, $error );
is ( $check_int_ret, 0, "check_int() returns 0 upon success" );
is ( $error->exists(), 0, "...and no error is set" );


my @bad_ints = qw ( 4.1 a 1a1 4e2 19.62 % ! . -192.48 45-2 );

for my $bad_int ( @bad_ints ) {

    _reset();

    $sanity->check_int( 'int', $bad_int, $error );

    is ( $error->exists(), 1, "$bad_int passed to check_int() results in an ISP::Error being flagged" );
}

# check_hour

print "\n# check_hour()\n\n";

_reset();

my $check_hour_ret = $sanity->check_hour( 'hour', 11, $error );
is ( $check_hour_ret, 0, "check_hour() returns 0 on success" );
is ( $error->exists(), 0, "...and no error is set" );


my @good_hours = qw ( 1 5 911 10 15 100 300 112 22 222 0 999 );

for my $good_hour ( @good_hours ) {

    _reset();

    my $ret = $sanity->check_hour( 'un', $good_hour, $error );

    is ( $ret, 0, "$good_hour passed to check_hour() returns success" );
    is ( $error->exists(), 0, "...and no error is set" );


}

my @bad_hours  = qw ( -1 1.5 10.5 100.5 1000 a ! ~ % 45a 4a5 16. );

for my $bad_hour ( @bad_hours ) {

    _reset();

    $sanity->check_hour( 'hour', $bad_hour, $error );

    is ( $error->exists(), 1, "$bad_hour passed to check_hour() results in an ISP::Error being flagged" );
}

# check_decimal

print "\n# check_decimal()\n\n";

_reset();

my $check_decimal_ret = $sanity->check_decimal( 'decimal', '11.3', $error );
is ( $check_decimal_ret, 0, "check_decimal() returns 0 on success" );
is ( $error->exists(), 0, "...and no error is set" );


my @good_decimals = qw ( 1 15 100 300 0 999 2112 -1 1.5 10.5 100.5 16.0 16. -15 -15.1 -.2 );

for my $good_decimal ( @good_decimals ) {

    _reset();

    my $ret = $sanity->check_decimal( 'decimal', $good_decimal, $error );

    is ( $ret, 0, "$good_decimal passed to check_decimal() returns success" );
    is ( $error->exists(), 0, "...and no error is set" );


}

my @bad_decimals  = qw ( a ! ~ % 45a 4a5 -10.5b -x.5 -x5 x5 5.0.5 -50-5 5.05.5 );

for my $bad_decimal ( @bad_decimals ) {

    _reset();

    $sanity->check_decimal( 'decimal', $bad_decimal, $error );

    is ( $error->exists(), 1, "$bad_decimal passed to check_decimal() results in an ISP::Error being flagged" );
}

# check_date

print "\n# check_date()\n\n";

_reset();

my $check_date_ret = $sanity->check_date( 'date', '2009-08-12', $error );
is ( $check_date_ret, 0, "check_date() returns 0 on success" );
is ( $error->exists(), 0, "...and no error is set" );


my @good_dates = qw ( 2009-09-24 1969-12-31 2029-01-01 2012-02-29 );
push @good_dates, '';

for my $good_date ( @good_dates ) {

    _reset();

    my $ret = $sanity->check_date( 'date', $good_date, $error );

    is ( $ret , 0, "$good_date passed to check_date() returns success" );
    is ( $error->exists(), 0, "...and no error is set" );

}

my @bad_dates  = qw (   a ! ~ % 45a 4a5 -10.5b -x.5 -x5 x5 5.0.5 -50-5 5.05.5 
                        2009x08-12 2009-12x09 2009-09-121 20009-10-12 209-12-09
                        2009.08.12 2009-009-12 2009-09.16 x-x-x !-%-~ --- 
                        2009_12_08 2009:12:16 2009-12-16:00:00:00

                    );

for my $bad_date ( @bad_dates ) {

    _reset();

    $sanity->check_date( 'date', $bad_date, $error );

    is ( $error->exists(), 1, "$bad_date passed to check_date() results in an ISP::Error being flagged" );
}

{ # check email good

    _reset();

    my @good_addr = qw(
                steveb@cpan.org
                isp@example.com
                steve.bertrand@something.on.ca
                steve-bertrand@gmail.com
                steve_bertrand@example.com
            );

    for my $addr ( @good_addr ) {
        
        my $ret = $sanity->check_email( 'email', $addr, $error );
        
        is ( $ret , 0, "$addr passed to check_email() returns success" );
        is ( $error->exists(), 0, "...and no error is set" );
    }
}

{ # check email bad

    _reset();

    my @bad_addr = qw(
                stev!e@ibctech.ca
                steve@ibc!tech.ca
                s_b@.com
                s-b@?hello.com
                steve.telus.com
                justastring
                just_a_string
                bad*addr.com
                ste*ve@ibctech.ca
            );
    push @bad_addr, 'steve@ibctech#.ca';
    push @bad_addr, 'ste ve@ibctech.ca';

    for my $addr ( @bad_addr ) {
        _reset();
        $sanity->check_email( 'email', $addr, $error );
        is( $error->exists(), 1, "$addr passed to check_email() results in an ISP::Error being flagged" );
    }
}
