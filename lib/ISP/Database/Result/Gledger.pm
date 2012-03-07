package ISP::Database::Result::Gledger;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'gledger' );

__PACKAGE__->add_columns( qw(
					id
					username       
					amount         
					payment        
					quantity       
					payment_method 
					comment        
					invoice_number 
					item_name      
					total_price    
					date     						
	));
__PACKAGE__->set_primary_key( qw/ id username / );
