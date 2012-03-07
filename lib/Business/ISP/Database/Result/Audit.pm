package Business::ISP::Database::Result::Audit;
use base qw/DBIx::Class /;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'audit' );

__PACKAGE__->add_columns( qw(
                        id
                        process
                        date
                        type
                        schedule
                        operator
                    ));

__PACKAGE__->set_primary_key( qw/ id / );
