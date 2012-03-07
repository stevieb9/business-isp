package ISP::Database::Result::Operator;
use base qw/DBIx::Class/;

__PACKAGE__->load_components( qw/Core/ );

__PACKAGE__->table( 'operators' );
__PACKAGE__->add_columns( qw(
							opid
							operator
							password
							opgroup
							name
							comment
							email_address
							rank
						));
__PACKAGE__->set_primary_key( qw/ opid / );
