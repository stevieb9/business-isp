#!/usr/bin/perl

use warnings;
use strict;

use DBI;
use DBIx::Recordset;
use Data::Dumper;
use ISP::User;
use ISP::Conversion;

my %arg_table = (

        '--plans'           => \&plans,
        '--uledger'         => \&uledger,
        '--gledger'         => \&gledger,
        '--clients'         => \&clients,
        '--plan_passwords'  => \&plan_passwords,
    );

my $convert = \%arg_table;

my @allowed_args = keys %arg_table;

if ( ! defined $ARGV[0] || $#ARGV > 1 ) {

    print "\n" .
          "You must supply one of:\n\n" .
          "${\( join \"\n\", @allowed_args ) }" .
          "\n\n";
    exit;
}
              
my $item_to_translate = $ARGV[0];

# call the requested conversion function

$convert->{$item_to_translate}();


# define the functions

sub plans {
    my $translator = ISP::Conversion->new();
    $translator->plans_inf_to_db();
}
sub clients { 
    my $translator = ISP::Conversion->new();
    $translator->client_inf_to_db();
}
sub gledger {
    my $translator = ISP::Conversion->new();
    $translator->gledger_inf_to_db( 2009 );
}   
sub uledger {
    my $translator = ISP::Conversion->new();
    $translator->uledger_inf_to_db( 2009 );
}   
sub plan_passwords {
    my $translator = ISP::Conversion->new();
    $translator->current_plan_password_to_db();
}
