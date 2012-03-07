#!/usr/bin/perl

use strict;

use Test::More qw(no_plan);

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";

    use_ok( 'Business::ISP::Sanity' );
    use_ok( 'Business::ISP::Error' );

# Declarations go here, but defs in the 'maintenance' area

my $sanity;
my $error;

# Maintenance subs go here

sub _clean {
 
    undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

    $sanity = Business::ISP::Sanity->new();
    $error  = Business::ISP::Error->new();
}

# Tests go below _nothing();

sub _nothing {} # placeholder for vim folds. Tests below...

#
# bug 17
# - Business::ISP::Sanity check_username() apparently allows ''
#   in the regex check
#

{ # check against empty string in Sanity check_username()

    _reset();

    my $username = '';

    my $return = $sanity->check_username( 'un', $username, $error );

    is ( $return, 1, "Business::ISP::Sanity check_username does not allow the empty string as a param" );
}
