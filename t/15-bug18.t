#!/usr/bin/perl

use strict;

use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
    use_ok( 'ISP::Sanity' );
    use_ok( 'ISP::Error' );

# Declarations go here

my $sanity;
my $error;

print <<EOT;

bug 18

ISP::Sanity check_username() allows an underscore as its first character (and it shouldn't)

EOT

sub _clean {
 
    undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

    $sanity = ISP::Sanity->new();
    $error  = ISP::Error->new();
}

# Tests go below _nothing();

sub _nothing {} # placeholder for vim folds. Tests below...

{
    _reset();

    my $un_ret = $sanity->check_username( 'un', '_aaaaa', $error );

    is ( $un_ret, 1, "Sanity check_username() notes a problem and returns 1 " .
                     "when a username preceeded with _ is passed in, and all " .
                     "other checks have passed"
        );


}
