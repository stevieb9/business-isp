#!/usr/bin/perl 

use strict;

use DBI;
use DBIx::Recordset;
use Cwd 'abs_path';

use Test::More qw(no_plan);
use Data::Dumper;

print "\n\n***** Init *****\n\n";
  use_ok('ISP::User');
  use_ok('ISP::Sanity');
  use_ok('ISP::Vars');
  use_ok('ISP::Error');

my $user;
my $sanity;
my $vardb;
my $error;

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

{ # add_notes();

	_reset();
	my $note =  "" .
				"This is a note for the accounting system.\n" .
				"We're testing it out";

	my $date = $user->full_date();

	my $add_notes_ret 
		
		= $user->add_notes({
				note		=> $note,
				operator	=> 'system',
				date		=> $date,
			});

	is ( $add_notes_ret, 0, "ISP::User add_notes() returns 0 upon completion" );

	# no note param

	$add_notes_ret

		= $user->add_notes({
				operator	=> 'system',
				date		=> $date,
			});

	is ( 	$add_notes_ret, 
			1, 
			"ISP::User add_notes() doesn't insert, " .
			"returns 1 if a note is not passed in, " .
			"and the classification tag is not set to " .
			"something that the system will set the note to a default" 
		);

# test auto-fill on params

	$user->add_notes({
				note	=> 'howdy, just testing!',
			});

	my $notes_aref		= $user->get_notes();
	my $last_note_href	= $notes_aref->[-1];

	like ( 	$last_note_href->{ date }, 
			qr/\d{4}-\d{2}-\d{2}/, 
			"add_notes() properly populates the date with a sane default if the date isn't supplied"
	);

	like (	$last_note_href->{ tag },
			qr/\w+/,
			"add_notes() sets a default classification (tag) when one isn't supplied"
	);

	like (	$last_note_href->{ operator },
			qr/\w+/,
			"add_notes() sets a default operator if 'operator' param is not supplied"
	);

} # end add notes

{ # individual add_notes

	_reset();

	my $result = $user->add_notes({
							tag		=> 'resolved',
						});
	is ( $result, 0, "add_notes() is success when notes/op are blank, but tag is something that will auto-set the note" );

}

{ # get_notes()

	_reset();

	my $notes_aref = $user->get_notes();

	isa_ok ( $notes_aref, 'ARRAY', "get_notes() returns an array reference" );
	isa_ok ( $notes_aref->[0], 'HASH', "each element in get_notes() return is a hash ref" );

	my $bad_notes_user = ISP::User->new({ config => $conf, username => 'rauch' });

	my $no_notes_ret = $bad_notes_user->get_notes();
	is ( $no_notes_ret, undef, "calling get_notes() when no notes exists returns undef" );

	my $single_note = $user->get_notes({ id => 1, });
	isa_ok ( $single_note, 'HASH', "calling get_notes() with an id param return" ); 

	my @field_test = qw ( id username note tag operator date );
	my $field_test_ret;

	for my $field ( @field_test ) {
		$field_test_ret ++ if exists $single_note->{ $field };
	}
	is ( $field_test_ret, 6, "Each note hashref contains 6 fields" );

} # end get_notes



sub _clean {
 
    undef $user;
	undef $sanity;
    undef $error;
}

sub _reset {

    _clean();

    $user  	= ISP::User->new({ config => $conf, username => 'steveb' });
	$vardb	= ISP::Vars->new({ config => $conf });
	$sanity	= ISP::Sanity->new({ config => $conf });
    $error 	= ISP::Error->new({ config => $conf });
}


