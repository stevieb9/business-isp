#!/usr/bin/perl

use strict;

use Test::More qw(no_plan);

{ # ver check test
    my $ver = '0.13_02';
    ok ( $ver =~ /_\d+$/, "devel platform will be identified correctly" );
}
