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
  use_ok('Business::ISP::User');
  use_ok('Business::ISP::Sanity');
  use_ok('Business::ISP::Vars');
  use_ok('Business::ISP::Error');
#  use_ok('Business::ISP::GUI::Accounting');

my $user;
my $sanity;
my $vardb;
my $error;
my $gui;

sub _clean {
 
    undef $user;
    undef $sanity;
    undef $error;
    undef $gui;
}

sub _reset {

    _clean();

    $user   = Business::ISP::User->new({ username => 'steveb' });
    $vardb  = Business::ISP::Vars->new();
    $sanity = Business::ISP::Sanity->new();
    $error  = Business::ISP::Error->new();
#   $gui    = Business::ISP::GUI::Accounting->setup();
}

_reset();
