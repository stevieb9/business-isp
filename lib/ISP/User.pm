package ISP::User;

use strict;
use warnings;

use vars qw( @ISA );
use base qw( ISP::Object );

use Carp;
$Carp::Verbose = 1;

use DBIx::Recordset;

# generate the symbol table accessors

BEGIN { 

    # config variables

    my @config_vars = qw (
                        PLANA_DEDUCT_ENABLE 
                        PLANA_MIN_HOURS
                        );

    for my $member ( @config_vars ) {
        no strict 'refs';
           *{ $member } = sub {                              
                my $self = shift;                       
                return $self->{ config }{ $member };        
            }                                               
    }                                                       

    # rw members

    my @rw_attributes =  qw(
                tax_exempt 
                billing_first_name 
                billing_last_name 
                billing_address1 
                billing_address2 
                billing_town 
                billing_province 
                billing_postal_code 
                billing_email_address
                home_phone 
                work_phone 
                fax
        
            ); 

    for my $member ( @rw_attributes ) { 

        no strict 'refs'; 

        *{ $member } = sub { 
            my $self = shift; 
            $self->{ info }{ $member } = shift if @_;
            return $self->{ info }{ $member }; 
        } 
    } 

    # ro members
    
    my @ro_attributes = qw(
                username
                   );

    for my $member ( @ro_attributes ) {

        no strict 'refs';

        *{ $member } = sub {
            my $self = shift;
            return $self->{ info }{ $member };
        }
    } 

    # manually handcrafted accessors
    
    my @complex_attributes = qw (
                street 
                fullname 
                prefix
             );

    for my $member ( @complex_attributes ) {
        
        no strict 'refs';
        
        # prefix
        *{ $member } = sub {
            my $self   = shift;
            my $prefix = substr( $self->username(), 0, 1 );
            return $prefix;        
        } if $member eq 'prefix';

        # street
        *{ $member } = sub {
            my $self = shift;
            return "$self->{ info }{ billing_address1 } $self->{ info }{ billing_address2 }";
        } if $member eq 'street';

        # full name
        *{ $member } = sub {
            my $self = shift;
            return "$self->{ info }{ billing_first_name } $self->{ info }{ billing_last_name }";
        } if $member eq 'fullname';  

    }
}

sub new {

    my $thing   = shift;
    my $params  = shift;

    my $username    = $params->{ username };
    my $config      = $params->{ config };

    my $self = ( ref $thing )
        ? $thing
        : bless {}, $thing;

    $self->configure();

    $self->function_orders();

    $self->build_db_user( $username ) if defined $username;

    return $self;
}
sub build_db_user {

    my $self        = shift;
    my $username    = shift;

    my $params      = shift;

    $self->function_orders();

    my $schema      = $self->schema();

    my $client_info_rs 
        = $schema->resultset( 'Clients' )->search({ username => $username });

    return if ! $client_info_rs;

    my $client_info 
        = $self->schema({ result => $client_info_rs, extract => 'href' })->first();

    $self->{ info } = $client_info;

    $self->_init_plans();

    return 0;
}
sub client_info {

    my $self        = shift;
    my $params      = shift;

    my $client_info = $params->{ client_info };

    my $error       = ( exists $params->{ error } )
        ? $params->{ error }
        : ISP::Error->new();

    $self->function_orders();

    if ( ! $client_info ) {
        return $self->{ info };
    }

    my $schema      = $self->schema();

    my $client_info_rs
        = $schema->resultset( 'Clients' )->search({ username => $self->username() });

    return if ! $client_info_rs;
    
    my $existing_client_info = $client_info_rs->first;

    my $sanity  = ISP::Sanity->new();

    $client_info->{ last_update } = $self->full_date();
    
    $sanity->validate_data({
                        type    => 'user_info',
                        data    => $client_info,
                        error   => $error,
                    });
    
    return $error if $error->exists;

    $existing_client_info->update( $client_info );

    return 0;
}
sub add_client {

    my $self        = shift;
    my $params      = shift;

    $self->function_orders();

    my $client_info = $params->{ client_info };
    my $error       = $params->{ error };

    # set the allowed blank fields, then the id

    my @allowed_blank_fields = qw(
                            billing_address2
                            shipping_address2
                            status
                            work_phone
                            comment
                            fax_phone
                            home_phone
                        );

    for my $field ( @allowed_blank_fields ) {
        if ( ! exists $client_info->{ $field } ) {
            $client_info->{ $field } = '';
        }
    }

    $client_info->{ id } = '';
    $client_info->{ last_update } = $self->full_date();

    my $sanity      = ISP::Sanity->new();
    $sanity->validate_data({
                    type    => 'user_info', 
                    data    => $client_info, 
                    error   => $error,
                });

    return $error if $error->exists();

    # set up the db stuff now, we'll need it for testing

    my $schema = $self->schema();
    
    # ensure there isn't already an existing user
    
    my $duplicate_user
        = $schema->resultset( 'Clients' )->search({ username => $client_info->{ username } })->count();

    if ( $duplicate_user ) {
    
        $error->add_trace();
        $error->add_message( "username $client_info->{ username } already exists in the database" );
        return $error;
    }

    # continue to add the user

    my $new_client 
        = $schema->resultset( 'Clients' )->create( $client_info );
                                            
    $new_client->update();
    
    # we need to create an entry in the balance db table

    my %balance_info = (
                   username => $client_info->{ username },
                   balance  => '0.00',
                 );

    my $new_balance
        = $schema->resultset( 'Balance' )->create( \%balance_info );

    $new_balance->update();

    return 0;
}
sub delete_client {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $username    = $params->{ username };
    my $schema      = $self->schema();

    # check to see if the user exists

    my $existing_user
        = $schema->resultset( 'Clients' )->search({
                                            username => $username,
                                        });

    if ( ! $existing_user->count() ){
        return 0;
    }

    my $deleted_ok = $existing_user->delete();

    return $deleted_ok;
}
sub add_plan {

    my $self    = shift;
    my $params  = shift;
    
    $self->function_orders();
    
    my $plan_info   = $params->{ plan_info };
    my $error       = $params->{ error };

    # I'll leave in the id check and then set it below. This uses
    # extra resources, but it allows us to be informed when the caller
    # is doing something dangerous with the id field

    if ( exists $plan_info->{ id } && $plan_info->{ id } ne '' ) {

    my $error_message = "" .
        "id field must be empty when adding a new plan";
        $error->bad_data( $error_message );
    }

    $plan_info->{ last_update } = $self->full_date();

    # the started param is for the Conversion function
    $plan_info->{ started } = ( $params->{ start_date } )
        ? $params->{ start_date }
        : $self->full_date();

    my $plan_class = $self->plan_classification({ plan => $plan_info->{ plan } });

    $plan_info->{ classification } = $plan_class;

    # some fields are allowed to be blank, however, they must
    # be present to pass sanity checks

    my @allowed_blank_fields = qw(
                        os
                        billing_period
                        description
                        next_billing_date
                        server
                        hours_balance
                        classification
                    );

    for my $field ( @allowed_blank_fields ) {

        if ( ! exists $plan_info->{ $field } ) {
            $plan_info->{ $field } = '';
        }
    }

    my $sanity = ISP::Sanity->new;

    $sanity->validate_data({ 
                type    => 'plan_info', 
                data    => $plan_info, 
                error   => $error,
            });

    if ( $error->exists() ) {
            $error->add_trace();
            return $error;
    }

    my $schema = $self->schema();

    my $new_plan
        = $schema->resultset( 'Plans' )->create( $plan_info );
    
    if ( ! $new_plan->update() ){

        $error->add_trace();
        $error->add_message( "The new plan was not added to the database" );
        $error->data( $plan_info );
        
        return $error;
    }

    return 0;
}
sub _init_plans {

    my $self        = shift;

    $self->function_orders();
   
    my $username    = $self->username();
    my $schema      = $self->schema();  
    
    delete $self->{ plan } if exists $self->{ plan };

    my $plan_info_result
        = $schema->resultset( 'Plans' )->search({ username => $username });

    $plan_info_result
        = $self->schema({ result => $plan_info_result, extract => 'href' });

    while ( my $plan_info = $plan_info_result->next() ) {
        $self->{ plan }{ $plan_info->{ id } } = $plan_info;
    }

    return 0;
}
sub username_to_login {

    my $self        = shift;
    my $plan        = shift;
    my $username    = shift;

    $self->function_orders();

    # bug 75 workaround (for now)
    # some users have multiple plans, and a different login_name than
    # username. To ensure that we pull radius data for the user, we
    # convert

    return $username if ! $username;

    if ( $username ne $plan->{ login_name } && $plan->{ login_name } ) {

        $username = $plan->{ login_name };
    }

    return $username;
}
sub get_plans {

    my $self     = shift;
    my @plans;

    $self->function_orders();

    $self->_init_plans();

    while ( my ( $plan_id, $plan_info ) = each ( %{ $self->{ plan } } )) {

        push @plans, $plan_info;
    }

    return @plans;

}
sub get_plan_ids {

    my $self    = shift;
    
    $self->function_orders();

    my @plan_ids = keys %{ $self->{ plan } };

    return @plan_ids;
}
sub get_plan {

    my $self    = shift;
    my $id      = shift;

    $self->function_orders();

    my $schema  = $self->schema();

    my $plan_rs = $schema->resultset( 'Plans' );
    
    if ( ! defined $id ) {
        # user wants the last id
        return $plan_rs->count();
    }

    my $plan = $plan_rs->search({ id => $id });
    
    return if ! $plan;

    my $plan_info = $self->schema({ result => $plan, extract => 'href' })->first();

    return $plan_info; 
}
sub get_plan_status {

    my $self    = shift;
    my $plan_id = shift;

    $self->function_orders();

    my $plan = $self->get_plan( $plan_id );

    my $plan_status = $plan->{ plan_status };

    return $plan_status;
}
sub change_plan_status {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $plan_id     = $params->{ plan_id };
    my $error       = $params->{ error };
    my $operator    = $params->{ operator };

    my $plan        = $self->get_plan( $plan_id );

    my $current_status  = $plan->{ plan_status };
    my $status;

    if ( $current_status eq 'active' ) {
        $status = 'hold';
    }
    else {
        $status = 'active';
    }

    $plan->{ plan_status } = $status;

    $self->write_plan_changes({
                    error       => $error,
                    id          => $plan_id,
                    plan        => $plan,
                    change      => 'plan_status',
                });

    $self->add_notes({
                note    => "Plan $plan_id changed from $current_status to $status",
                tag     => 'plan_status_change',
                operator    => $operator,
            });

    return 0;
}
sub plan_password {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $id      = $params->{ plan_id };
    return 1 if ! $id;

    my $new_pw  = $params->{ new_password };

    my $schema = $self->schema();

    my $pwentry = $schema->resultset( 'Plans' )->find({ id => $id });
    my $orig_pw = $pwentry->password(); 

    # return the password if we're not changing it

    return $orig_pw if ! $new_pw;

    $pwentry->password( $new_pw );
    $pwentry->update();

    return $self->plan_password();
}
sub delete_plan {

    my $self     = shift;
    my $id       = shift;
    my $operator = shift;

    return 1 if ! defined $id;

    $operator   = ( $operator )
        ? $operator
        : 'system';

    $self->function_orders();

    my $schema  = $self->schema();

    my $rs
        = $schema->resultset( 'Plans' )->search({ id => $id });
    
    my $existing_plan   = $rs->first;

    return 1 if ! $existing_plan;

    my $plan_name       = $existing_plan->plan;

    my $deleted_ok = $existing_plan->delete();
    
    if ( $deleted_ok ) {
        my $note 
          = "$plan_name account with the id of $id has been deleted";

        $self->add_notes({
                    tag         => 'system',
                    note        => $note,
                    operator    => $operator,
                });
    }
    return 0 if $deleted_ok;
}
sub plan_hours {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error       = $params->{ error };
    my $id          = $params->{ id };
    my $quantity    = $params->{ quantity };

    my $plan        = $self->get_plan( $id );

    my $sanity      = ISP::Sanity->new();
    $sanity->validate_data({ 
                type    => 'plan_info', 
                data    => $plan, 
                error   => $error,
            });

    if ( $error->exists() ) {
        $error->add_trace();
        $error->add_message( "Plan ID $id is invalid" );
        return $error;
    }

    if ( $quantity !~ /\d+/ ) {
        return 1;
    }

    my $current_hours = $plan->{ hours_balance };

    return $current_hours if ! $quantity;

    my $new_hours = ( $current_hours - $quantity );

    return $new_hours;
}
sub modify_plan_expiry {

    use DateTime::Format::Strptime;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error       = $params->{error};
    my $id          = $params->{id};
    my $quantity    = $params->{quantity};

    my $plan        = $self->get_plan( $id );

    my $sanity = ISP::Sanity->new();
    $sanity->validate_data({
                type    => 'plan_info', 
                data    => $plan, 
                error   => $error, 
            });

    return $error if $error->exists();

    if ( $plan->{ expires } =~ /0000/ ) {
        return 1; 
    }

    if ( $quantity !~ /\d+/ ) {
        return 1;
    }

    my $operand;

    if ( $quantity > 0 ) {
        $operand = 'add';
    }
    elsif ( $quantity < 0 ) {
        $operand = 'subtract';
    }
    else {
        return 1;
    }

    my $date_format
        = new DateTime::Format::Strptime( pattern => '%Y-%m-%d', );

    my $expiry
        = $date_format->parse_datetime( $plan->{'expires'} );

    $expiry->$operand( months => $quantity );

    $expiry = $expiry->ymd('-');

    return $expiry;
}   
sub plana_deduction {

    use ISP::Error;
    use ISP::Sanity;

    use Data::Dumper;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error       = $params->{ error };
    
    # the very first thing we do is ensure that we already haven't
    # run in this current month

    my $sanity      = ISP::Sanity->new();
    my $executed = $sanity->audit({
                                operator    => 'system',
                                runtype     => 'auto',
                            });
    
    if ( $executed ) {

        my $message = "plana_deduction has already run this month";
        $error->bad_data( $message );
    }

    my $month;           
    
    if ( $params->{ month } ) {        
        $month = $params->{ month };        
        if ( $month !~ m{ \A \d{4}-\d{2} \z }xms ){            
            croak "The 'month' param must be in the form YYYY-MM: $!";        
        }    
    }      
    else {        
        my $datetime = $self->date();        
        $datetime->subtract( months => 1 );        
        $month = $self->date( { get => 'month', datetime => $datetime } );    
    }

    my $plan_ids    = $self->plan_members({ plan_name => 'plana', return_id => 1 });
    my $usernames   = $self->plan_members({ plan_name => 'plana' });

    my $error_flag = 0;
    my %result;

    for my $plan_id ( @$plan_ids ) {

        my $username    = shift @$usernames;
        my $user        = ISP::User->new({ username => $username });

        my $hours_remaining 
            = $self->plan_hours({ id => $plan_id, quantity => 0, error => $error });
    
        $result{ hours_remaining } += $hours_remaining;

        my $account_plan = $self->get_plan( $plan_id );
        
        if ( $error->exists() ) {
            
            # we need this flag so we can tell after the loop that an error
            # has occured

            $error_flag = 1;
            
            $error->add_trace();
            $error->add_message( "The above fatal errors occurred while trying to perform PlanA deductions on plan $plan_id" );

            # this resets the error exists bit back to zero, so that
            # this if statement doesn't trigger on subsequent runs.
            # we re-enable it (if necessary) after the for loop

            $error->reset();    
            
            next();
        }

        my $used_hours   = ( $user->get_month_hours_used({ plan => $account_plan, month => $month }) )
            ? $user->get_month_hours_used({ plan => $account_plan, month => $month })
            : 0;

        $result{ used_hours } += $used_hours;
        $result{ total_users }++;

        if ( $self->PLANA_DEDUCT_ENABLE() ) {
            
            if ( $used_hours < $self->PLANA_MIN_HOURS() ) {
            
                $result{ users_under }++;

                my $deducted_hours = ( $self->PLANA_MIN_HOURS - $used_hours );
                $result{ deducted_hours } += $deducted_hours;

                my $note = "$deducted_hours hours were deducted for the month of $month by the PlanA deduction utility";    
                    
                $user->add_notes({
                                tag     => 'system',
                                note    => $note,
                            });

                $used_hours = $self->PLANA_MIN_HOURS();
            }
        }

        $used_hours = ( $used_hours * -1 );

    }

    $error->reset( 1 ) if $error_flag;
    
    my $audited = $sanity->audit({
                            complete    => 1,
                            operator    => 'system',
                            runtype     => 'auto',
                    });

    if ( ! $audited ) {
        my $message = "plana_deduction ran, but it could not be audited...update the log manually";
        $error->bad_data( $message );
    }

    my @return;

    push @return, \%result;
    push (@return, $error) if $error->exists();

    return \@return;
}
sub add_notes {

    my $self        = shift;
    my $params      = shift;

    $self->function_orders();

    my $note        = $params->{ note };

    my $operator    = ( $params->{ operator } ) 
        ? $params->{ operator } 
        : 'system';

    my $tag         = ( $params->{ tag } )
        ? $params->{ tag }
        : 'unclassified';

    my $date        = ( $params->{ date } )
        ? $params->{ date }
        : $self->full_date();

    my %default_tags;

    $default_tags{ non_payment }        = "Note added as a reminder that this account is in arrears";
    $default_tags{ password_change }    = "Clients password changed from original default";
    $default_tags{ resolved }           = "Issues relating to the last note have been resolved";

    $note = $default_tags{ $tag } if ! $note;

    return 1 if ! $note;
    
    # prepend a newline so the notes look cleaner
    $note = "\n\n" . $note;

    my $username    = $self->username();

    #id         => '',
    my %note_entry = (
                tag         => $tag,
                date        => $date,
                operator    => $operator,
                username    => $username,
                note        => $note,
            );

    my $schema = $self->schema();

    my $new_notes   = $schema->resultset( 'Notes' )->create( \%note_entry );
    my $result_ok   = $new_notes->update();

    if ( $result_ok ) {
        return 0;
    }
    else {
        return 1;
    }
}
sub get_notes {

    my $self        = shift;
    my $params      = shift;

    $self->function_orders();

    my $note_id     = $params->{ id };

    my $schema      = $self->schema();

    # return a single record if we received a note id

    if ( defined $note_id ) {
        
        my $note = $schema->resultset( 'Notes' )->search({ id => $note_id });
        my $note_data = $self->schema({ result => $note, extract => 'href' })->first();

        return $note_data if $note_data;

        return;
    }

    # otherwise, return all notes for the current user

    my $notes = $schema->resultset( 'Notes' )->search( 
                                                { username => $self->username() }, 
                                                { order_by  => 'id DESC' },
                                            );
    
    $notes = $self->schema({ result => $notes, extract => 'href' });

    my @user_notes;

    while ( my $note = $notes->next() ) {
        push @user_notes, $note;
    }

    return \@user_notes if $user_notes[0];

    return;
}
sub delete_notes {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $id      = $params->{ id };

    return 1 unless $id;

    my $schema = $self->schema();

    my $existing_note
        = $schema->resultset( 'Notes' )->find({ id => $id });

    my $deleted_ok = $existing_note->delete();  

    return 0 if $deleted_ok;

    return 1;
}
sub write_plan_changes {

    use ISP::Sanity;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error           = $params->{ error };
    my $id              = $params->{ id };
    my $updated_plan    = $params->{ plan };
    my $field_to_change = $params->{ change };

    my $sanity  = ISP::Sanity->new();

    $sanity->validate_data({ 
                type    => 'plan_info', 
                data    => $updated_plan, 
                error   => $error, 
            });

    return $error if $error->exists();
    
    $self->function_orders();

    unless (defined $error) {
        $error = ISP::Error->new();
        $error->bad_api();
    }

    # if there is more than one field that the caller wants changed
    # they've passed in an array

    my $schema  = $self->schema();
    my $table   = $schema->resultset( 'Plans' )->find({ id => $id });

    if ( ref $field_to_change eq 'ARRAY' ) {

        for my $changed_field ( @$field_to_change ) {
    
            $table->$changed_field( $updated_plan->{ $changed_field } );
            $table->update();
        }
    }   
    else {
        
        # only a single field to change

        $table->$field_to_change( $updated_plan->{ $field_to_change } );
        $table->update();
    }

    $self->last_plan_update( $id );

    return 0;
}
sub get_client_list {

    my $self    = shift;

    $self->function_orders();

    my $schema  = $self->schema();
    
    my $rs          = $schema->resultset( 'Clients' )->get_column( 'username' );
    my @client_list = $rs->all();
        
    return @client_list;
}
sub plan_members {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $plan_name = $params->{ plan_name };
    my $return_id = $params->{ return_id };
    my $status    = ( $params->{ status } )
        ? $params->{ status }
        : 'active';
        
    my $schema  = $self->schema();

    # if the caller wants just the ids all of the plans within
    # a specific group, we'll return just that

    if ( $return_id ) {

        my $rs = $schema->resultset( 'Plans' )->search(
                                    { plan => { -like => "%$plan_name%" }},
                                    { plan_status => $status },
                                );
        my @ids;

        while ( my $record = $rs->next ) {
            push @ids, $record->id;
        }

        return \@ids;
    }

    # otherwise, the caller wants the list of usernames

    my $rs  = $schema->resultset( 'Plans' )->search({
                                    plan => { -like => "%$plan_name%" },
                                    plan_status => $status,
                                });
    my @plan_members;                                           

    while ( my $record = $rs->next ) {
        push @plan_members, $record->username;  
   }    

    return \@plan_members;
}
sub get_monthly_login_totals {

    use ISP::RADIUS;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $plan        = $params->{ plan };
    my $plan_name   = $plan->{ plan };
    my $class       = $self->plan_classification({ plan => $plan_name });
    my $stats;
    
    my $username = $self->username();
    $username    = $self->username_to_login( $plan, $username );

    if ( $class ) {
        my $radius  = ISP::RADIUS->new();

        $stats  
            = $radius->monthly_login_totals({
                                username    => $username,
                                nas         => $class,
                            });
    }
    
    return $stats;
}
sub get_month_hours_used {
    
    use ISP::RADIUS;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $plan        = $params->{ plan };
    my $plan_name   = $plan->{ plan };

    my $class   = $self->plan_classification({ plan => $plan });
    my $month   = $params->{ month };

    my $username = $self->username();

    $username = $self->username_to_login( $plan, $username );

    my $radius  = ISP::RADIUS->new();
    
    if ( $month ) {
    
        my $hours_used 
          = $radius->month_hours_used({ username => $username, nas => $class, month => $month });
    
        return $hours_used;
    }

    my $hours_used = $radius->month_hours_used({ username => $username, nas => $class });

    return $hours_used;
}
sub plan_classification {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $plan    = $params->{ plan };

    my $vardb   = ISP::Vars->new();
    
    my $class 
        = $vardb->plan_classification({ plan => $plan });

    return $class;
    
}
sub last_plan_update {

    my $self    = shift;
    my $plan_id = shift;
    
    $self->function_orders();

    my $date    = $self->full_date();
    my $schema  = $self->schema();

    my $plan    = $schema->resultset( 'Plans' )->find({ id => $plan_id });
    
    return 0 if $plan->last_update( $date );

    return;
}
sub radius_password {

    use ISP::RADIUS;

    my $self        = shift;
    my $params      = shift;

    $self->function_orders();

    my $new_pw      = $params->{ password };

    $self->function_orders();

    my $radius      = ISP::RADIUS->new();

    # return if getter
    return $radius->password({ username => $self->username() }) if ! $new_pw;

    my $password =  $radius->password({
                            username => $self->username(), 
                            password => $new_pw, 
                        });

    return $password;
}

sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

ISP::User - Perl module for ISP user operations.

=head1 SYNOPSIS

  # Initialize and populate a new ISP::User
  use ISP::User;
  my $user = ISP::User->new({ username => 'username' });

=head1 DESCRIPTION

This module is used for all client information gathering, manipulation and storage
functions within the ISP:: collection of modules, and the ISP accounting system.

=head1 METHODS

=head2 new ({ username => USERNAME })

Instantiates a new ISP::User object.

The optional parameter USERNAME is a scalar string, and is passed in within a
hash reference. If present, will attempt to configure itself with the user's
information.

If USERNAME is not specified, a new generic, unconfigured user object will be
returned.

Calling new() without any parameters is useful for generating an empty object that can
access class methods through itself.





=head2 build_db_user ( USERNAME )

Retrieves all user information from the MySQL database, and configures the object.

Should really only be called by new().

The mandatory parameter USERNAME is a scalar string.

Returns undef upon failure, and 0 upon success.




=head2 client_info ({ client_info => CLIENT_INFO })

Sets and gets the client's personal information.

CLIENT_INFO is an optional parameter, and if present, will update the client's
information with the data set in The user object itself will be updated. 

The format of the data is that of the 'user_info' hashref as documented in ISP::Vars. 
This parameter must be passed in within a hash reference.

If the parameter is not passed in, a hash reference of the current user's info
is returned.

If the parameter is passed in, this method will die() via ISP::Sanity if the param
contains illicit data. Otherwise, the return will be success (0).



=head2 add_client ({ error => $error, client_info => CLIENT_INFO })

Adds a new client to the database.

There are two mandatory params, passed in within a hash reference.

error is an ISP::Error object. CLIENT_INFO is a hash reference type as defined
in ISP::Vars.

Returns the ISP::Error object upon Sanity failure, or if trying to
create a client who has the same username as someone else.

Returns 0 upon success.




=head2 delete_client({ username => USERNAME })

Deletes a client record.

USERNAME is a mandatory parameter, passed in within a hash reference.

Returns 1 upon success, and 0 if the user could not be found/deleted.





=head2 add_plan ({ plan_info => PLAN_INFO, error => ERROR , start_date => DATE })

Adds a new account plan for the pre-configured user object that calls us.

PLAN_INFO and ERROR are both mandatory parameters, ERROR is an ISP::Error.

DATE is an optional parameter, and must be in the form YYYY-MM-DD. This param
is primarily only used with the Conversion utility. It sets the plan
start date to DATE, as opposed to using today's date.

All params must be passed in within a hash reference.

See the plans.sql schema file for a description of PLAN_INFO.

Returns 0 upon success, and ERROR upon failure.




=head2 _init_plans

This method is called internally to configure the object with it's account
plans.

Takes no parameters, returns 0 upon success.



=head2 username_to_login( PLAN, USERNAME )

Used only by functions that need to find RADIUS database information. It
converts the account username to the specific plan login_name to perform
the search.

PLAN is a hashref containing the user plan in question. USERNAME is
a scalar string containing the overall account username. Both
parameters are mandatory.

Returns the username as a scalar.



=head2 get_plans

Retrieves a list of all the current user object's plans. It first
re-initializes the plans, in case they have changed since last access.

Takes no parameters.

Returns an array where each element is a hashref containing the key, value pairs
for each plan.

If the user has no existing account plans, returns an empty array.




=head2 get_plan_ids

Takes no parameters.

Returns an array containing the current users plan ids.




=head2 get_plan ( ID )

Retrieves the data associated with an individual plan.

ID is (should be) a mandatory scalar integer parameter which represents 
the id number of the plan. However, if called with no parameters,
will return the id of the very last plan created. Useful for testing.

Returns a hashref of the indivitual plan data if the plan exists,
else returns undef.




=head2 get_plan_status( ID )

ID is a mandatory integer value representing a user plan.

Returns a string representing the status of the account plan,
as either 'active' or 'hold'.

Returns undef if no plan is found by ID.




=head2 change_plan_status({ plan_id => ID, operator => OP, error => ERROR })

Modifies the active/non-active status of a users account plan.

All three parameters are mandatory, and are passed in within a hash reference.

OP is the name of the operator performing the task. ID is the id of the plan
itself, and ERROR is an ISP::Error object.




=head2 plan_password({ plan_id => ID, new_password => PASSWD })

Parameters are passed in within a hash reference.

ID is a mandatory integer representing the plan to take action on.

PASSWD is a string scalar.

If PASSWD is omitted, the existing account plan password is returned.

If PASSWD is supplied, the plan referenced by ID will have the password changed.

Returns the password. 




=head2 delete_plan ( ID, OPERATOR )

Deletes an individual client account plan.

ID is a mandatory scalar integer that represents the plan id in the
database.

OPERATOR is an optional parameter that will be used as the operator
name for the notes.

Returns 1 if the ID parameter is not passed in, or if the plan by that
id does not exist. Returns 0 upon success.



=head2 plan_hours ({ id => ID, quantity => QTY, error => ERROR })

Used to add or subtract to the number of hours remaining in a client's
account plan, if the plan is PlanA.

All three parameters are mandatory, and are passed in within a hash reference.

Supply a negative integer as QTY to subtract from the total, or 0 to
simply return the current balance of hours. ERROR is ISP::Error object.

An ISP::Error will be returned immediately if the plan 'id' is invalid.

Returns 1 on failure, and returns the updated number of hours remaining
in the client account plan upon success.

NOTE: the hours balance will be negative if the balance is in the client's
favour!!



=head2 modify_plan_expiry ({ id => ID, quantity => QTY, error => ERROR })

Performs the same function as plan_hours(), but operates 
on the expiry date for plans that are not based on hours.

It takes the same parameters as plan_hours(), however, in this case,
QTY represents the number of months to add/remove from the existing
expiry date.

Upon failure, returns are identical to plan_hours(), but on success,
returns the new expiry date in YYYY-MM-DD format.

An ISP::Error object will be returned immediately if the plan 'id' is
invalid.



=head2 plana_deduction({ error => ERROR, month => MONTH })

This method is responsible for maintaining the remaining hours that a PlanA
user has remaining, by deducting the used hours from the previous month.

If 'plana_deduct_enable' is set to true in the configuration file, any
user who didn't use up to their minimum hours (plana_min_hours in the config file)
will have that time deducted as well.

The ERROR paramater is mandatory, and is an ISP::Error object.

MONTH is a scalar string in the format YYYY-MM. If it is provided, the month
specified will be operated on, as opposed to the default of last month.

Returns an array reference that contains a hashref of the results as its first
parameter, and if there were errors, the error object will be pushed onto the
returned arrayref.

Note that only the problematic PlanA users will be skipped, the valid ones will
all be processed.




=head2 add_notes({ operator => OP, note => NOTE, tag => TAG, date => DATE })

This method adds notes/tickets for the client.

All parameters are passed in within a hash reference.

NOTE is a mandatory parameter as a scalar blob of text.

OP is optional, and specifies the name of the operator making the call.

TAG is optional, and is used for classification purposes.

DATE is optional, and must be passed in as 'YYYY-MM-DD HH:MM:SS' if present.

Returns 1 if the mandatory note parameter is not present.

Returns 0 upon completion and success.




=head2 get_notes({ id => NOTE_ID });

Retrieves the notes associated with the client account.

Returns an array reference if called without any parameters. Each element
in the array reference is a hash reference containing the note information.
The fields in each note are: id, note, operator, tag, date, username.

If called with the scalar string NOTE_ID (which is the id of the record in
the database), get_notes() will return a hashref of the single note requested.

The parameters are to be passed in as a hash reference.

Returns undef if notes don't exist for the client.




=head2 delete_notes ({ id => ID })

Deletes an individual note from a client account.

ID is a mandatory scalar integer that represents the plan id in the
database, and must be passed in within a hash reference.

Returns 1 if the ID parameter is not passed in. Returns 0 upon success.




=head2 write_plan_changes({ id => ID, plan => PLAN, change => CHANGE, error => ERROR })

Updates a client's plan in the database.

Takes four mandatory params within a hash reference:

ID is the id of the plan to change.
PLAN is the plan information that include the desired changes.
ERROR is an ISP::Error object.

CHANGE is the plan item(s) that are to be updated. If a scalar value is passed in,
only that item will be changed. If CHANGE is passed in as an array reference, all
of the items within the array will be updated.

Returns 0 on success, or dies with a DBI::Errstr upon failure.




=head2 get_client_list

Call this when you want to retrieve a list of all existing client usernames.

It can be used as the iterator for get_plans().

Takes no parameters, returns an array in which each element is a unique
client username (upon success).




=head2 plan_members( { plan_name => PLAN, status => STATUS, return_id => BOOL } )

Fetches a list of usernames (or plan ids)  that belong to a specified plan type.

PLAN is a scalar of one of the defined account plan names (eg plana). This
parameter is mandatory.

STATUS is a scalar that represents the status of the account
(eg. active, delete, onhold etc). This parameter is optional. If it is not
supplied, 'active' will be the default.

The 'return_id' parameter is optional. If set to true a true value, then
the return will be an array reference of the plan ids that match the
value in the plan_name parameter.

The parameters must be passed in within a hash reference.

Returns an array reference that contains the list of usernames if return_id
is either not present, or set to a false value.




=head2 get_monthly_login_totals( { plan => PLAN } )

Gathers up the client's monthly login information ( bandwidth up/down/, 
time duration ).

PLAN is the hashref representing the user's plan that you want to operate
on.

ISP::RADIUS is a prerequisite for using this method.

Returns an array reference of hash references.

See ISP::RADIUS::monthly_login_totals() for further details.




=head2 get_month_hours_used({ plan => PLAN, month => MONTH })

Returns the total number of hours used for a month.

PLAN is the hashref of the plan to retrieve stats for, as retrieved
by get_plan(). 

The default is to operate on the current month's data.

MONTH is a month in the format YYYY-MM. This will override the default
with the month you specify.

The parameters must be passed in within a hashref.

See ISP::RADIUS::month_hours_used() for further details.



=head2 plan_classification({ plan => PLAN })

PLAN is the user account plan hashref, after being retrieved via
get_plan(). The parameters are passed in within a hash reference.

Returns the class that the plan name belongs to.




=head2 last_plan_update( ID )

This method is used to update the last_update field in a users plan
when a change to the plan occurs.

ID is the scalar integer of the plan to update.

Returns 0 upon success, and undef upon failure.




=head2 radius_password ({ password => PASSWD })

Returns the current user object's RADIUS password. 

If the optional param PASSWD is passed in, the password will be updated
prior to being returned. The parameter is passed in within a hash reference.

Returns undef if a password is not found.



=head1 AUTHOR

Steve Bertrand, steveb@cpan.org

=head1 SEE ALSO

perl(1).

=cut
1;
