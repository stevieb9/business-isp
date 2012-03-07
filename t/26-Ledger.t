#!/usr/bin/perl 

use strict;
#use diagnostics;

use DBI;
use DBIx::Recordset;
use Cwd 'abs_path';

use Test::More qw(no_plan);
use Data::Dumper;

my $conf = abs_path( 't/ISP.conf-dist' );
$ENV{'ISP_CONFIG'} = $conf;

print "\n\n***** Init *****\n\n";
  use_ok('ISP::User');
  use_ok('ISP::Sanity');
  use_ok('ISP::Vars');
  use_ok('ISP::Error');
  use_ok('ISP::Transac');
  use_ok('ISP::Ledger');

my $user;
my $sanity;
my $vardb;
my $error;
my $transac;
my $ledger;

{ # balance

    _reset();

    my $username = $user->username();

    my $current_balance = $ledger->balance({ username => $username });
    like ( $current_balance, qr/\d{1,}/, "ISP::Ledger->balance() returns a digit given a username" );

    my $new_balance = '129.49';

    # try to write a new balance to the db
    
    $ledger->balance({ username => $username, balance => '0.00' });
    my $balance_return = $ledger->balance({ username => $username, balance => $new_balance });

    is ( $balance_return, 0, "ISP::Ledger->balance() returns success (0) if new balance is inserted to the db" );

    my $new_current_balance = $ledger->balance({ username => $username });
    is ( $new_current_balance, '129.49', "adding 129.49 via Ledger->balance() does the right thing" );

    $ledger->balance({ username => $username, balance => 'aaaa' });
    my $bad_balance_ret = $ledger->balance({ username => $username });
    ok ( $bad_balance_ret ne 'aaaa', "The database doesn't accept invalid balance values" );
    
    # put the balance back to orig
    $ledger->balance({ username => $username, balance => $current_balance });
}


{ # Testing invoice_number()

    _reset();

    my $inv_num = $ledger->invoice_number();
    like ( $inv_num, qr/\d+/, "invoice_number() returns an integer: $inv_num" );

    my $inv_write_return = $ledger->invoice_number( $inv_num );
    is ( $inv_write_return, 0, "invoice_number( inv_num ) returns success" );

    my $new_inv_num = $ledger->invoice_number();
    
    my $difference  = ( $new_inv_num - $inv_num );
    is ( $difference, 1, "invoice_number() increments the inv_num by one appropriately" );

    my $date = $ledger->date({ get => 'day' });

    my $day_inv_nums = $ledger->invoice_number( undef, $date );

    ok ( $day_inv_nums->[0] =~ /\d+/, "When requesting a list of daily inv nums, the array contains integers" );

    # test out things when passing both an inv_num and date

    $ledger->invoice_number( 1000, '2020-01-01' );

    my $date_check_inv = $ledger->invoice_number( undef, '2020-01-01' );

    is( $date_check_inv->[0], 1000, "inserting a manual inv_num along with a date does the right thing" );

}

{ # Testing ledger_field

    _reset();

    my $date = $ledger->date({ get => 'day' });
    my $doc_nums = $ledger->invoice_number( undef, $date );

    my $doc = $doc_nums->[0];

    my $gledger_entries = $ledger->get_gledger({ invoice_number => $doc });
    my $single_entry    = $gledger_entries->[0];

    my @fields = qw( username amount date );

    my $data = $ledger->ledger_field({ entry => $single_entry, fields => \@fields });

    my $field_count = keys %$data;

    ok ( $field_count == 3, "we asked ledger_field() for three fields, and we got them" );
    ok ( $data->{ username } =~ /\w+/, "username returned from ledger_field() looks sane" );
    ok ( $data->{ amount }   =~ /\d+/, "amount returned from ledger_field() looks sane" );
    ok ( $data->{ date }     =~ m{ \d{4}-\d{2}-\d{2} }xms, "date field from ledger_field() looks sane" );
    
}

{ # testing sum()

    _reset();

    my $date = $ledger->date({ get => 'day' });

    my $sum = $ledger->sum({
                            date    => $date,
                            for     => 'item_name',
                            total   => 'payment',
                        });

    isa_ok ( $sum, 'HASH', "return value from sum()" );
    ok( exists $sum->{ bad } == 0, "baseline check for invalid item is successful" );
    ok( exists $sum->{ sohodsl } == 1, "first key we received is valid" );
    ok( exists $sum->{ POA } == 1, "second key we received is valid" );
    ok( exists $sum->{ Tax } == 1, "third key we received is valid" );
    ok( $sum->{ sohodsl } =~ /\d+\.?\d{0,2}/, "the key's value is an int or float" ); 
    ok( $sum->{ sohodsl } == '101.19', "value for the first key is accurate" );
    ok( $sum->{ POA } == '22.22', "value for the second key is accurate" );
    ok( $sum->{ Tax } == '13.16', "value for the third key is accurate" );
}


sub _clean {

    undef $user;
    undef $sanity;
    undef $vardb;
    undef $error;
    undef $transac;
    undef $ledger;
}

sub _reset {

    _clean();

     $user      = ISP::User->new({ config => $conf, username => 'steveb' });
     $sanity        = ISP::Sanity->new({ config => $conf });
     $vardb     = ISP::Vars->new({ config => $conf });
     $error     = ISP::Error->new({ config => $conf });
     $transac       = ISP::Transac->new({ config => $conf });
     $ledger        = ISP::Ledger->new({ config => $conf });

}

