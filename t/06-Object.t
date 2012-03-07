#!/usr/bin/perl

use strict;
#use diagnostics;

use DBI;
use DBIx::Recordset;
use Cwd 'abs_path';

use Test::More qw(no_plan);
use Data::Dumper;
use ISP::Sanity;
use ISP::Vars;
use ISP::Error;

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
  use_ok('ISP::Object');

can_ok ( 'ISP::Object', 'new' );  
can_ok ( 'ISP::Object', 'configure' );  
can_ok ( 'ISP::Object', 'function_orders' );  
can_ok ( 'ISP::Object', 'build_stack' );  
can_ok ( 'ISP::Object', 'db_handle' );  
can_ok ( 'ISP::Object', 'dsn' );  
can_ok ( 'ISP::Object', 'tax_rate' );  
can_ok ( 'ISP::Object', 'bank_info' );  
can_ok ( 'ISP::Object', 'full_date' );  
can_ok ( 'ISP::Object', 'string_date' );  
can_ok ( 'ISP::Object', 'string_to_date' );  
can_ok ( 'ISP::Object', 'storeit' );  
can_ok ( 'ISP::Object', 'DESTROY' );  

# definitions

my @constant_subs = qw (
                    UNDEF
                    CAPTCHA_LENGTH
                    BANK_TEST_MODE
                    ENABLE_BANK_PROCESSING
                    TEMPLATE_DIR
                    CONFIG_DIR
                    CURRENT_CONFIG_FILE
                    ACCT_APP
                    HTML_MANUAL_LOCATION
                    SOURCE_REPO_LINK
                    IN_TEST_MODE
                    GST
                    PST
                    VERSION
                    DISABLE_ALL_CODE_DEBUG
                );

my @dispatch_subs = qw (
                    CODEFLOW
                    GET_CODEFLOW
                    STACK_TRACING
                    GET_STACK_TRACING
                    MASTER_DISPATCH
                );
    
my $obj;
my $sanity;
my $error;

{ # test use
    
    _reset();

    for my $const_sub ( @constant_subs ) {
        can_ok ( 'ISP::Object', $const_sub );
    }

    for my $dispatch_sub ( @dispatch_subs ) {
        can_ok ( 'ISP::Object', $dispatch_sub );
    }
}

{ # test accessors

    _reset();

    my $bad_ret = $obj->UNDEF();
    is ( $bad_ret, undef, "If the config file can't be read, the subs created from it return undef" );

    if ( -e './src/conf/ISP.conf' ) {

        for my $config_sub ( @constant_subs ) {

            next if $config_sub eq 'UNDEF';
    
            my $ret = $obj->$config_sub();
            isnt ( $ret, undef, "If the config is read, and all [Constant]s have values, generated subs don't return undef" );
        }
    }
}

{ # configure

    _reset();

    my $config_ret = $obj->configure();
    is ( $config_ret, 0, "configure() returns 0 upon success" );

    my $env_conf = $ENV{'ISP_CONFIG'};

    $ENV{'ISP_CONFIG'} = 'bad_file';

    my $bad_config_ret = $obj->configure();
    is ( $bad_config_ret, 1, "configure() returns 1 if the config file can't be found" );
    
    $ENV{'ISP_CONFIG'} = $env_conf;
}

{ # db_handle

    _reset();

    my $test_dbh = $obj->db_handle();

    isa_ok ( $test_dbh, 'HASH', "db_handle() returns a hash ref as expected. Return" );
}

{ # dsn

    _reset();

    my %test_dsn = $obj->dsn();

    isa_ok ( \%test_dsn, 'HASH', "Return of dsn() is a hash as expected. Return" );

    is ( $test_dsn{ '!Table' }, undef, "The DSN has an undefined !Table field if dsn() isn't called with a param" );

    my %test_dsn_table = $obj->dsn({ table => 'table' });

    is ( $test_dsn_table{ '!Table' }, 'table', "When called with 'table' as a param, dsn() has the !Table field properly set" );
}

{ # tax_rate hst  

    _reset();

    my $tax_rate_ret = $obj->tax_rate( 'hst' );

    is ( $sanity->check_decimal( 'tax', $tax_rate_ret, $error ), 
         0,
         "tax_rate('hst') returns a decimal",
    );

    ok( $tax_rate_ret == .13, "HST tax rate is .13" );
}

{ # tax_rate gst  

    _reset();

    my $tax_rate_ret = $obj->tax_rate( 'gst' );

    is ( $sanity->check_decimal( 'tax', $tax_rate_ret, $error ), 
         0,
         "tax_rate('gst') returns a decimal",
    );

    ok( $tax_rate_ret == .05, "GST tax rate is .05" );

}

{ # tax_rate pst

    _reset();

    my $tax_rate_ret = $obj->tax_rate( 'pst' );

    is ( $sanity->check_decimal( 'tax', $tax_rate_ret, $error ), 
         0,
         "tax_rate('pst') returns a decimal",
    );

    ok( $tax_rate_ret == .08, "PST tax rate is .08" );

}

{ # tax_rate none

    _reset();

    my $no_tax_rate_ret = $obj->tax_rate();
    is ( $no_tax_rate_ret, undef, "tax_rate() returns undef if a tax type is not passed in" );
}

{ # tax_rate bad
    
    _reset();

    my $bad_tax_rate_ret = $obj->tax_rate( 'blah' );
    is ( $bad_tax_rate_ret, undef, "tax_rate() returns undef if an unknown tax type is passed in" );
}

{ # tax_rate calculations
    
    _reset();

    my $pst_ret = $obj->tax_rate( 'pst' );
    my $gst_ret = $obj->tax_rate( 'gst' );

    my $pst_tot = ( $pst_ret + 1 );
    my $gst_tot = ( $gst_ret + 1 );

    ok ( $pst_tot > 1, "PST + 1 increments the total correctly" );
    ok ( $gst_tot > 1, "GST + 1 increments the total correctly" );

    my $tax_tot = ( $gst_ret + $pst_ret );
    
    is ( $tax_tot, '0.13', "GST + PST add up to the correct amount" );
}

{ # captcha

    _reset();

    my $captcha_ret = $obj->captcha();
    ok ( $captcha_ret > 100, "capcha returns an int when called with no params" );

    my @captchas;
    my $captcha_get_count = 1000;

    for ( 1..$captcha_get_count ) {
        push @captchas, $obj->captcha();
    }
    
    my %seen_captcha;
    my @unique_captchas = grep { ! $seen_captcha{ $_ }++ } @captchas;
    my $unique_captcha_count = scalar @unique_captchas;

    my $unique_percent = sprintf( '%.2f', ( $unique_captcha_count / $captcha_get_count ) * 100 );

    ok ( $unique_percent > 92, "Out of $captcha_get_count captchas, there is better than 92% randomness" );

    my $captcha_test_ret = $obj->captcha({ captcha => $captcha_ret });
    is ( $captcha_test_ret, 0, "captcha() returns 0 if the captcha param is supplied, but not input" );
    
    my $captcha_test_ret2 = $obj->captcha({ input => 500 });
    is ( $captcha_test_ret2, 0, "captcha() returns 0 if the input param is supplied, but not captcha" );

    my $captcha_test_ret_fail_match = $obj->captcha({ captcha => 3, input => 5 });
    is ( $captcha_test_ret_fail_match, 0, "captcha() returns 0 if all params are available, but there is no match" );

    my $captcha_success_ret = $obj->captcha({ captcha => $captcha_ret, input => $captcha_ret });
    ok ( $captcha_success_ret eq 'ok', "captcha() returns ok when all params are supplied, and upon a successful match" );
}

{ # current_config_file

    _reset();

    my $set_cf = $ENV{'ISP_CONFIG'};
    my $cf = $obj->CURRENT_CONFIG_FILE();

    ok( $cf eq $set_cf, "CURRENT_CONFIG_FILE() properly sets and returns the config file location" );
}
sub _clean {
    undef $sanity;
    undef $obj;
    undef $error;
}

sub _reset {

    _clean();

    $obj    = ISP::Object->new({ config => $conf });
    $sanity = ISP::Sanity->new({ config => $conf });
    $error  = ISP::Error->new({ config => $conf });
}

_reset();

