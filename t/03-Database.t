#!/usr/bin/perl

use strict;

use Test::More qw(no_plan);
use Data::Dumper;
use Cwd qw( abs_path );

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

use_ok('ISP::Object');
use_ok('ISP::Database');
use_ok('ISP::Replicated');

my $obj = ISP::Object->new({ config => $conf });

my $schema = $obj->schema(); 

{
    my $notes = $schema->resultset( 'Notes' )->find( 1 );
    ok( $notes->id() == 1, "id 1 of Notes using DBIx::Class is 1" );
}
