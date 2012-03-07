#!/usr/bin/perl 

use strict;

#
# bug 49 test
#
# ISP::Error
#

# This bug refers to a situation where render_gui_data() would
# exponentially grow the @data for each hashref put into it


use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print <<EOT;

bug 49 test

If more than one hashref of data is stashed onto \$error->data(), we want to ensure
that it doesn't get rendered exponentially by the gui.

EOT

print "\n\n***** Init *****\n\n";
  use_ok('ISP::Sanity');
  use_ok('ISP::Vars');
  use_ok('ISP::Error');

my $sanity;
my $vardb;
my $error;

sub _clean {

    undef $vardb;
    undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

    $vardb  = ISP::Vars->new();
    $sanity = ISP::Sanity->new();
    $error  = ISP::Error->new();
}

sub _nothing{} # placeholder

_reset();

#
# error
#

{

    for my $count ( 1..3 ) {

        $error->add_message( "This is msg $count" );
        $error->data( { $count => $count } );
        $error->add_trace();

    }

    my %gui_data = $error->render_gui_data();

    my $data_count  = scalar ( @{ $gui_data{ DATA } } );
    my $msg_count   = scalar ( @{ $gui_data{ MESSAGES } } );
    my $trace_count = scalar ( @{ $gui_data{ STACK } } );

    is ( $data_count,   3, "when Error has three data elements, so does the gui data" );
    is ( $msg_count,    3, "when Error has three message elems, so does the gui data" );
    is ( $trace_count,  4, "when Error is called directly, it contains one additional stack entry" );


}
