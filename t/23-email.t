#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw( no_plan );

use_ok('Business::ISP::Object');
use_ok('Business::ISP::Email');
use Business::ISP::Object;
use Business::ISP::Email;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

can_ok( 'Business::ISP::Email', ('new'));
can_ok( 'Business::ISP::Email', ('email'));

my $template = 't/test_email.tpl';

{ # send one

    my $snd = Business::ISP::Email->new();

    $snd->email({
                subject => 'System check',
                tmpl    => $template,
                to      => 'steve.bertrand@gmail.com',
                data    => {
                            test => 'test',
                            sender => 'stevieb'
                        },
            });
}
