#!/usr/bin/perl

use strict;
#use diagnostics;

use Scalar::Util qw( reftype );

use Test::More qw(no_plan);
use Data::Dumper;
use Cwd 'abs_path';

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
  
use_ok('ISP::Error');

my $error;

sub _clean {
 
    undef $error;
}
sub _reset {

    _clean();

    $error 	= ISP::Error->new({ config => $conf });
}

sub _nothing {} # it's only here to break vim folds...TESTS START HERE

print "************************************\n\n\n\n*******************\n";
#
# Error
#

print "\n\n***** Public Tests *****\n\n";

can_ok('ISP::Error', ('add_trace'));
can_ok('ISP::Error', ('add_message'));
can_ok('ISP::Error', ('data'));
can_ok('ISP::Error', ('exists'));
can_ok('ISP::Error', ('dump_stack'));
can_ok('ISP::Error', ('dump_messages'));
can_ok('ISP::Error', ('dump_data'));
can_ok('ISP::Error', ('dump_all'));
can_ok('ISP::Error', ('get_messages'));
can_ok('ISP::Error', ('get_stack'));
can_ok('ISP::Error', ('bad_api'));
can_ok('ISP::Error', ('bad_data'));
can_ok('ISP::Error', ('render_gui_data'));

print "\n\n***** Private Tests *****\n\n";

can_ok('ISP::Error', ('_flag'));

print "\n\n***** Tests against the methods *****\n\n";

#
# add_trace
#

{ # add_trace() trivial

	_reset();

	my $add_trace_ret = $error->add_trace();
	is ( $add_trace_ret, 0, "add_trace() returns success (0) when successful" );
}

{ # add_trace type

	_reset();
	
	$error->add_trace();
	my $add_trace_ret_type = reftype $error->{ stack };
	is ( $add_trace_ret_type, 'ARRAY', "Error's stack trace is an array ref upon success" );
}

# comment out this test for now- 091002
=begin comment

{ # add_trace with param, but with an improper caller stack position

	_reset();

	eval { $error->add_trace( 'blah' ) }; 

	like ( 	$@,
			'/Bad API/', 
			"add_trace() with a param when you are a first-level " .
		   	"caller() results in death via ISP::Error"
		);
}
=end coment
=cut


{ # add message to ensure exists is set

	_reset();

	$error->{ exists } = 0;

	my $add_msg_ret = $error->add_message();

	is ( $add_msg_ret, 
		 0, 
		 "add_message() returns success" 
	);
	is ( $error->exists(), 
		 1, 
		 "add_message() has properly set exists() to true" 
	);
}

{ # add message with param

	_reset();

	$error->add_message( "parameter" );

	my $add_msg_error_message = $error->get_messages()->[0];

	is ( $add_msg_error_message, 
		 'parameter', 
		 "add_message() properly sets it's message to the passed in param" 
	);
}

{ # data

	_reset();

	my $data_ret = $error->data( { key => 'val', a => 'b', } );
	my $data_ret_type = reftype $data_ret;

	my $data_entry = $error->data();
	my $data_entry_type = reftype $data_entry;
	my $data_ret_entry_type = reftype $data_entry->[0];

	is ( $data_ret_type, 
		 'ARRAY', 
		 "calling data() returns all data within the Error as an array ref" 
	); 
	is ( $data_entry_type, 
		 'ARRAY', 
		 "calling data() with no params returns all data within the Error as an array ref" 
	);
	is ( $data_ret_entry_type, 
		 'HASH', 
		 "calling data() with a hashref param pushes that hashref onto Error->{ messages }" 
	);
}

{ # _flag, set and exists is true

	_reset();

	my $flag_ret = $error->_flag();

	is ( $flag_ret, 
		 0, 
		 "_flag() returns success when successful" 
	);
	is ( $error->exists(), 
		 1, 
		 "_flag() properly sets $error->{ exists } to 1" 
	);
}

{ # _flag(), testing aspects
	
	_reset();

	$error->_flag(); 			# COLD CALL

	my $flag_trace = $error->get_stack();
	my $flag_trace_type = reftype $flag_trace;

	is ( $flag_trace_type, 
		 'ARRAY', 
		 "_flag() adds a trace to the stack when called, and $error->exists is not set" 
	);

	$error->{ exists } = 1; 	#FIXME: IN THE GUTS
	delete $error->{ stack };	#FIXME: THIS TOO
	$error->_flag();			# COLD CALL

	my $flag_trace_is_empty = $error->get_stack();
	my $flag_trace_is_empty_type = reftype $flag_trace_is_empty;

	is ( $flag_trace_is_empty_type, 
		 undef, 
		 "if $error->exists() is true, _flag() does not add a trace to the stack" 
	);
}


{ # exists

	_reset();

	my $exists_ret = $error->exists();

	is ( $exists_ret, 
		 0, 
		 "exists() returns 0 if no error is present" 
	);

	$error->_flag();
	$exists_ret = $error->exists();

	is ( $exists_ret, 
		 1, 
		 "exists() returns 1 if an error has been flagged" 
	);
}

{ # dump_*

	_reset();

	# I just want to get this done, so in the Dumper tests, I won't check for
	# proper Dumper results. We'll just check for success...

	#FIXME: NOTE: looks like the methods are doing their thing (and using Dumper) 
	# when calling the tests with 'perl' :)
	# - figure out how to supress this output... eval()?

	my $dump_stack_ret = $error->dump_stack();

	is ( $dump_stack_ret, 
		 0, 
		 "dump_stack() returns success upon success" 
	);

	my $dump_messages_ret = $error->dump_messages();
	
	is ( $dump_messages_ret, 
		 0, 
		 "dump_messages() returns success upon success" 
	);

	my $dump_data_ret = $error->dump_data();

	is ( $dump_data_ret, 
		 0, 
		 "dump_data() returns success upon success" 
	);

	my $dump_all_ret = $error->dump_all();

	is ( $dump_all_ret,	
		 0, 
		 "dump_all() returns success upon success" 
	);
}

{ # get_messages

	_reset();

	my $get_msg_ret = $error->get_messages();

	is ( $get_msg_ret, 
		 undef, 
		 "get_messages() returns undef when no error msgs have been noted" 
	);
}

{ # add_message()

	_reset();

	$error->add_message( "failure" );

	my $get_msg_ret = $error->get_messages();

	is ( $get_msg_ret->[0], 
		 'failure', 
		 "get_messages() with 'failure' as a param returns 'failure' " .
		 "in an array as elem1. FIXME. ME THINKS AN ARRAYREF SHOULD BE HERE!"
	);


	# msg already added above, so we'll add one more, and see if we
	# get two (2) as the result of 'evaluating' an array in scalar context.
	#NOTE: learn terminology for: ( $scalar = @array; ). Is it an evaluation?
	# what is it called?

	my $get_msg_ret_scalar = $error->get_messages();

	#FIXME: THIS DOESN'T WORK! can't identify scalar from wantarray now
	# that we return a ref

}

{ # bad_api

	_reset();

	eval { $error->bad_api() };

	like ( $@,
		 qr/Bad API call/,
		 "Program dies a miserable instant death when bad_api() is called"
	);
}

{ # bad_data

	_reset();

	eval { $error->bad_data() };

	like ( $@,
	   qr/Invalid/,
	   "Program dies a miserable death with a generic error msg when " .
	   "bad_data() is called"
	);

	eval { $error->bad_data( "test_call_bad_data") };

	like ( $@,
	   qr/test_call_bad_data/,
	   "When bad_data() is called with a string param, the program dies, " .
	   "and the string message is displayed"
	);
}

{ # render_gui_data

	_reset();
	
	$error->add_message( "testing" );
	$error->data( { ab => 'cd', ef => 'gh' } );
	$error->add_trace();

	my %render_gui_data_ret = $error->render_gui_data();

	my $ren_gui_data_type = reftype \%render_gui_data_ret;

	is ( $ren_gui_data_type, 'HASH', "render_gui_data() returns a hash" );
}

{ # test returns

	_reset();
	
	$error->add_trace();
	$error->add_message( "blah" );
	$error->data( { this => 'that' } );

    my @msg     = $error->get_messages();
    my @data    = $error->data();
    my @stack   = $error->get_stack();

    isa_ok ( \@msg,     'ARRAY', "check_phone properly updates messages" );
    isa_ok ( \@data,    'ARRAY', "check_phone properly updates data" );
    isa_ok ( \@stack,   'ARRAY', "check_phone properly updates stack" );

}

