package Business::ISP::Object;

use strict;
use warnings;
no warnings 'redefine';

our $VERSION = '0.13_01';

use Carp;
$Carp::Verbose = 1;

use Time::HiRes 'time';

{ 
    # constants

    my @constants = qw (
            UNDEF
            CAPTCHA_LENGTH
            BANK_TEST_MODE
            ENABLE_BANK_PROCESSING
            TEMPLATE_DIR
            CONFIG_DIR
            CURRENT_CONFIG_FILE
            ACCT_APP
            HTML_MANUAL_LOCATION
            SOURCE_REPO_LINK
            IN_TEST_MODE
            HST
            GST
            PST
            VERSION
            DISABLE_ALL_CODE_DEBUG
            TIMEZONE
        );

    for my $member (@constants) {
        no strict 'refs';

        *{$member} = sub {
            my $self = shift;
            $self->{config}{$member} = shift if @_;
            return $self->{config}{$member};
        }
    }
}

{ # master dispatch functions

    my $master_dispatch;

    { # CODEFLOW
        my $codeflow_storage;
        my $call_count = 0;

        sub CODEFLOW {
            my $self = shift;
            my $skip = @_;
            return \$codeflow_storage if $skip;

            my ($rest, $user_param) = @_;
            $codeflow_storage->{$call_count} = (caller(2))[3];
            $call_count++;
        }
        $master_dispatch->{CODEFLOW} = \&CODEFLOW;

        sub GET_CODEFLOW {
            my $self = shift;

            my @sorted_codeflow;
            foreach my $key (sort { ($a) <=> ($b) } keys %$codeflow_storage) {
                push @sorted_codeflow, "$key => $codeflow_storage->{$key}";
            }
            return @sorted_codeflow;

        }
    }

    { # STACK_TRACING

        my @stack;

        sub STACK_TRACING {

            my $self = shift;

            my $skip = @_;
            return @stack if $skip;

            my $caller = (caller(3))[3] ? (caller(3))[3] : 0;
            push @stack, {
                    caller   => $caller,
                    package  => (caller(1))[0],
                    filename => (caller(1))[1],
                    line     => (caller(1))[2],
                    sub      => (caller(2))[3],
                };
        }
        $master_dispatch->{STACK_TRACING} = \&STACK_TRACING;

        sub GET_STACK_TRACING {

            my $self = shift;
            return @stack;
        }
    }

    { # Return a reference to the master dispatch table

        sub MASTER_DISPATCH {
            my $self = shift;
            return $master_dispatch;
        }
    }
}

sub new {

    use Config::Tiny;

    my $class   = shift;
    my $params  = shift;

    my $self  = bless {}, $class;

    # configuration file bootstrap

    my @locations = qw( env param default );

    my $conf_file;

    if ( exists $ENV{'ISP_CONFIG'} ) {
        $conf_file = $ENV{'ISP_CONFIG'};
    }
    elsif ( exists $params->{ config } ) {
        $conf_file = $params->{ config };
    }
    else {
        $conf_file = '/usr/local/etc/ISP.conf';
    }

        
    my $config = Config::Tiny->read( $conf_file );

    # class specific
    
    if ( $class =~ /Business::ISP::GUI/ ) {
    
        my $gui_base = 'Business::ISP::GUI::Base';
        
        while ( my ( $key, $value ) = each ( %{ $config->{ $gui_base } } )) {
                $key = uc $key;
                $self->{ config }{ $key } = $value;
        }
    }

    while ( my ($key, $value) = each (%{$config->{$class}})) {
        $key = uc $key;
        $self->{config}{$key} = $value;
    }

    # version
    while ( my ($key, $value) = each (%{$config->{'Version'}})) {
        $key = uc $key;
        $self->{config}{$key} = $value;
    }
    
    # database
    while ( my ( $key, $value ) = each ( %{ $config->{ 'Database' } } )){
        $key = uc $key;
        $self->{ database }{ $key } = $value;
    }
    { # database symtab entries

        for my $member ( keys %{ $self->{ database } } ){
            no strict 'refs';

            *{ $member } = sub {
                my $self = shift;
                $self->{ database }{ $member } = shift if @_;
                return $self->{ database }{ $member };
            }
        }
    }

    # inject the config file into the object
    $config->{ Constants }{ current_config_file } = $conf_file;

    # constants
    while ( my ($key, $value) = each (%{$config->{'Constants'}})) {
    $key = uc $key;
            $self->{config}{$key} = $value;
    }
    
    # global
    while ( my ($tag, $rest) = each ( %{$config->{'Global'}} )) {

            $tag = uc $tag;
            if ($rest) {
                    $self->{dispatch}{$tag} = MASTER_DISPATCH()->{$tag};
            }
    }

    #$self->function_orders();

    return $self;
}
sub configure {

    use Config::Tiny;

    my $object = shift;
    my $class  = ref $object;

    $object->function_orders();

    my $params = shift;

    my $conf_file;

    if ( exists $ENV{'ISP_CONFIG'} ) {
        $conf_file = $ENV{'ISP_CONFIG'};
    }
    elsif ( exists $params->{ config } ) {
        $conf_file = $params->{ config };
    }
    else {  
        $conf_file = '/usr/local/etc/ISP.conf';
    }

    return 1 if ! -e $conf_file;

    my $config = Config::Tiny->read( $conf_file );

    while ( my ($key, $value) = each (%{$config->{$class}})) {
        $key = uc $key;
        $object->{config}{$key} = $value;
    }

    # email

#   while ( my ( $key, $value ) = each ( %{ $config->{ 'Email' } } )) {
#       $key = uc $key;
#       $object->{ email }{ $key } = $value;
#   }

#   { # email symtab entries

#       no warnings 'redefine';

#       for my $member ( keys %{ $object->{ email }} ) {
#           no strict 'refs';

#           *{ $member } = sub {
#               my $object = shift;
#               $object->{ email }{ $member } = shift if @_;
#               return $object->{ email }{ $member };
#           }
#       }
#   }

    # database
    while ( my ( $key, $value ) = each ( %{ $config->{ 'Database' } } )){
        $key = uc $key;
        $object->{ database }{ $key } = $value;
    }
    { # database symtab entries

        no warnings 'redefine';

        for my $member ( keys %{ $object->{ database } } ){
            no strict 'refs';

            *{ $member } = sub {
                my $object = shift;
                $object->{ database }{ $member } = shift if @_;
                return $object->{ database }{ $member };
            } 
        }
    }

    # inject the config file
    
    $config->{ Constants }{ current_config_file } = $conf_file;

    while ( my ($key, $value) = each (%{$config->{'Constants'}})) {
        $key = uc $key;
        $object->{config}{$key} = $value;
    }

    while ( my ($tag, $rest) = each ( %{$config->{'Global'}} )) {
 
        $tag = uc $tag;
        if ($rest) {
            $object->{dispatch}{$tag} = MASTER_DISPATCH()->{$tag};
        }
    }

    return 0;
}
sub date {

    use DateTime;
    
    my $self    = shift;
    my $params  = shift;    
    
    if ( exists $params->{ get } && $params->{ get } !~ m{ \A (day|month|year) \z }xms ) {
   
        croak "\n\nThe get parameter must be one of 'day', 'month' or 'year': $!";    
    }    
    
    my $get_what = ( $params->{ get } )
        ? $params->{ get }
        : '';
    
    my $datetime;     
    
    if ( $params->{ datetime } ) {        
        $datetime = $params->{ datetime };
    }   
    else {
        $datetime = DateTime->now( time_zone => $self->TIMEZONE() );
    }
        
    if ( $get_what eq 'day' ) {
        return $datetime->ymd();
    }
        
    if ( $get_what eq 'month' ) {
        
        my $month = $datetime->month();
        
        if ( length( $month ) == 1 ) {
            $month = 0 . $month;
        }
        
        my $date =  $datetime->year() . "-" . $month;
        
        return $date;
    }
        
    if ( $get_what eq 'year' ) {
        my $date =  $datetime->year();
        
        return $date;
    }
        
    return ( DateTime->now( time_zone => $self->TIMEZONE()) );
}
sub function_orders {

    my $self = shift;

    # bypass if code debugging is disabled

    return if $self->DISABLE_ALL_CODE_DEBUG();
    
    while ( my ($tag, $function) = each ( %{$self->{dispatch}} )) {
        $self->{dispatch}{$tag}();
    }
}
sub build_stack {

    use Storable;

    my $self = shift;
    my $params = shift;

    $self->function_orders();

    my $stack_file = $params->{ stack_file };

    if ( ! $stack_file || ! -e $stack_file ) {
        $stack_file  = '/tmp/stack.txt';
    }

    my $data;

    if ( -e $stack_file ) {     
        $data = retrieve($stack_file);
    }

    unshift @{$data}, {
            package  => (caller(0))[0],
            filename => (caller(0))[1],
            line     => (caller(0))[2],
            sub      => (caller(1))[3],
        };        

    store ($data, $stack_file);
}
sub db_handle {

    my $self    = shift;

    $self->function_orders();

    my $db_source   = ( $self->IN_TEST_MODE() )
        ? $self->TEST_MODE_SOURCE()
        : $self->MASTER_SOURCE();

    my $db_user     = ( $self->IN_TEST_MODE() )
        ? ''    
        : $self->MASTER_USER();
    
    my $db_pass     = ( $self->IN_TEST_MODE() )
        ? ''
        : $self->MASTER_PASS();
 
    my $dbh = DBI->connect(
            $db_source,
            $db_user,
            $db_pass,
            {
                    RaiseError => 1,
                    PrintError => 0,
                    ChopBlanks => 1,
                    AutoCommit => 1,
            }
    ) or die DBI->errstr;
 
    return $dbh;
}
sub dsn {

    my $self    = shift;
    my $params  = shift;

    my $table   = $params->{ table };

    $self->function_orders();

    my $source  = ( $self->IN_TEST_MODE() )
        ? $self->TEST_MODE_SOURCE()
        : $self->MASTER_SOURCE();
    
    my $user    = ( $self->IN_TEST_MODE() )
        ? ''
        : $self->MASTER_USER();

    my $pass    = ( $self->IN_TEST_MODE() )
        ? ''
        : $self->MASTER_PASS();

    my %dsn = (
        '!DataSource'   => $source,
        '!Username'     => $user,
        '!Password'     => $pass,
        '!Table'        => $table,
    );

    return %dsn;
}
sub schema {

    use Business::ISP::Database;
    use Business::ISP::Replicated;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $result  = $params->{ result };
    my $extract = $params->{ extract };

    # if an indication of an extraction is passed in, ensure
    # both params are present, or return undef

    if ( $result && ! $extract ) {
        return;
    }
    if ( ! $result && $extract ) {
        return;
    }

    # do the extraction work, if necessary

    if ( $result && $extract ) {

        my %inflator = (
                    href    => 'DBIx::Class::ResultClass::HashRefInflator',
                );
    
        $result->result_class( $inflator{ $extract } );

        return $result;
    }

    # get the db info

    my $database_servers = $self->database_config();

    my $master = shift @{ $database_servers };

    if ( ! $self->IN_TEST_MODE() && $self->ENABLE_REPLICATION() ) {
    
        my $schema 
            = Business::ISP::Replicated->connect( @{ $master } );

        $schema->storage->connect_replicants( @{ $database_servers } );
        
        return $schema;
    }

    my $schema
        = Business::ISP::Database->connect( @{ $master } );

    return $schema;
}
sub database_config {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $database_servers; # aref

    # configure the test server if required

    print $self->IN_TEST_MODE() . "'n";
    if ( $self->IN_TEST_MODE() ){

        push( @$database_servers, [
                                $self->TEST_MODE_SOURCE(),
                            ]);

        return $database_servers;
    }

    # configure the master

    push( @$database_servers, [
                                $self->MASTER_SOURCE(),
                                $self->MASTER_USER(),
                                $self->MASTER_PASS(),
                            ]);

    # ...and add any slaves

    if ( $self->ENABLE_REPLICATION() && $self->SLAVE_SERVERS() ){
        
        for my $slave_number ( 1 .. $self->SLAVE_SERVERS() ){
            
            my $slave_info = "SLAVE_${ slave_number }_";

            my $slave; # aref

            for my $item ( qw/ SOURCE USER PASS / ){
                    
                my $function = $slave_info . $item;
                
                push @$slave, $self->$function();
            }       
                
            push @$database_servers, $slave;
        }
    }

    # if the master is locked for maintenance, shift it off
    # the stack

    if ( $self->MASTER_LOCKED() ) {
        
        shift @$database_servers;
    }

    return $database_servers;
}
sub item_count {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $date    = $params->{ date };
    my $column  = $params->{ column };
    my $table   = $params->{ table };

    my $schema  = $self->schema();
    my $col_rs  = $schema->resultset( $table )->search({
                                                    date    => { -like => "$date%" },
                                                });

    my %entries;

    while ( my $record = $col_rs->next ) {
        $entries{ $record->$column }++;
    }

    return \%entries;
}
sub tax_rate {

    my $self = shift;
    my $tax  = shift;
    
    $self->function_orders();

    return unless $tax;

    return $self->GST() if $tax eq 'gst';
    return $self->PST() if $tax eq 'pst';
    return $self->HST() if $tax eq 'hst';

    return;
}
sub bank_info {

    use Config::Tiny;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();
    
    my $conf_file = $self->CURRENT_CONFIG_FILE();

    my $config = Config::Tiny->read( $conf_file );

    my $bank_info;

    if ( $self->BANK_TEST_MODE() ) {
        $bank_info = $config->{ 'BankTest' };
    }
    else {
        $bank_info = $config->{ 'Bank' };
    }
    
    return $bank_info;
}
sub full_date {

    use DateTime;
    use DateTime::Format::MySQL;
    
    my $self    = shift;
    my $date    = DateTime->now( time_zone => 'America/New_York' );
    $date   = DateTime::Format::MySQL->format_datetime( $date );

    return $date;
}
sub string_date {

    use DateTime;
 
    my $self = shift;

    $self->function_orders();

    my $date        = DateTime->now(time_zone => 'America/New_York');
    my $date_string = $date->month_abbr ." ". $date->day .", ". $date->year;
 
    return $date_string;
}
sub string_to_date {
    
    my $self    = shift;
    my $string  = shift;
    
    $self->function_orders();

    my %months = (
            'Jan' => 1,
            'Feb' => 2,
            'Mar' => 3,
            'Apr' => 4,
            'May' => 5,
            'Jun' => 6,
            'Jul' => 7,
            'Aug' => 8,
            'Sep' => 9,
            'Oct' => 10,
            'Nov' => 11,
            'Dec' => 12
        );

    $string =~ s/,/ /g;
    my ($mon, $day, $year) = split (/\s+/, $string);
    $mon = $months{$mon};

    return "${year}-${mon}-${day}";
}
sub storeit {

    use Storable;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();
    
    my $data  = $params->{ data };
    my $store = $params->{ store };

    if ( ! $store ) {
        return 1;
    }

    store( \$data, $store );

    return 0;
}
sub retrieveit {

    use Storable;

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();
    
    my $store   = $params->{ store };
    
    if ( ! $store ) {
        return 1;
    }

    if ( -e $store ) {
        return 1;
    }

    my $data = retrieve( $store );

    return $data;
}   
sub captcha {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $input   = $params->{ input };
    my $captcha = $params->{ captcha };

    if ( ! $input && ! $captcha) {
        
        # caller wants a new captcha

        my $captcha_length = $self->CAPTCHA_LENGTH();

        my $new_captcha;

        for ( 1 .. $captcha_length ) {  
            $new_captcha .= int( rand( 10 ));
        }

        return $new_captcha;
    }
    
    if ( ! $captcha && $input ) {
        return 0;
    }
    if ( ! $input && $captcha ) {
        return 0;
    }
    if ( $captcha == $input ) {
        return 'ok';
    }

    return 0;
}
sub DESTROY {

    my $self = shift;
    $self->function_orders();
}


=head1 NAME

Business::ISP::Object - This module is the base class for all other modules under the Business::ISP:: umbrella.

=head1 SYNOPSIS

    use Business::ISP::Transac; # does not override new()
    use Business::ISP::User;    # overrides new

    # Instantiate a new object who's class does not provide a new() method
    my $transaction = Business::ISP::Transaction->new();

    # Load in info from the config file if the object's class overrides the
    # new() method
    my $user = Business::ISP::User->new();
    $user->configure();
    
=head1 DESCRIPTION

This module contains base methods common to multiple other classes. All Business::ISP:: modules should
use this class as it's base class.

=head1 METHODS

=head2 new({ config => config_file_location })

Provides instantiation of an object of classes who only need generic initialization.

Parameters must be passed in as a hash reference.



=head2 configure ({ NAME => VALUE })

For classes that must override the new() method due to instance specific initialization,
this method will configure the existing object with information from the configuration file,
if it exists.

There are two optional named parameters that can be passed in as a hash reference:

    config      => '/path/to/file',
    more_config => '/path/to/additional.config/'

If config is not passed in, the default configuration file will be used.

The more_config parameter allows the caller to specify an additional
file that contains configuration information that will be applied in
addition to the primary config.

Returns 1 if neither the default or the passed in parameter configuration
files can be found or read.

Returns 0 upon success.


=head2 date ( { get => VALUE, datetime => $datetime } )

Returns a date string or object.

The 'get' hashref parameter can take either day, month or year as valid values.

If year is specified, returns the string 'YYYY'. If 'month' is specified,
the return is 'YYYY-MM'. For day, returns 'YYYY-MM-DD'.

The method will generate a 'now' DateTime object to work with, unless a pre-created
DateTime object is passed in with the 'datetime' parameter.

Returns a DateTime object of the present date/time if no parameters are passed in.

The program terminates via croak() if the 'get' parameter is passed in with an
invalid value.




=head2 function_orders

Call this method in each and every caller where you want to keep the state
of the running application.

This method is used to perform global operations, such as stack tracing,
profiling, codeflow rendering etc.

All methods in all classes in the Business::ISP:: umbrella call this method
just after shifting $self.

Takes no parameters, and it has no return.




=head2 build_stack ({ stack_file => 'file_location' })

A method using Storable to create a stack trace. All methods across all classes should
be configured to use this method, with control in the config file.

The default stack storage file is /tmp/stack.txt. This can be overridden using the
'stack_file' parameter, passed in as a hash reference.




=head2 db_handle

Creates a database handle for DBI.

All configuration info for the DBH is retrieved from the config
file. If 'in_test_mode' is set in the config file, a database handle
that points to the testing database will be configured.

Returns the DBH as a hash ref upon success.




=head2 dsn ({ table => table_name })

Creates a data source for methods that use DBIx::Recordset.

'table' is a mandatory scalar string which indicates which table
in the database to work with. The parameter is passed in as a 
hash reference.

The rest of the DSN is configured from the configuration file.

Returns the DSN as a hash upon success.

The table name will be returned within the DSN as undef if
the table parameter is not supplied.




=head2 schema ({ result => RESULT, extract => EXTRACT })

Returns a DBIx::Class object that has been pre-configured with the
data source information for the ISP database, with the added capability
of configuring a result with an inflator.

When called with no parameters, returns $schema, which is ready 
to be used directly, eg:

    $obj->schema();
    $schema->resultset( 'Clients' )->(1)

If an inflation method is desired for the results of a schema call,
both RESULT and EXTRACT parameters are mandatory, and must be passed in
within a hash reference.

RESULT is the reference that is returned by a call to resultset().
EXTRACT is the code for the inflation module to use. Currently, the
only EXTRACT parameter valid is href.

Returns undef if the parameters are incorrect, returns $schema otherwise.




=head2 database_config

This method compiles all of the database information from the configuration
file.

It returns an array reference. Each element of the returned array ref is
another array reference, containing the database connectivity information. If
'in_test_mode' is enabled in the configuration file, only the test database
information will be returned. Otherwise, the first element will be the master
server configuration, and the following will be the slaves.

[ 'db_source', 'db_user', 'db_pass' ]

If "master_locked" is set in the config file, the master server will not
be included in the return, and the first slave server will be used instead,
if available. Note that the system operates in read-only mode while the
master server is locked.

An empty array reference will be returned if configuration fails, or no
database configuration details are present in the configuration file.



=head2 item_count({ date => DATE, column => COLUMN })

Used to get a list of all the different entries in a single column from any
one of our database tables.

TABLE is a mandatory scalar string. This parameter is used to determine
which table in the database to look into. Valid table names are Balance,
Uledger, Notes, Gledger, Bank, Operator, Receipt, Plans, Clients and Audit.
The names are case-sensitive.

DATE is an optional scalar string param, in the following format YYYY-MM-DD.
Note that you don't need to use the entire date, YYYY will work for year, and
YYYY-MM will work for a month. If DATE is not supplied, all records in the
table will be counted.

COLUMN is a scalar string of the column you want the data from. Both params
must be passed in within a hash reference.

Returns a hash reference where the keys are the field names found, and the
value for each key is an integer representing the number of times that
field was found.




=head2 tax_rate ( TAX )

Returns the applicable tax rate out of the config file.

The manadory parameter TAX is a scalar string, containing one of 'pst' or 'gst'.

Returns undef if a tax type is not supplied as a param, or the tax type
is not found.



=head2 bank_info ({ config => 'config_file_location' })

This method retrieves the information necessary to authenticate to the credit
card processor, and process credit card payments/refunds.

The information is retrieved from the configuration file.

An optional parameter pointing to an alternate configuration file can be
passed in as a hash reference.

It is important to note that unless BANK_TEST_MODE is set to 1 in the 
configuration file, merchant processing will happen live-time in production.

Returns the bank login info as a hash ref.




=head2 string_date

Returns the current date in stringified form, eg: Jun 1, 2009

Takes no params, returns a scalar string.




=head2 string_to_date ( DATE )

This method converts a stringified date, eg: Jun 1, 2009
and converts it into the format 2009-06-01.

DATE is a mandatory string scalar, which contains the stringified
date you want converted.

Returns the reformatted date as a scalar string.




=head2 full_date

Call this method when you need a stringified date in MySQL format, eg:

    '2009-08-12 HH:MM:SS'

Takes no parameters, returns the stringified date.




=head2 storeit ({ data => some_ref, store => 'name_of_storage_file' })

Using Storable, will store data into the specified file for later retrieval.

'data' and 'store' are to be passed in as a hash reference.

'data' is any type of data structure. 'store' is a string scalar file name.

Returns 1 if 'store' is not provided.

Returns 0 upon success.




=head2 retrieveit ({ store => 'name_of_store_file' })

Using Storable, will retrieve the data that was stowed by storeit().

'store' is the path to the file the data is in. Pass it in as a hash reference.

Returns 1 if 'store' is not present, or the file doesn't exist or can't
be opened.

Returns a scalar containing the reference of the data.

It's up to the caller to sort out the reference type.




=head2 captcha ({ NAME => VALUE })

This method is used to generate random captchas, and to compare user input
against it.

Called with no params, will return a random integer. The length of the integer
is determined by the 'captcha_length' directive in the configuration file.

To compare the captcha with the user's input, pass in the following two parameters
as a hash reference.

    captcha => $captcha,
    input   => $user_input

Where $captcha is the captcha originally supplied in the initial call, and 
$input is what the user supplied. Returns "ok" upon successful match.

If one but not both of the parameters are missing, or if the captcha does not
equal the input, returns 0.



=head2 GET_CODEFLOW

If the config file variable CODEFLOW is enabled, this sub will return an array which
contains the entire method process flow of the current run.

Takes no parameters.

=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steve at ibctech.ca> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Business::ISP::Object

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
