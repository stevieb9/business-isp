package Business::ISP::Database::Result::Receipt;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'inv_num' );

__PACKAGE__->add_columns( qw(
                            id
                            inv_num 
                            date
                        ));

__PACKAGE__->set_primary_key( qw/ id / );

