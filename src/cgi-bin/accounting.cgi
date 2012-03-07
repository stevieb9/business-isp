#!/usr/bin/perl

use warnings;
use strict;
use Business::ISP::GUI::Accounting;
use CGI::HTMLError trace => 1;
use HTML::Menu::Select qw( menu options );

use DBI;

my $accounting_gui = Business::ISP::GUI::Accounting->new();

$accounting_gui->function_orders();

$accounting_gui->setup();

$accounting_gui->run();

# below is the debug rendering code
# it may be an idea to put it into C::A::post_run()

if ( $accounting_gui->RENDER_CODEFLOW() && ! $accounting_gui->DISABLE_ALL_CODE_DEBUG() ) {
    my @codeflow = $accounting_gui->GET_CODEFLOW();
    print "<table>";

    for my $call (@codeflow) {
        print "<tr><td>$call</td></tr>";
    }
    print "</table>";
}

if ( $accounting_gui->RENDER_STACK_TRACING() && ! $accounting_gui->DISABLE_ALL_CODE_DEBUG() ) {

    my @stack = $accounting_gui->GET_STACK_TRACING();
    my $stack_layer = 0;

    print "<br>--------------------<br><br>";

    for my $trace (@stack) {

        print "Trace Number: $stack_layer<br><br>";
            print "<table>";

        while ( my ($key, $value) = each (%$trace)) {
            print "<tr><td><font size=2>$key</font></td><td><font color=white>blank</font></td><td><font size=2>$value</font></td></tr>";
        }

        print "</table><br><br>";       
        $stack_layer++;
        }

}

exit(0);
