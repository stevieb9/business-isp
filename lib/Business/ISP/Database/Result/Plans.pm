package Business::ISP::Database::Result::Plans;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'plans' );
__PACKAGE__->add_columns( qw(
                            id                
                            plan_status       
                            username          
                            login_name        
                            password          
                            server            
                            email             
                            dob               
                            last_update       
                            plan              
                            description       
                            rate              
                            hours             
                            over_rate         
                            billing_period    
                            expires           
                            started           
                            pap_date          
                            next_billing_date 
                            pap_method        
                            billing_method    
                            os                
                            dsl_number        
                            comment           
                            hours_balance     
                            classification                          
    ));
__PACKAGE__->set_primary_key( qw/ id username / );
