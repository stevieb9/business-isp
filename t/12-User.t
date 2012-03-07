#!/usr/bin/perl

use strict;

use DBI;
use DBIx::Recordset;
use Data::Dumper;
use Cwd qw( abs_path );

use Test::More qw(no_plan);

BEGIN {
  #
  use_ok('ISP::User');
  use_ok('ISP::Sanity');
  use_ok('ISP::Error');
}

my $user = undef;
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

#
# Initialization
#

print "\n\nInitialization ******************\n\n";

can_ok('ISP::User', ('new'));

{ # is $user an ISP::User obj

    my $user = ISP::User->new({ config => $conf });
    isa_ok($user, 'ISP::User');
}

{ # is also an Ojbect
    
    my $user = ISP::User->new({ config => $conf });
    isa_ok($user, 'ISP::Object');
}

{ # can initialize with a username
    
    my $user = ISP::User->new({ config => $conf, username => 'steveb' });
    is ($user->username(), 'steveb', "${\(ref $user)}->new({ username => 'steveb' }) can initialize an object given a username parameter");
}

{ # undef with bad username
    
    my $user = ISP::User->new({ config => $conf, username => 'asdf' });
    is ($user->username(), undef, "${\(ref $user)}->new({ config => $conf }) returns undef if given an invalid username parameter");
}

{ # can build a user manually/properly

    my $user = ISP::User->new({ config => $conf });
    can_ok ('ISP::User', ('build_db_user'));

    my $build_user_ret = $user->build_db_user('steveb');
    is ( $user->username(), 'steveb', "${\(ref $user)}->build_db_user('steveb') properly initializes an object");
    is ( $build_user_ret, 0, "build_db_user() returns 0 upon success" );
}

{ # manual build returns undef with bad username
    
    my $user = ISP::User->new({ config => $conf });
    $user->build_db_user('asdf');
    is ($user->username(), undef, "${\(ref $user)}->build_db_user() returns undef if given an invalid username parameter");
}

#
# RW Accessors
#

{
    print "\nAccessor Tests ********************\n\n";
    my $user = ISP::User->new({ config => $conf });

    my @rw_attrs = qw (
                   tax_exempt
                   billing_first_name
                   billing_last_name
                   billing_address1
                   billing_address2
                   billing_town
                   billing_province
                   billing_postal_code
                   home_phone
                   work_phone 
                   fax
        );

    print "\nTest rw accessors for read...\n\n";
    for (@rw_attrs) { can_ok  ($user, $_); }

    print "\nTest rw accessors for write...\n\n";
    for (@rw_attrs) { is ($user->$_('test'), 'test', "$_:  accessor is rw"); }
}

#
# RO Accessors
#

{
    
    my $user = ISP::User->new({ config => $conf });

    my @ro_attrs = qw (
           username
          );

    print "\nTest ro accessors for read...\n\n";
    for (@ro_attrs) { can_ok ($user, $_); }

    print "\nTest ro accessors for write...\n\n";
    for (@ro_attrs) { is ($user->username('mattr'), undef, "${\(ref $user)}-> ${_} is read only"); }

}

SKIP: {
    
    eval { require ISP::RADIUS };
    skip "ISP::RADIUS not installed" if $@;

    { # get_monthly_login_totals
    
        can_ok( 'ISP::User', 'get_monthly_login_totals' );
    
        my $user = ISP::User->new({ config => $conf, username => 'steveb' });
        my $plan = $user->get_plan( 1 );

        my $stats = $user->get_monthly_login_totals({
                                    plan => $plan,
                                });

        isa_ok ( $stats, 'ARRAY', "get_monthly_login_totals() return" );
        isa_ok ( $stats->[0], 'HASH', "get_monthly_login_totals() element" );
    }


    #
    # radius_password();
    #

    { 
        my $user    = ISP::User->new({ config => $conf, username => 'steveb' });
        my $orig_pw = $user->radius_password();

        ok( $orig_pw eq 'verb4mm', "radius_password returns the user's pw" );

        my $new_pw  = 'testing';
        my $cur_pw  = $user->radius_password({ password => $new_pw });

        ok( $new_pw ne $orig_pw, "radius_password called with password param changes the pw" );
        ok( $cur_pw eq $new_pw,  "radius_password called with password param properly sets the new pw" );

        my $last_pw = $user->radius_password({ password => $orig_pw });
        ok ( $last_pw eq $orig_pw, "radius_password can reset the password back to original" );
    }

} # end skip no ISP::RADIUS

#
# plan_password()
#

{
    my $user    = ISP::User->new({ config => $conf, username => 'steveb' });
    my $cur_pw  = $user->plan_password();

    # no plan_id supplied
    is ( $cur_pw, 1, "plan_password() will return 1 if you forgot the plan_id param" );

    # change pw
    my $new_pw  = 'testing';
    $user->plan_password({ plan_id => 2, new_password => $new_pw });

    # good plan_id returns pw
    $cur_pw     = $user->plan_password({ plan_id => 2 });

}

#
# add_client() to ensure no dup usernames are allowed to be entered
#

{
    my $clientdb    = ISP::User->new({ config => $conf });

    my $user = {

          home_phone => '905-885-5363',
          billing_address1 => '101 Phillips Rd',
          shipping_address2 => '',
          billing_company_name => '',
          shipping_address1 => '101 Phillips Rd',
          last_update => '0000-00-00',
          shipping_email_address => 'isp@example.com',
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
          fax_phone => '',
    };  
    
    my $error       = ISP::Error->new({ config => $conf });

    $clientdb->add_client({
                        error       => $error,
                        client_info => $user,
                    });

    is( $error->exists(), 1, "add_client() will not create a client record if the username is already in the db" );
}

{ # bug 208 - client_info() not updating the db

    can_ok( 'ISP::User', 'client_info' );

    my $user = ISP::User->new({ username => 'steveb' });

    my $client_info = $user->client_info();

    my $orig = $client_info->{ tax_exempt };

    $client_info->{ tax_exempt } = ( $client_info->{ tax_exempt } =~ /y/i )
        ? 'N'
        : 'Y';

    my $updated_info = $user->client_info({ client_info => $client_info });

    my $new = $client_info->{ tax_exempt };

    ok( $orig ne $new, "client_info() properly sets updated parameters" );

    $client_info->{ tax_exempt } = $orig;

    $user->client_info({ client_info => $client_info });

    my $orig_info = $user->client_info();

    my $orig_var  = $orig_info->{ tax_exempt };

    ok( $orig eq $orig_var, "...and reverts it back again" );

    # check ISP::Error failure (die)

    $client_info->{ blah } = 'blah';

    eval {
        $user->client_info({ client_info => $client_info });
    };

    like (  $@,
            '/has invalid attributes/',
            "client_info() dies via ISP::Error if Sanity checks fail on the incoming data"
    );
}
