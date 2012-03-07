#!/usr/bin/perl 

use strict;

#
# bug 75 test
#
# ISP::User
#

# This bug refers to an issue in that the username in an account
# can be different from the login_name that a plan contains,
# which would be the one used to authenticate to the RADIUS server
# with, essentially rendering bandwidth/time based checks from
# coming up empty

use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print <<EOT;

bug 75 test

If a client's username is different than one of their plan's login name, we
need to temporarily put the login_name into the username for RADIUS checks.

EOT

print "\n\n***** Init *****\n\n";

use ISP::User;

my $user;

sub _clean {

	undef $user;
}

sub _reset {

    _clean();

	$user = ISP::User->new({ username => 'steveb' });
}

sub _nothing{} # placeholder

_reset();

#
# error
#

{

	my $plan	= $user->get_plan( 1 );

	$plan->{ login_name } = 'mike';
	
	my $real_username = $user->username();

	my $changed_username = $user->username_to_login( $plan, $real_username );

	ok( $changed_username eq 'mike', "when username and login_name differ, the username is changed temporarily" );

	$plan->{ login_name } = '';

	$changed_username = $user->username_to_login( $plan, $real_username );

	print "$real_username, $changed_username\n";
	ok ( $changed_username eq 'steveb', "if a login name is blank, we retain the original username" );

	$plan->{ login_name } = '';
}
