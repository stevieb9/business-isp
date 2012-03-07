package ISP::Database::Result::Uledger;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'uledger' );
__PACKAGE__->add_columns( qw(
							id             
							username       
							amount         
							payment        
							comment        
							date           
							invoice_number					
	));
__PACKAGE__->set_primary_key( qw/ id username / );
