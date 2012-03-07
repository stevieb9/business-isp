package ISP::Database::Result::Notes;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

#__PACKAGE__->load_components( qw/ +ISP::Database::Override / );


__PACKAGE__->table( 'notes' );

__PACKAGE__->add_columns( qw(
                            id          
                            username    
                            note        
                            tag         
                            operator    
                            date        
                ));

__PACKAGE__->set_primary_key( qw/ id / );
