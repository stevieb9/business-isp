package Business::ISP::Replicated;
use base qw/ Business::ISP::Database /;

__PACKAGE__->load_namespaces();

__PACKAGE__->storage_type(
                '::DBI::Replicated' => {
                        balancer_type => '::Random',
                        balancer_args => {
                                auto_validate_every => 5,
                                master_read_weight => 1
                        },
                        pool_args => {
                                maximum_lag =>2,
                        },
                }
        );

1;
