#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw( no_plan );

use_ok('Business::ISP::Object') ;
can_ok( 'Business::ISP::Object', 'date' );

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

{ #date bad param

    my $obj = Business::ISP::Object->new();

    eval { $obj->date( { get => 'that' } ) };

    like( $@, qr/parameter must be/, "date() dies if the get param is incorrect" );
}

{ # date() 
    
    my $obj = Business::ISP::Object->new();

    my $ret = $obj->date();
    
    isa_ok( $ret, 'DateTime', "calling date() with no params, return" );
}

{ # date() get param

    my $obj = Business::ISP::Object->new();
    my $ret = $obj->date({ get => 'month' });
    ok( $ret =~ m{ \A \d{4}-\d{2} \z }xms, "called with get=>month works out ok" );
}

{ # timezone checks

    my $obj = Business::ISP::Object->new();

    $obj->TIMEZONE( 0 );
    eval { my $ret = $obj->date({ get => 'month' }) };
    isnt ( $@, undef, "If the timezone isn't set correctly, we die" );
}

{ # with datetime sent in

    my $obj = Business::ISP::Object->new();

    my $datetime = DateTime->now( time_zone => $obj->TIMEZONE() )->subtract( days => 1);

    my $ret = $obj->date({ get => 'day', datetime => $datetime });

    ok( $ret =~ m{ \d{4}-\d{2}-\d{2} }xms, "obj->date() does the right thing if a DateTime obj is passed in" );
}

{ # string_to_date()

    my $o = Business::ISP::Object->new();

    my $date = "Dec 31, 2009";

    my $ret = $o->string_to_date( $date );

    print "$ret\n\n";

    ok( $ret eq '2009-12-31', "string_to_date() seems to follow the legacy plan expires layout... Dec 31, 2009" );
}
