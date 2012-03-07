#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw( no_plan );

use_ok('Business::ISP::Object');
use_ok('Business::ISP::Billing');

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

{ # inv

    my $bill = Business::ISP::Billing->new();

    $bill->email_bill({ invoice => 2 });

}

{ # renewal notice

    my $bill    = Business::ISP::Billing->new();

    $bill->renewal_notice({ account_type => 'month' });
}
