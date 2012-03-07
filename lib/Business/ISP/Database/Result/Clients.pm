package Business::ISP::Database::Result::Clients;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'clients' );

__PACKAGE__->add_columns( qw(
                            id
                            username
                            last_update
                            status
                            home_phone
                            work_phone
                            fax_phone
                            tax_exempt
                            comment
                            billing_company_name
                            billing_first_name
                            billing_last_name
                            billing_address1
                            billing_address2
                            billing_town
                            billing_province
                            billing_postal_code
                            billing_email_address
                            shipping_company_name
                            shipping_first_name
                            shipping_last_name
                            shipping_address1
                            shipping_address2
                            shipping_town
                            shipping_province
                            shipping_postal_code
                            shipping_email_address
                        ));

__PACKAGE__->set_primary_key( qw/ id / );
