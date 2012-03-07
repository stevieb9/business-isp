package Business::ISP::Sanity;

use warnings;
use strict;

use vars qw( @ISA );
use base qw( Business::ISP::Object );

use Data::Types qw( :all );
use Scalar::Util qw( reftype );
use Switch;

use Business::ISP::Vars;

BEGIN {
# config accessors
    my @config_vars = qw (
        VALIDATE_VALUE_CODEFLOW
        VALIDATE_VALUE_DEBUG
        VALIDATE_VALUE_TRACE
        DISABLE_VALIDATE_VALUE
    );
    for my $member ( @config_vars ) {
        no strict 'refs';
        *{ $member } = sub {
            my $self = shift;
            return $self->{ config }{ $member };
        }
    }
    
} # end BEGIN

sub audit {

    use Business::ISP::Error;

    my $self        = shift;
    my $params      = shift;

    $self->function_orders();
    
    my $process;

    if ( (caller(1))[3] ) {
        
        my @caller  = split ( /::/, (caller(1))[3] );
        $process    = pop @caller;  
    }

    $process = $params->{ process } if $params->{ process };

    my $complete    = $params->{ complete };
    my $test        = $params->{ test };
    
    my $operator = ( $params->{ operator } )
        ? $params->{ operator }
        : 'system';

    my $runtype = ( $params->{ runtype } )
        ? $params->{ runtype }
        : 'auto';

    my $error       = Business::ISP::Error->new();

    my $schedule = $self->check_process( $process );

    if ( ! $schedule ){
        my $message = "Can not perform an audit on unknown process $process";
        $error->bad_data( $message );
    }
    
    my $date        = $self->date({ get => $schedule });

    my $schema      = $self->schema();
    my $audit_rs    = $schema->resultset( 'Audit' );

    # update the audit list if the process is claiming to be
    # completed

    if ( $complete ) {
        
        my $row_count = $audit_rs->count;

        $audit_rs->create({
                        process     => $process,
                        date        => $self->date({ get => 'day' }),
                        type        => $runtype,
                        operator    => $operator,
                    });

        my $check = $audit_rs->count - $row_count;

        if ( $check == 1 && ! $test ) {
            
            return 1;
        }
        else {
            my $message = "The audit process could not log that $process for $date completed";
            $error->bad_data( $message );
        }
    }

    # we just want to check to see if a process has already run 
    # during it's last time frame

    $audit_rs = $schema->resultset( 'Audit' )->search({
                                            process => $process,
                                            date => { -like => "$date%" },
                                        });

    if ( $audit_rs->count() > 1 ) {

        my $message = "" .
            "Process audit reports that $process " .
            "ran more than once in it's scheduled timeframe";
        $error->bad_data( $message );
    }

    my $executed = $audit_rs->first();

    if ( $executed ) {

        my $executed_date = $executed->date;
        
        my $message = "" .
            "Process $process has already run its $schedule cycle on $executed_date"; 
        $error->bad_data( $message );
    }

    return 0;
}

sub validate_data {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();
    
    my $type    = $params->{ type };
    my $data    = $params->{ data };
    my $error   = $params->{ error };

    my $vardb    = Business::ISP::Vars->new();

    # die right off the bat if either data is an invalid type,
    # or no $error obj was passed in

    unless ( defined $error ) {
        $error = Business::ISP::Error->new();
        $error->bad_api();
    }

    my $skip_value_check_href = $vardb->sanity_value_skip_permitted();

    $self->check_type({ 
                type    => $type, 
                data    => $data, 
                error   => $error, 
            });

    while ( my ( $attribute, $value ) = each ( %$data )) {
        
        if ( exists $skip_value_check_href->{ $attribute } ) {
            next;
        }

        $self->validate_value({ 
                    tag     => $attribute, 
                    value   => $value, 
                    error   => $error, 
                });
    }

    $error->add_trace() and return $error if $error->exists;

    return 1;    
}
sub validate_value {

    use Data::Types qw(:all);

    my $self    = shift;
    my $params  = shift;

    $self->function_orders()
        unless $self->VALIDATE_VALUE_CODEFLOW();

    my $tag     = $params->{ tag };
    my $value   = $params->{ value };
    my $error   = $params->{ error };

    # return if validate_value is disabled!

    return ( 1 ) if $self->DISABLE_VALIDATE_VALUE();    
    
    unless ( defined $error ) {
        $error = Business::ISP::Error->new();
        $error->bad_api();
    }

    if ( $self->VALIDATE_VALUE_DEBUG() ) {

        print "Sanity validate_value_debug: $tag, $value\n";
    }

    my %struct_dispatch_table = $self->get_struct_dispatch_table();

    my $action = $struct_dispatch_table{$tag} 
        || $error->bad_data( "$tag field has no Sanity check!" );

    $self->$action( $tag, $value, $error );

    if ( $self->VALIDATE_VALUE_TRACE() ) {
        $error->add_trace() and return $error if $error->exists;
    }
    return 1;

}
sub validate_payment {

    my $self        = shift;
    my $params      = shift;

    $self->function_orders();
    
    my $transaction = $params->{ transaction };
    my $error       = $params->{ error };

    # die if API error
    
    unless ( defined $error ) {
        $error = Business::ISP::Error->new();
        $error->bad_api();
    }

    $error->add_trace() 
        and $error->add_message( "Illegal number of line items in payment" )
        if defined $transaction->[1]; 
    
    for my $line_item ( @{ $transaction } ) {

        # payment and amount are both non-zero
        $error->add_message( "amount and payment are both non-zero" )
            if  $line_item->{ payment } != 0 
                and $line_item->{ amount }  != 0; 

        # payment eq 0 or is negative
        $error->add_message( "payment is zero or negative" )
            unless $line_item->{ payment } > 0;

        # amount is > 0
        $error->add_message( "amount is non-zero. It must be zero to make a payment" )
            unless $line_item->{ amount } == 0;

        # gst/pst are set
        $error->add_message( "tax is set. It shouldn't be for a payment" )
            unless  $line_item->{ tax } == 0;

        # quantity is not 1
        $error->add_message( "quantity is not set to 1. It must be for a payment" )
            unless $line_item->{ quantity } == 1;

        $error->add_trace() if $error->exists();

    }

    return 0;
}
sub validate_renew {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error   = $params->{ error };
    my $plan_id = $params->{ plan_id };
    my $qty     = $params->{ quantity };
    my $amount  = $params->{ amount };

    if ( ! defined $error ) {
        my $error = Business::ISP::Error->new();
        $error->bad_api();
    }

    # check for -plan_id param

    if ( ! defined $plan_id ) {
        $error->bad_data( "Invalid or missing plan_id parameter" );
    }

    my $plan_db = Business::ISP::User->new();
    my $plan    = $plan_db->get_plan( $plan_id );

    if ( ! defined $plan ) {
        $error->bad_data( "Plan with the id $plan_id does not exist" );
    }

    if ( ! defined $qty || $qty > 300 ) {
        $error->bad_data( "Quantity must be between 1 and 300" );
    }

    $self->validate_value({ 
                tag     => 'amount', 
                value   => $amount, 
                error   => $error, 
            });

    return $error if $error->exists();

    return 0;
}
sub unsafe_string {

    my $self     = shift;
    my $string   = shift;

    $self->function_orders();

    if ( $string =~ /([^\w\s\d])/ ) {
        return $1;
    }
}
sub unsafe_word {
    
    my $self = shift;
    my $word = shift;

    $self->function_orders();

    if ( $word =~ /([^\w])/ ) {
        return $1;
    }
}
sub check_type {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();
    
    my $type    = $params->{ type };
    my $data    = $params->{ data };
    my $error   = $params->{ error };

    my $vardb = Business::ISP::Vars->new();
    $vardb->compare({ type => $type, data => $data, error => $error });

    return 1;
}
sub check_process {

    my $self            = shift;
    my $process_name    = shift;

    $self->function_orders();

    my $vardb = Business::ISP::Vars->new();
    my $proclist    = $vardb->struct( 'process' );

    return $proclist->{ $process_name };
}

# param checking subs

sub check_phone {
    my $self = shift;
    $self->function_orders();
    my ($tag, $value, $error) = @_;
  
    if ( $value !~ /^(\d{3}-\d{3}-\d{4}|^$)$/ ) {

        $error->add_message( "$tag is invalid. Must be in the form xxx-xxx-xxxx, or left blank" );
        $error->add_trace();
        $error->data( { $tag => $value } );
    
    }
    
    return 0;
}
sub check_username {

    my $self = shift;

    $self->function_orders();
    my ($tag, $value, $error) = @_;

    my $problem;

    if ( ( length $value ) >= 45 ) { $problem = "is too long"; }

    #FIXME dirty look to see if it's a pure blank login_name

    unless ( $tag eq 'login_name' && $value eq '' ) {

        if ( ( length $value ) <= 1  ) { $problem = "is too short"; }
    }

    if ( $value !~ m{ ( ^ \w+ (-|\.)? \w+ $ | ^$ ) }xms ) { $problem = "contains invalid characters"; }
    if ( $value =~ /\A_/xms ) { $problem = "$tag can't start with an underscore"; }
    
    if ( $problem ) {

        $error->add_message( "$tag $problem" );  
        $error->add_trace();
        $error->data( { username => $value } );
    
        return 1;
    }

    return 0;
}
sub check_password {

    my $self = shift;

    $self->function_orders();

    my ($tag, $value, $error) = @_;

    my $problem;

    if ( $value =~ /[.\/\\&]/ ) { $problem = "contains potential control characters"; }
    if ( ( length $value ) >= 45 ) { $problem = "is too long"; }
    if ( ( length $value ) <= 5 ) { $problem = "is too short"; }    

    if ( $problem ) {
        $error->add_message( "$tag $problem" );
        $error->add_trace();
        $error->data( { $tag => $value } );
    }

    return 0;
}
sub check_id {

    my $self = shift;
    $self->function_orders();

    my ( $tag, $value, $error ) = @_;

    if ( $value !~ /^\d+$/ && $value ne '' ) {
        $error->add_message( "$tag, supplied as $value, is not a valid id number" );
        $error->data( { $tag, $value } );
        $error->add_trace();
    }

    return 0;
}
sub check_int {
    
    my $self = shift;
    $self->function_orders();
    
    my ( $tag, $value, $error ) = @_;
    
    if ( ( ! is_int( $value )) || ( $value eq '' )) {

        $error->add_message( "$tag is not a legal integer" );
        $error->add_trace();
        $error->data( { $tag => $value } );
    }

    return 0;
}
sub check_hour {
    
    my $self = shift;
    $self->function_orders();
    
    my ( $tag, $value, $error ) = @_;
    
    if ( ! ( $value =~ m{ ^ ( \d{1,3} | 0 | ^$ ) $ }xms ) ) {
        
        $error->add_message( "$tag is illegal. Must be left blank, be 0, or contain 2 or 3 digits" );
        $error->add_trace();
        $error->data( { $tag => $value } );    
    }

    return 0;
}
sub check_decimal {
    
    my $self = shift;
    $self->function_orders();
    
    my ($tag, $value, $error) = @_;
    
    if ( ! is_decimal( $value ) ) {
    $error->add_message( "$tag is not a legal decimal" );
        $error->add_trace();
        $error->data( { $tag => $value } );    
    }

    return 0;
}
sub check_date {

    my $self = shift;
    $self->function_orders();

    my ( $tag, $value, $error ) = @_;

    if ( $value !~ m{ ^ ( \d{4} - \d{2} - \d{2} | ^$ ) $ }xms ) {
        
        $error->add_message( "$tag is not valid. It must be in the format YYYY-MM-DD" ); 
        $error->add_trace();
        $error->data( { $tag => $value } );
    }
        
    return 0;
}
sub check_word {

    my $self = shift;

    $self->function_orders();

    my ( $tag, $value, $error ) = @_;

    if ( $self->unsafe_word($value) ) {
        $error->add_trace();
        $error->data( { $tag => $value } );
        $error->add_message( "$tag has potentially dangerous characters: " .
                    $self->unsafe_word($value)
                );
    }
}
sub check_string {

    my $self = shift;
    $self->function_orders();
    
    my ($tag, $value, $error) = @_;
    
    if ($self->unsafe_string($value)) {
        $error->add_trace(); 
        $error->data( { $tag => $value } );
        $error->add_message( "$tag has potentially dangerous characters: " .
            $self->unsafe_string($value) );
    }
}
sub check_email {

    use Email::Valid;

    my $self = shift;
    $self->function_orders();

    my ($tag, $value, $error) = @_;
   
    my $address = $value;
    my @pieces = split( /@/, $address);
    
    my $check_name = $self->check_username( 'email_name', $pieces[0], $error );

    return if $error->exists();

    my $problem;

    if ( ! Email::Valid->address( $value ) ) {
        $problem = " domain contains illegal chars or formatting"; 
    }

    if ( $problem ) {
    
        $error->add_message( "$tag $problem" );
        $error->add_trace();
        $error->data( { $tag => $value } );
    }

    return 0;
}
sub check_tables {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error   = $params->{ error };
    my $table   = $params->{ table };

    my $vardb   = Business::ISP::Vars->new();

    my $table_exists    = $vardb->is_table({ table => $table });

    if ( ! $table_exists ) {

        $error->add_message( "Database table $table does not exist!" );
        $error->add_trace();
        $error->data({ $table => 'not a valid db table' });

    }

    return 0;
}
sub dt_default {
    my $self = shift;
    $self->function_orders();
    my ($tag, $value, $error) = @_;
    print "NO SUCH DIRECTIVE... \n";
    return 1;
}
sub get_struct_dispatch_table {

    my $self = shift;
    $self->function_orders();

    my %dispatch_table = (

        __DEFAULT__             => \&dt_default,
        username                => \&check_username,
        login_name              => \&check_username,
        password                => \&check_password,
        home_phone              => \&check_phone,
        fax                     => \&check_phone,
        fax_phone               => \&check_phone,
        dsl_number              => \&check_phone,
        work_phone              => \&check_phone,
        mc                      => \&check_int,
        id                      => \&check_id,
        amex                    => \&check_int,
        mastercard              => \&check_int,
        hours                   => \&check_hour,
        balance                 => \&check_decimal,
        rate                    => \&check_decimal,
        quantity                => \&check_decimal,
        extra_hours             => \&check_decimal,
        over_rate               => \&check_decimal,
        tax                     => \&check_decimal,
        pst                     => \&check_decimal,
        gst                     => \&check_decimal,
        hst                     => \&check_decimal,
        payment                 => \&check_decimal,
        amount                  => \&check_decimal,
        flag                    => \&check_decimal,
        hours_balance           => \&check_decimal,
        billing_town            => \&check_string,
        shipping_salutation     => \&check_string,
        billing_address1        => \&check_string,
        billing_address2        => \&check_string,
        shipping_postal_code    => \&check_string,
        billing_postal_code     => \&check_string,
        shipping_last_name      => \&check_string,
        billing_province        => \&check_string,
        shipping_province       => \&check_string,
        billing_first_name      => \&check_string,
        billing_salutation      => \&check_string,
        shipping_address1       => \&check_string,
        shipping_address2       => \&check_string,
        billing_last_name       => \&check_string,
        billing_company_name    => \&check_string,
        shipping_company_name   => \&check_string,
        shipping_first_name     => \&check_string,
        do                      => \&check_string,
        comment                 => \&check_string,
        dob                     => \&check_string,
        shipping_town           => \&check_string,
        description             => \&check_string,
        started                 => \&check_string,
        item_name               => \&check_string,
        plana_deduction         => \&check_string,
        shipping_email_address  => \&check_email,
        billing_email_address   => \&check_email,
        email                   => \&check_email,
        last_update             => \&check_date,
        pap_date                => \&check_date,
        next_billing_date       => \&check_date,
        expires                 => \&check_date,
        system                  => \&check_word,
        technical               => \&check_word,
        accounting              => \&check_word,
        non_payment             => \&check_word,
        password_change         => \&check_word,
        resolved                => \&check_word,
        bank                    => \&check_word,
        none                    => \&check_word,
        erase                   => \&check_word,
        plan                    => \&check_word,
        netbank                 => \&check_word,
        plana                   => \&check_word,
        plan_status             => \&check_word,
        baddebt                 => \&check_word,
        pland                   => \&check_word,
        tax_exempt              => \&check_word,
        cheque                  => \&check_word,
        15                      => \&check_word,
        contra                  => \&check_word,
        telebank                => \&check_word,
        dom_reg                 => \&check_word,
        planc                   => \&check_word,
        os                      => \&check_word,
        1                       => \&check_word,
        planb                   => \&check_word,
        residsl                 => \&check_word,
        server                  => \&check_word,
        visa                    => \&check_word,
        active                  => \&check_word,
        payment_method          => \&check_word,
        other                   => \&check_word,
        hold                    => \&check_word,
        sohodsl                 => \&check_word,
        status                  => \&check_word,
        free                    => \&check_word,
        giftc                   => \&check_word,
        0                       => \&check_word,
        mail                    => \&check_word,
        billing_period          => \&check_word,
        billing_method          => \&check_word,
        plane                   => \&check_word,
        debit                   => \&check_word,
        slipstream              => \&check_word,
        cash                    => \&check_word,
        bizdsl                  => \&check_word,
        pap_method              => \&check_word,

        );                

    return %dispatch_table;
}
sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}

=head1 NAME

Business::ISP::Sanity - Perl module for Business::ISP:: programs. This module is used to
perform validation, verification, authentication and other sanitization
checks on data that is input from other modules, or directly from applications.


=head1 SYNOPSIS

    use Business::ISP::Sanity;

    # Initialize a Sanity object, and pull in config if 
    # available
    my $sanity_check = Business::ISP::Sanity->new();

=cut

=head1 DESCRIPTION

This module is an intermediary sanity checker, which compares attempted
input data against pre-programmed data standards. This module will fail-safe
(ie. we let Error die()) if any input data fails against the pre-programmed
patterns.

This module generally sits somewhere between the user application, and the
modules that perform any write operations. We will work hard to ensure that
all data is passed through this module in the future, no matter what it is.

Business::ISP::Sanity uses the Business::ISP::Error object heavily to relay error notification, 
error messages and error traces back to the caller.

This module is relatively generic, and can be adapted with new APIs, even if
the new callers are not related to the accounting system.

=head1 METHODS

=head2 new

Initializes a new Business::ISP::Sanity object, and if available, will configure itself
from the ISP.conf configuration file.

This method is inhereted from the base class.



=head2 audit({ complete => 1, operator => OP, runtype => TYPE, check => 1 })

This method is responsible for keeping track of accounting operations that can
only be run once per a given cycle.

For example, if a database write operation is to happen automatically once per
month, this method will log an entry each time it is run. If an attempt
is made to run the operation again within the same month, we won't allow it.

All parameters are passed in within a hash reference.

We will identify which process we need to work on by the function name
of the caller.

'complete' informs the audit that the operation just completed, and the timestamp
needs to be logged. This parameter should only be passed in from the operation after
the run is complete. Always send this parameter with the value 1.

'operator' is a string that contains the name of the operator who ran the
operation. It defaults to 'system'.

'runtype' is a string specifying whether this is a manual or automatic run. Values
are 'auto' and 'manual'. Defaults to 'auto' if not passed in.

'check' performs a simple check whether a process has run. This is for
statistics, and should not be called by any automated processes. 

Called without 'complete', the return will be 0 if the operation has not run during
this run cycle, and if it has, will die via Business::ISP::Error.

Called with 'complete', the return will be 1 if the cycle finished and the
audit entry was successfully saved. Will die with an Business::ISP::Error otherwise.




=head2 validate_data({ type => TYPE, data => DATA, error => ERROR })

Validates a data structure as defined in Business::ISP::Vars. 

TYPE is a scalar string name of the defined type to validate. DATA is
the actual data of the type TYPE. ERROR is an Business::ISP::Error object. All 
parameters are passed in within a hash reference.

Checks include:

- the type is actually a defined type
- the type has the correct structure
- the type contains all of the proper properties
- the properties of the type contains values within the guidelines

The value check can be bypassed by setting 'sanity_value_skip_permitted' to a
true value in the configuration file.

The program will die if any of the following are encountered:

- an ERROR is not passed in
- the type is not defined
- the type has too many properties
- the type does not contain all defined properties

If the type is correct thus far but it has invalid values for its properties,
the Business::ISP::Error will be returned.

If all checks pass, the return is 1.



=head2 validate_value({ tag => TAG, value => VALUE, error => ERROR })

Validates the value of a pre-defined element. This method is primarily called by
validate_data(), but this is not enforced.

TAG is the name of the property being validated. VALUE is the TAG value.
ERROR is an Business::ISP::Error object. All parameters are passed in as a hash reference.

Setting VALIDATE_VALUE_DEBUG will have this method perform diagnostic printing to
STDOUT. Setting VALIDATE_VALUE_TRACE allows the profiler to track calls.

Returns:

- die() if an ERROR is not passed in
- die() if TAG does not have an Business::ISP::Sanity check internally
- returns ERROR if VALIDATE_VALUE_TRACE is enabled, and an error has been flagged
- otherwise, returns 1




=head2 validate_payment({ transaction => TRANSAC, error => ERROR })

This method is specifically used when a transaction is a payment. It confirms
that the figures are inline with that of a payment.

TRANSAC is an Business::ISP::Transac object that has already been validated against
Business::ISP::Sanity::validate_data(). ERROR is an Business::ISP::Error object. The parameters are passed
in within a hash reference.

die()s if an ERROR is not passed in.

Returns 0 upon completion. It is up to the caller to handle error conditions. See
perldoc Business::ISP::Error.




=head2 validate_renew({ plan_id => ID, quantity => QTY, amount => AMT, error => ERROR })

This method is specifically used when a transaction is a renewal. It confirms
that the figures are inline with that of a renewal.

ID is the id of the Business::ISP::User account plan being renewed. QTY is an integer of the number
of months/hours for the renewal. AMT is either a two decimal float or an integer
that represents the dollar value of each QTY. ERROR is an Business::ISP::Error object. These
parameters are passed in as a hash reference.

Either die()s or returns ERROR depending on the severity of any issues. Returns 0 upon
success.




=head2 unsafe_string( STRING )

Replaces the 'is_word()' function that I hacked into Data::Types. It is used
to validate strings to ensure they do not contain invalid, illegal or potential
control characters.

Valid characters are: a-zA-Z_ and whitespace.

Takes a single scalar string as the only mandatory parameter. Returns the first
invalid character in the string.




=head2 check_type({ type => $TYPE, data => \%DATA, error => ERROR })

Although this is advertised as a public method, it's primary purpose is for
use internally within Business::ISP::Sanity.

This is a wrapper for data that needs to be passed to Business::ISP::Var::compare().

TYPE is a mandatory scalar string specifying the Business::ISP::Vars type we need to check,
and DATA is a mandatory hashref pointing to the data structure specified by
TYPE. ERROR is an Business::ISP::Error object. Parameters are passed within a hash reference.

Returns true on success, executes and dies with Business::ISP::Error->bad_data() on
failure.



=head2 check_process( PROCESS )

For auditing, verifies whether the process is a legitimate one.

PROCESS is a string that contains the name of the process we are trying
to validate.

Returns either true or false depending on whether the process is legitimate.

=head2 check_tables( TABLE, ERROR )

Check to see if a table exists in the database.

ERROR is a mandatory Business::ISP::Error object parameter, and TABLE is a mandatory
string scalar of the table you want to verify whether it exists.

Returns 0, sets $error->exists() if the table doesn't exist


=head2 get_struct_dispatch_table

This method is also primarly for use internally, but it can and does have
limited functionality outside of the Business::ISP::Sanity package scope.

Call this method to retrieve the dispatch table that maps individual type
property (tag) components to their respective sanity check subroutine.

Returns a hash containing the complete mapping.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<devel at ibctech.ca>. I will be
notified, and you will receive a response when the bug is fixed.

=head1 SUPPORT

You can find documentation for this module with the perldoc command. 

    perldoc Business::ISP::Sanity


=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
