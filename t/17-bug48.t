#!/usr/bin/perl 

use strict;

print <<EOT;
bug 48 test
Business::ISP::Sanity's check_* methods are doing the wrong thing with cascading
'and' statements.

When the first 'do' expression got a return of 0, the next exprs
would not run

...in this case, \$error->add_trace() was not being updated:

    \$error->add_message( "\$tag is illegal. Must be left blank, be 0, or contain 2 or 3 digits" )
        and \$error->add_trace()

This test could use more cases!!!!!!!!!!!!!
EOT

use Test::More qw(no_plan);
use Data::Dumper;

use Cwd 'abs_path';
my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
  use_ok('Business::ISP::Sanity');
  use_ok('Business::ISP::Vars');
  use_ok('Business::ISP::Error');

my $sanity;
my $vardb;
my $error;

sub _clean {

	undef $vardb;
	undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

	$vardb	= Business::ISP::Vars->new();
	$sanity	= Business::ISP::Sanity->new();
    $error 	= Business::ISP::Error->new();
}

sub _nothing{} # placeholder

_reset();

#
# Sanity check_* methods 
#


{
	my @methods = qw (
					check_phone
					check_username
					check_password
					check_int
					check_hour
					check_decimal
					check_date
					check_word
					check_string
					check_email
				);

	for my $method ( @methods ) {
		
		_reset();

		$sanity->$method( $method, '**********************************************', $error );

		my @msg 	= $error->get_messages();
		my @data	= $error->data();
		my $stack	= $error->get_stack();

		isnt ( $data[0], 	undef, "Business::ISP::Sanity $method properly adds a data entry to error" );
		isnt ( $stack->[1],	undef, "Business::ISP::Sanity $method properly adds a stack entry to error" );
		isnt ( $msg[0], 	undef, "Business::ISP::Sanity $method properly adds a message entry to error" );

	}
}
