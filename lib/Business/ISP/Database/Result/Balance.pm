package Business::ISP::Database::Result::Balance;
use base qw/DBIx::Class /;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'balance' );

__PACKAGE__->add_columns( qw(
                        id
                        username
                        balance 
                    ));

__PACKAGE__->set_primary_key( qw/ id username / );
