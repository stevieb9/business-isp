#!/usr/bin/perl

use strict;

use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
  use_ok( 'WWW::Mechanize' );
  use_ok( 'Business::ISP::Object' );

my $mech;
my $obj;

sub _clean {
 
    undef $mech;
    undef $obj;
}

sub _reset {

    _clean();

    $obj = Business::ISP::Object->new();
    $mech = WWW::Mechanize->new();
}

sub _nothing{} # placeholder


#
# test the main page
#


{

    _reset();

    my $url = $obj->ACCT_APP();

    $mech->get( $url );

    like (  $mech->content(),
            qr/Operator Name:/,
            "login() run_mode requests a username"
        );

    like (  $mech->content(),
            qr/Password:/,
            "login() run_mode requests an operator"
        );

    $mech->submit_form(
        form_number => 1,
        fields      => {
                operator => 'ssssssssssssssssssssssixxxxxxxxxeve',
                password => '',
            }
    );

    like (  $mech->content(),
            qr/Error messages:/,
            "A bad operator id in login() results in an Error"
        );

}
