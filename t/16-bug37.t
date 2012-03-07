#!/usr/bin/perl 

use strict;
use Test::More qw(no_plan);

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** bug 37 -- add in session support *****\n\n";

use_ok('CGI::Application::Plugin::Session');
use_ok('Business::ISP::GUI::Accounting');

sub _clean {
}
sub _reset {

    _clean();

}

sub _nothing{} # placeholder for tests

can_ok ( 'Business::ISP::GUI::Accounting', 'session' );
