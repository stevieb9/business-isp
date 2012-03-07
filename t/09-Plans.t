#!/usr/bin/perl 

use strict;

use DBI;
use DBIx::Recordset;
use Data::Dumper;
use Cwd 'abs_path';

use Test::More qw(no_plan);

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

BEGIN {
  #
print "\n\nInit ******************\n\n";
  use_ok('Business::ISP::User');
  use_ok('Business::ISP::Sanity');
  use_ok('Business::ISP::Error');
}

my $user;
my $error;
my $plan_db;
my $result;
my %plan_info;

#
# PLANS
#

print "\n\nPlan Tests ****************************\n\n";

can_ok('Business::ISP::User', ('_init_plans'));
can_ok('Business::ISP::User', ('get_plans'));
can_ok('Business::ISP::User', ('get_plan'));
can_ok('Business::ISP::User', ('add_plan'));

{ # check for proper references

    _reset();

    $user = Business::ISP::User->new({ config => $conf, username => 'steveb' });

    my @plans   = $user->get_plans();
    my $planref     = $plans[0];

    isa_ok (\@plans,   'ARRAY', "A ref taken of get_plans() return," );
    isa_ok ($planref, 'HASH' , "The first element of ${\(ref $user)}->get_plans() returned array is a reference, and");

}

{ # check for proper return with and without valid id

    _reset();

    my $plan = $user->get_plan( 1 );
    isa_ok ($plan, 'HASH', "The ${\(ref $user)}->get_plan(1) return value");

    $plan = $user->get_plan(0);
    is ( $plan, undef, "get_plan() returns undef when an invalid plan_id is supplied" );

}

#
# get_plans for user with no plans
#

{ # check for no plans

    _reset();

    my $plan_user = Business::ISP::User->new({ config => $conf, username => 'noplan' });
    my @no_plans    = $plan_user->get_plans();
    my $no_planref  = $no_plans[0];

    is ( @no_plans, 0, "get_plans() returns an empty array if the user has no plans" );
    isa_ok (\@no_plans,   'ARRAY', "A ref taken of get_plans() return," );
    is ( $no_planref, undef, "if the user has no plans, the first plan in the empty array is undef" );
}



#
# _init_plans
#

{ # test _init_plans() return value

    _reset();

    $user = Business::ISP::User->new({ config => $conf, username => 'steveb' });
    my $init_plans_ret = $user->_init_plans();
    is ( $init_plans_ret, 0, "_init_plans() returns 0 upon success" );

}
    
print "\nTest Plan Addition API calls\n\n";

{

    _reset();

    $user  = Business::ISP::User->new({ config => $conf, username => 'steveb' });
    my $error = Business::ISP::Error->new({ config => $conf }); 
    my %plan_info;

    # No params at all

    eval { $user->add_plan() } ;
    like (  $@,
        '/Bad API/',
        "${\(ref $user)}->add_plan() is terminated by " .
        "Business::ISP::Error->bad_api() when no parameters are passed in"
      );


    _reset();

    # bad api

    eval { $user->add_plan({ plan_info => \%plan_info }) } ;

    like (  $@, 
        '/Bad API/', 
        "${\(ref $user)}->add_plan() is terminated by " .
        "Business::ISP::Error->bad_api() if an Business::ISP::Error is not passed in" 
    );

    # Bad Data Type

    _reset();
    
    undef %plan_info;
    %plan_info = ( this => 'that', these => 'those', );

    eval { $user->add_plan({ plan_info => \%plan_info, error => $error }) } ;
    like (  $@,
        '/invalid attributes/',
        "${\(ref $user)}->add_plan() is terminated by Business::ISP::Error->bad_data() if " .
        "the plan_info data does not conform to the defined type in Business::ISP::Vars"
     );

}

print "\nTest individual plan fields for add_plan()\n\n";

# valid

{

    _reset();

    my $return;

    eval { $return = $user->add_plan({ plan_info => \%plan_info, error => $error }) };
    ok ( $@ eq '', "Valid data and API call to ${\(ref $user)}->add_plan() doesn't die" );
    
    is ( $return, 0, "Valid data and API call to ${\(ref $user)}->add_plan() returns 0" );
    undef $@;   
}

_reset();


{ # bad id

    _reset();

    $plan_info{id} = 65564;

    eval { $user->add_plan({ plan_info => \%plan_info, error => $error }) } ;
    like (  $@,
        '/id field must be empty/',
        "${\(ref $user)}->add_plan() is terminated by Business::ISP::Error->bad_data() if " .
        "the plan_info data tries to set the id field."
     );

}

print "\nTesting the 'hours' field\n\n";

{ # good hours

    _reset();

    my @good_hours = qw( 0 25 50 100 300 );

    for (@good_hours) {
        $plan_info{hours} = $_;
        is ($user->add_plan({ plan_info => \%plan_info, error => $error }), 0, "$_ in the hours field returns success" );
    }
}

{ # bad hours

    _reset();
    
    my @bad_hours = qw ( a x $ 8p p8 $8 9999 &&& hello %hash );

    for (@bad_hours) {
        $plan_info{hours} = $_;
        my $return = $user->add_plan({ plan_info => \%plan_info, error => $error });
        isa_ok ( $return, 'Business::ISP::Error', "$_ in the hours field, the return" );
        _reset();
    }
}

{ # login_name

    print "\nTesting good login_name\n\n";

    _reset();

    my @good_login = ( 'steveb', '44234', 's_4_8', 'abcdefghijklmnopqrstuvwxyz123456789012345678', );

    $plan_info{login_name} = '';
    is ($user->add_plan({ plan_info => \%plan_info, error => $error }), 0, "' ' in the login_name field returns success" );

    for (@good_login) {
        _reset();
        $plan_info{login_name} = $_;
        is ($user->add_plan({ plan_info => \%plan_info, error => $error }), 0, "$_ in the login_name field returns success" );
    }

    print "\nTesting bad login_name\n\n";

    _reset();

    my @bad_login_chars = qw( a! a@ a$ a% a^ a& a* a( a) a- a= a+ a~ a\ a| a} a] a{ a[ a. );
    push @bad_login_chars, ( 'a#', 'a,' );
    my @bad_login_words = ( 'this that', '888*', 'abcdefghijklmnopqrstuvwxyz1234567890123456789', 'a', );
    my @bad_login = (@bad_login_chars, @bad_login_words);

    for (@bad_login) {
        _reset();
        $plan_info{login_name} = $_;
        my $return = $user->add_plan({ plan_info => \%plan_info, error => $error });
        isa_ok ( $return, 'Business::ISP::Error', "$_ in the login_name field, the return " );
    }
}

# new validate_data() in Sanity

_reset();
is ($user->add_plan({ plan_info => \%plan_info, error => $error }), 0, "plan_info data is a plan_info type" );

print "\nTesting modify_plan_expiry()\n\n";

{
    _reset();

    $result
        = $plan_db->modify_plan_expiry({
                            error       => $error,
                            id          => 1,
                            quantity    => 2,
                        });

    like ( $result, qr/\d{4}-\d{2}-\d{2}/, "modify_plan_expiry() returns a new date when all params are valid" );
}

{
    _reset();

    my $result
        = $plan_db->modify_plan_expiry({
                            error       => $error,
                            id          => 2,
                            quantity    => 2,
                        });
    is ( $result, 1, "Business::ISP::User->modify_plan_expiry()returns 1 if the plan has no expiry date" ); 

}

{

    _reset();

    $result
        = $plan_db->modify_plan_expiry({
                            error       => $error,
                            id          => 1,
                            quantity    => 'a',
                        });
    is ( $result, 1, "Business::ISP::User->modify_plan_expiry() returns 1 if quantity is not an integer" ); 

}

{
    _reset();
    
    my $subtract_plan_hours = $plan_db->plan_hours({
                        error       => $error,
                        id          => 2,
                        quantity    => -50,
                    });
    is ( $subtract_plan_hours, -50, "plan_hours properly subtracts the negative number of hours" );
}

{
    _reset();

    my $new_plan_hours = $plan_db->plan_hours({
                        error       => $error,
                        id          => 2,
                        quantity    => 50,
                    });
    is ( $new_plan_hours, '-150', "adding 50 hours to an account with -100 already is -150" );
}

{ # adding char to plan_hours()
    _reset();
    
    my $new_plan_hours = $plan_db->plan_hours({
                        error       => $error,
                        id          => 2,
                        quantity    => 'asdf',
                    });
    is ( $new_plan_hours, 1, "adding 'asdf' hours to an account with 50 already returns 1 (failure)" );
}


{ # get_client_list

    _reset();

    my $client_db = Business::ISP::User->new({ config => $conf });

    my @get_client_list_ret = $client_db->get_client_list();
    isa_ok ( \@get_client_list_ret, 'ARRAY', "taking a ref of the get_client_list() return is" );
}

{ # delete_plan with no id

    _reset();

    my $del_plan_ret = $user->delete_plan();
    is ( $del_plan_ret, 1, "delete_plan() returns 1 if no id is passed in" );
}

{ # delete_plan


    _reset();

    # we need a temporary user here, or else the notes subsystem will barf

    my $del_user = Business::ISP::User->new({ config => $conf, username => 'steveb' });

    my $del_id = $del_user->get_plan();

    my $del_plan_ret = $del_user->delete_plan( $del_id );
    is ( $del_plan_ret, 0, "delete_plan() returns 0 on completion" );
}

{ # delete plan undef

    _reset();

    my $del_id = 0;

    my $del_plan_ret = $user->delete_plan( $del_id );
    is ( $del_plan_ret, 1, "delete_plan() returns 1 if the plan is not found" );

}


{ # get_plan_ids

    _reset();

    $user->build_db_user( 'steveb' );

    my @ids = $user->get_plan_ids();

    isa_ok( \@ids, 'ARRAY', "get_plan_ids() return" );

    ok( $ids[0] =~ m{ \A \d+ \z }xms, "get_plan_ids returns an array of integers");
}

{ # plan_members

    _reset();

    my $plan_members = $user->plan_members({ plan_name => 'pland' });

    isa_ok( $plan_members, 'ARRAY', "deref of plan_members() return" );

    my $plan_members_ids = $user->plan_members({ plan_name => 'goldendsl', return_id => 1 });

    isa_ok( $plan_members_ids, 'ARRAY', "deref of plan_members( return_id ) return" );

    ok( $plan_members_ids->[0] =~ m{ \d+ }xms, "plan_members returns an int when returning by ids" );   
}
sub _clean {

    undef %plan_info;
    undef $user;
    undef $error;
    undef $plan_db;
    undef $result;
}

sub _reset {

    _clean();

    $user  = Business::ISP::User->new({ config => $conf });
    $plan_db = Business::ISP::User->new({ config => $conf });
    $error = Business::ISP::Error->new({ config => $conf });
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
          'hours_balance' => 0,
          'classification' => '',
      );
}
