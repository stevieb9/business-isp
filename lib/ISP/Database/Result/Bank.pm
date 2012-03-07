package ISP::Database::Result::Bank;
use base qw/DBIx::Class /;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'bank' );
__PACKAGE__->add_columns( qw(
						id
						invoice_number
						record	
					));
__PACKAGE__->set_primary_key( qw/ id / );
