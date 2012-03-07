package ISP::Error;

use warnings;
use strict;

use vars qw(@ISA);
use base qw(ISP::Object);
use Storable;

BEGIN {

    # config accessors
    my @config_vars = qw (
                         );

    for my $member ( @config_vars ) {
        no strict 'refs';
        *{ $member } = sub {                              
            my $self = shift;                       
            return $self->{ config }{ $member };        
        }                                               
    }                                                       
} # end BEGIN  

sub add_trace {

    my $self = shift;
    my $step_back = shift;

    $self->function_orders();

    if ( $step_back ) {

        my $valid_caller = ( caller(1) )[0];

        if ( ! $valid_caller ) {

            my $message =   "\nYou must have a valid position in the stack trace " .
                            "to call add_trace() with the BACK parameter. " .
                            "See perldoc ISP::Error\n\n";
        
            $self->bad_api( $message );
        }

        unshift @{ $self->{ stack } }, {
            package  => ( caller(1) )[0],
            filename => ( caller(1) )[1],
            line     => ( caller(1) )[2],
            sub      => ( caller(2) )[3] || 'main()',
        }; 
        
        return 1;
    }

    unshift @{ $self->{ stack } }, {
            package  => ( caller(0) )[0],
            filename => ( caller(0) )[1],
            line     => ( caller(0) )[2],
            sub      => ( caller(1) )[3] || 'main()',
    };

    return 0;
}
sub add_message {

    my $self    = shift;
    my $message = shift;

    $self->function_orders();

    push @{ $self->{ messages }}, $message;

    # we've been given an error message, so we need to set
    # the error exists flag

    $self->_flag();

    return 0;
}
sub data {

    my $self = shift;
    my $data = shift;

    $self->function_orders();

    push @{ $self->{ data }}, $data if $data;

    return $self->{ data };

}
sub _flag {

    my $self = shift;
    $self->function_orders();

    $self->add_trace() unless $self->exists();
    $self->{ exists } = 1;

    return 0;
}
sub exists {

    my $self = shift;
    $self->function_orders();

    return $self->{ exists } if $self->{ exists };

    return 0;
} 
sub reset {

    my $self        = shift;
    my $re_enable   = shift;

    $self->function_orders();

    $self->{ exists } = ( $re_enable )
        ? 1
        : 0;
}
sub dump_stack {

    use Data::Dumper;
    my $self = shift;

    $self->function_orders();

    print Dumper \$self->{ stack };

    return 0;
}
sub dump_messages {

    use Data::Dumper;
    my $self = shift;

    $self->function_orders();

    print Dumper \$self->{ messages };

    return 0;
}
sub dump_data {

    use Data::Dumper;
    my $self = shift;

    $self->function_orders();

    print Dumper \$self->{ data };

    return 0;
}
sub dump_all {

    use Data::Dumper;
    my $self = shift;
    $self->function_orders();

    print Dumper \$self->{ messages }, \$self->{ stack }, \$self->{ data };

    return 0;
}
sub get_messages {

    my $self = shift;
    $self->function_orders();

    return $self->{ messages } if $self->{ messages };

}
sub get_stack {

    my $self = shift;
    $self->function_orders();
    return $self->{ stack };

}
sub bad_api {

    my $self    = shift;
    my $message = shift;

    $self->function_orders();

    my $_sub     = ( caller(1) )[3];
    my $_package = ( caller(0) )[0];
    my $_caller  = ( caller(2) )[3];

    $_caller = $0 unless defined $_caller;

    if ( $message ) {
        die "\n\nBad API call to ${ _sub } from ${ _caller }\n\n" .
            "$message\nCaller: ${ _caller }, Function: ${ _sub }...\n\n";
    }
    else {
        die "\n\nBad API call to ${_sub} from ${_caller}: You did not supply an ISP::Error object\n\n" .
            "Please read \"perldoc $_package\" for proper API use\n\n";
    }
}
sub bad_data {                        

    my $self        = shift;        
    my $message    = shift;

    $self->function_orders();

    my $_sub        = ( caller(1) )[3];        
    my $_package    = ( caller(0) )[0];
    my $_caller     = ( caller(2) )[3];
        
    $_caller = $0 unless defined $_caller;
                
    if ( $message ) {
        die "\n\n$message\nCaller: ${_caller}, Function: ${_sub}...\n\n";
    } 
    else {
        die "\n\nInvalid data type or structure passed to ${_sub} from ${_caller}: " .
        "The sanity check has failed during the data compare() phase\n" .
        "FATAL: This is currently a fatal error\n";            
    }
}
sub render_gui_data {

    my $self     = shift;
    $self->function_orders();

    my $error_messages = $self->get_messages();
    
    my $stack   = $self->get_stack();
    my $data    = $self->data();

    my $messages;

    my $gui_data;

    my $tmpl_iter = 1;

    for my $each_sub_data ( @$data ) {

        my $temp;
        
        while ( my ( $key, $value ) = each ( %$each_sub_data )) {
            
            $temp->{"d${tmpl_iter}"} = "${key} => ${value}";
            $tmpl_iter++;
        }
        push @$gui_data, $temp;
    }

    for ( @$error_messages ) {
        push @$messages, { text => "$_" };
    }

    my %error_tpl_data = (

        MESSAGES    => $messages,
        STACK       => $stack,
        DATA        => $gui_data,
    );
    
    return %error_tpl_data;
}
sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}

=head1 NAME

ISP::Error - Perl module within the ISP:: namespace. Performs various
operations for error checking, printing and storage.

=head1 VERSION

=cut
our $VERSION = sprintf ("%d", q$Revision: 165 $ =~ /(\d+)/);

=head1 SYNOPSIS

    # Initialize an ISP::Error object

    use ISP::Error;
    my $error = ISP::Error->new();

    # Permit ISP::Error to die() a program if a function requires an ISP::Error
    # object as a parameter, but one was not supplied

    unless defined $error {
        $error = ISP::Error->new;
        $error->bad_api();
    }

=head1 DESCRIPTION

This module handles all error processing for any application or module that calls us.

We are capable of generating error messages,  stack back-traces, and even rendering
the data that caused an error to be triggered.

Stack traces can be generated at application level, or can be cascaded throughout the 
entire caller() chain.

This module can, and generally is used to kill an entire process immediately via die(). It
is also very handy as a troubleshooting mechanism for long running programs. Although
its main purpose is to cause death, it has the side-effect of storing full stack traces, 
custom error messages and faulty data. This information can be rendered at will. In 
combination with ISP::GUI:: modules, prints the info to the browser in a nicely formatted
manner.

=head1 METHODS

=head2 new
 
Instantiates a new ISP::Error object.

This method is inhereted from the base class.




=head2 add_trace( BACK )
 
Adds a stack trace to itself from the standpoint of the caller.

Call this in every routine present to ensure a complete stack trace.

If the optional integer BACK is supplied, a trace will be pushed onto the stack that is
from the perspective of a single caller previous.




=head2 add_message( MESSAGE )
 
Adds a text error message string to itself.

The optional MESSAGE param is a scalar string, and it will be used as the message
pushed into itself. Otherwise, a generic pre-determined string will be used, if
available.

Use this method to indicate that an error has happened.




=head2 data( DATA )

Adds the DATA that triggered the error event.

If the DATA is being set for use in the web GUI rendering engine, then DATA MUST be
in the form of a hash reference at this time, in the form 'description' => 'value'.
Otherwise, it can be a reference of any type, or a simple scalar string.

Returns an array ref containing all of the items stored. It's up to the caller
to sort out what type of data is contained in each element.

Call this method when you want to tell the ISP::Error about the DATA that triggered
the error event. 

If the method is called without the DATA parameter, the existing DATA will be returned per above.




=head2 _flag

Sets to true the fact that an error has been caught.

Takes no params, returns 0 upon success. Adds a stack trace entry if
the exists flag has not been previously set.




=head2 exists
 
Used by external calls to verify whether an error flag is present.

Returns true if an error has been flagged, else returns 0.



=head2 reset( BOOL )

Enables a caller to flip the exists bit on and off.

The purpose of this method is to provide the use of the ISP::Error object
in a loop manner, without appending any custom data to the object each time
through the loop, when data is being appended based on the exists flag.

This should be used with caution, and you must re-enable the exists flag
after the loop terminates so proper handling can be performed.

When called with no parameters, the exists bit will be set to 0.

Calling with the parameter 1 will set the exists flag back to true.



=head2 dump_stack
 
Using Data::Dumper, dumps the trace stack to STDOUT

Returns 0 on success.




=head2 dump_messages
 
Using Data::Dumper, dumps the error messages to STDOUT

Returns 0 on success.




=head2 dump_data

Using Data::Dumper, dumps the current user data to STDOUT

Returns 0 on success.




=head2 dump_all
 
Using Data::Dumper, dumps all of the data, messages and stack traces stored.

Returns 0 upon success.




=head2 get_stack
 
Returns the array storing all current stack traces. Individual stack traces
are contained within a hashref.




=head2 get_messages
 
When called in list context, returns an array reference. Each array element stores 
a string of text, which is normally passed in by the caller via add_message(). In cases where
the caller didn't supply a custom message to add_message(), the message will be
a generic string, written by the core itself.

The messages are 'unshifted' under the array, so the zeroeth element is 
the most recent message stored.

When called in scalar context, returns the number of messages that have been added
to the Error object's message storage system since inception.

Returns undef if no messages have yet been stored.




=head2 bad_api( MESSAGE )
 
Call this routine if an ISP::Error object is not supplied via parameter,
and it needs to be mandatory.

If MESSAGE is supplied, it will be included in the die() output. Otherwise,
a generic message will be printed.

This method uses die() to kill all processes immediately.




=head2 bad_data ( MESSAGE )

This routine allows ISP::Error to die() if an ISP::Sanity data
comparison check fails. More work needs to be done, but essentially, for now,
it does the same thing as bad_api().

Although this method was designed for use specifically by ISP::Sanity, it
can be used elsewhere. If the optional scalar string MESSAGE is passed in,
the error message will override the default, and display the string passed in
instead.




=head2 render_gui_data

This is a helper method for an application that produces and populates the HTML 
template.

It massages the $stack, $data and $messages into a bundle ready to be inserted
into the error.html.tpl template.

This method takes no parameters, and returns a hash containing the formatted data.

The three hash keys being DATA, MESSAGES, and STACK.

=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steveb at cpan.org> >>. I will be notified, and will report
back to you with any updates.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISP::Error


=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
