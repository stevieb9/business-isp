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
  use_ok('ISP::User');
  use_ok('ISP::Sanity');
  use_ok('ISP::Vars');
  use_ok('ISP::Error');
#  use_ok('ISP::GUI::Accounting');

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

    $user  	= ISP::User->new({ username => 'steveb' });
	$vardb	= ISP::Vars->new();
	$sanity	= ISP::Sanity->new();
    $error 	= ISP::Error->new();
#	$gui	= ISP::GUI::Accounting->setup();
}

_reset();
