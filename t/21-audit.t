#!/usr/bin/perl 

use strict;

# Business::ISP::Sanity::audit()

use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print <<EOT;

Test for the audit() method in Business::ISP::Sanity

EOT

print "\n\n***** Init *****\n\n";

use Business::ISP::Sanity;
use Business::ISP::Object;

my $sanity;
my $schema;
my $rs;

sub _clean {

    undef $sanity;
}

sub _reset {

    _clean();

    $sanity     = Business::ISP::Sanity->new();
    $schema     = $sanity->schema();
    $rs     = $schema->resultset( 'Audit' );
}

sub _nothing{} # placeholder

_reset();

#
# 
#
$rs->delete();

{ # successful run, not logged
    
    my $res = $sanity->audit({
                process     => 'plana_deduction',
                operator    => 'system',
                runtype     => 'auto',
            });

    ok( $res == 0, "audit() returns 0 if a process has not run during current cycle" );

}

{ # die with error if process has run this cycle

    $sanity->audit({
                process     => 'plana_deduction',
                complete    => 1,
            });

    eval {
            $sanity->audit({
                    process => 'plana_deduction',
                });
    };

    like (  $@,
            '/has already run its/',
            "audit() dies via Business::ISP::Error if trying to run a process more than once per cycle"
    );

    $rs->delete;
}

{ # return is 1 if everything goes smoothly

    my $res = $sanity->audit({ 
                process     => 'plana_deduction',
                complete    => 1,
                operator    => 'system',
                runtype     => 'auto',
            });

    ok( $res == 1, "completed audit returns true(1) if all params are correct" );
    
    $rs->delete;
}

{ # error on unknown process

    eval {
            $sanity->audit({
                    process => 'unknown',
                });
    };

    like (  $@,
            '/Can not perform an audit on unknown process/',
            "audit() dies via Business::ISP::Error if an unknown process name is passed in"
    );
}

{ # error if db can't be written to

    eval {
            $sanity->audit({
                    process     => 'plana_deduction',
                    complete    => 1,
                    test        => 1,
                });
    };

    like (  $@,
            '/audit process could not log that/',
            "audit() dies via Business::ISP::Error if the audit log could not be written to the db"
    );

    $rs->delete;
}


