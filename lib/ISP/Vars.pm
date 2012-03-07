package ISP::Vars;

use warnings;
use strict;

use vars qw(@ISA);
use base qw(ISP::Object);
use HTML::Menu::Select qw( menu options );

BEGIN {

# config accessors

    my @config_vars = qw (
            FORGIVE_MISSING_ATTRS
            );

	for my $member ( @config_vars ) {

		no strict 'refs';

		*{ $member } = sub {
            my $self = shift;
			$self->{ config }{ $member } = shift
				if @_
				and $member eq 'FORGIVE_MISSING_ATTRS';

            return $self->{ config }{ $member };
        }
    }
} # end BEGIN

# DEFINE DATA TYPES

my @types = qw (
		credit_card
		user_info
        plan_info
        plan_status
        plan
        pap_method
        pap_date
        payment_method
        billing_method
        transaction_data
		note_classification
		process
);
            
sub _defined_user_info {

    my $self = shift;

    $self->function_orders;

    my $user_info = {
				id						=> 'Client ID',
                home_phone 				=> 'Home Phone',
                billing_address1 		=> 'Street',
                shipping_address2 		=> '',
                billing_company_name 	=> 'Company',
                shipping_address1 		=> 'Street',
                last_update 			=> 'Last Update',
                status 					=> 'Status',
                shipping_email_address 	=> 'Shipping Email',
                billing_first_name 		=> 'Billing First Name',
                shipping_company_name 	=> 'Company',
                shipping_first_name 	=> 'Shipping First Name',
                work_phone 				=> 'Work Phone',
                billing_last_name 		=> 'Billing Last Name',
                billing_address2 		=> '',
                tax_exempt 				=> 'GST Exempt',
                billing_email_address 	=> 'Billing Email',
                shipping_town 			=> 'Shipping City',
                shipping_postal_code 	=> 'Shipping Postal Code',
                username 				=> 'Username',
                billing_postal_code 	=> 'Billing Postal Code',
                comment 				=> 'Comment',
                billing_province 		=> 'Billing Province',
                shipping_province 		=> 'Shipping Province',
                shipping_last_name 		=> 'Shipping Last Name',
                billing_town 			=> 'Billing City',
                fax_phone 				=> 'Fax',
    };

    return $user_info;
}
sub _defined_plan_info {

    my $self = shift;

    $self->function_orders;

    my $plan_info = {
				id					=> 'Plan ID',
				pap_date            => 'PAP Date',
                last_update         => 'Last Update',
                plan_status         => 'Status',
                os              	=> 'OS',
                rate            	=> 'Plan Rate',
                email           	=> 'Email',
                dsl_number          => 'DSL Number',
                password            => 'Password',
                billing_period      => 'Billing Period',
                plan            	=> 'Plan',
                login_name          => 'Login',
                server          	=> 'Server',
                billing_method      => 'Billing Method',
                hours           	=> 'Hours',
                description         => 'Description',
                username            => 'Username',
                dob             	=> 'DOB',
                over_rate           => 'Over Rate',
                comment             => 'Comment',
                started             => 'Started',
                pap_method          => 'PAP Method',
                next_billing_date   => 'Next Bill Date',
                expires             => 'Expires',
				hours_balance		=> 'PlanA Hours Remaining',
				classification		=> 'Classification',
		};

    return $plan_info;
}
sub _defined_plan_status {

    my $self = shift;

    $self->function_orders;
    
    my $plan_status = {

        active  => 'Active',
        hold    => 'On Hold',
        erase   => 'Erase',
        flag    => 'Flag',
    };

    return $plan_status;
}
sub _defined_plan {

    my $self = shift;

    $self->function_orders;

    my $plan_names = {
                
   				none			=> '',
				plana           => 'PlanA',
                planb           => 'PlanB',
                planc           => 'PlanC',
                pland           => 'PlanD',
                plane           => 'PlanE',
                residsl         => 'ResiDSL',
                sohodsl         => 'SohoDSL',
                bizdsl          => 'BizDSL',
                extra_hours     => 'Extra Hours',
                dom_reg         => 'Domain Registration',
                slipstream      => 'SlipStream',
				gst				=> 'GST',
				pst				=> 'PST',
				hst				=> 'HST',
		};

    return $plan_names;
}
sub _defined_pap_method {

    my $self = shift;

    $self->function_orders;
        
    my $pap_methods = {

            none    => '',
            bank    => 'Bank',
            visa    => 'Visa',
            mc    	=> 'Mastercard',
            amex    => 'Amex',
        };
}
sub _defined_pap_date {

    my $self = shift;

    $self->function_orders();

    my $pap_dates = {

        0  => '',
                1  => '1st',
                15 => '15th',
        };

        return $pap_dates;
}   
sub _defined_credit_card {

	my $self = shift;

	$self->function_orders();

	my $credit_cards = {

				visa		=> 1,
				mastercard	=> 1,
				amex		=> 1,
			};

	return $credit_cards;
}
sub _defined_payment_method {

    my $self = shift;

    $self->function_orders;

    my $payment_methods = {

                amex            => 'Amex',
                baddebt         => 'BadDebt',
                cheque          => 'Cheque',
                cash            => 'Cash',
                contra          => 'Contra',
                debit           => 'Debit Card',
                free            => 'Free',
                giftc           => 'Gift Card',
                mastercard      => 'Mastercard',
                netbank         => 'Internet Banking',
				invoice			=> 'Invoice',
				other           => 'Other',
                telebank        => 'Telephone Banking',
                visa            => 'Visa',
        };

    return $payment_methods;
}
sub _defined_billing_method {

    my $self = shift;

    $self->function_orders;

    my $billing_methods = {

        email       => 'Email',
        fax        	=> 'Fax',
        mail        => 'Mail',
		halt		=> 'Halt',
	};
}
sub _defined_transaction_data {

    my $self = shift;

    $self->function_orders();

    my $transaction_data = {

              payment_method 	=> '',
              amount 			=> '',
              comment 			=> '',
              payment 			=> '',
              quantity 			=> '',
              tax				=> '',
			  item_name 		=> '',
    };

	return $transaction_data;
}
sub _defined_note_classification {

	my $self = shift;

	$self->function_orders();

	my $note_classifications = {

				system			=> 'system',
				technical		=> 'technical',
				accounting		=> 'accounting',
				non_payment		=> 'non_payment',
				password_change	=> 'password_change',
				resolved		=> 'resolved',
				plan_status_change	=> 'plan_change',
			};

	return $note_classifications;
}
sub _defined_process {

	my $self = shift;

	$self->function_orders();

	my $processes = {

			plana_deduction		=> 'month',

		};

	return $processes;
}
sub _defined_tables {

	my $self	= shift;

	$self->function_orders();

	my $tables = {

		audit		=> 1,
		balance		=> 1,
		bank		=> 1,
		clients		=> 1,
		gledger		=> 1,
		notes		=> 1,
		operator	=> 1,
		plans		=> 1,
		receipt		=> 1,
		uledger		=> 1,
	};

	return $tables;
}
sub _return_vars {

    my $self     	= shift;
    my $type     	= shift;
    my $return_type = shift;

    $self->function_orders;

    my $options = $self->_get_struct($type);

    # return an array of names if told to

    if (defined $return_type and $return_type eq 'name') {
        my @options;

        for my $key (keys (%$options)) {
            push @options, $options->{$key};
        }
        return @options;
    }

    # return an array of keys

    if (defined $return_type and $return_type eq 'key') {

        my @options = keys (%$options);
        return @options;
    }

    return %$options;
}
sub compare {

    my $self  	= shift;
  	my $params	= shift;

    $self->function_orders;

	my $type  = $params->{ type };
    my $data  = $params->{ data };
    my $error = $params->{ error };
    
    $error->bad_data( "$type is not a defined datatype" ) unless $self->is_type( $type );

    my $definition = $self->_get_struct( $type );

    # check for too many/invalid attributes

    my @invalid_attributes;

    for my $attribute ( keys %$data ) {
		push ( @invalid_attributes, $attribute ) unless exists $definition->{ $attribute };
    }

    $error->bad_data( "$type is defined, but it has invalid attributes: " .
        join ( ', ', @invalid_attributes ) ) 
			if scalar( @invalid_attributes );

    # check for not enough attributes

	if ( ! $self->FORGIVE_MISSING_ATTRS() ) {

        my @missing_attributes;

        for my $attribute ( keys %$definition ) {
			next if $attribute eq 'id';
            push ( @missing_attributes, $attribute ) 
				unless exists $data->{ $attribute };
        }

	    $error->bad_data( "$type is defined, but is missing required attributes: " .
            join ( ', ', @missing_attributes ) ) 
				if scalar( @missing_attributes );
    }

    return 0;
}
sub build_select {

    my $self	= shift;
   	my $params	= shift;

    $self->function_orders;

	my $type     = $params->{ type };
    my $default  = $params->{ default };
    my $name     = $params->{ name };

    $name = $type unless defined $name;

    my @keys     = $self->_return_vars($type, 'key');
    my %hash     = $self->_return_vars($type);
        
    my $select  = menu (
            name    => $name,
            values  => [@keys],
            labels  => {%hash},
            default => $default,
    );
    
    return $select;
}
sub is_type {

    my $self = shift;
    my $type = shift;

    $self->function_orders;

    return @types if wantarray;

    my $result = grep (/$type/, @types);

    return $result;
}
sub is_credit_card {

	my $self	= shift;
	my $card	= shift;

	$self->function_orders();

	my $cards	= $self->_defined_credit_card();

	if ( exists $cards->{ $card } && $self->ENABLE_BANK_PROCESSING() ) {
		return 1;
	}

	return 0;
}
sub is_table {

	my $self	= shift;
	my $table	= shift;

	$table = lc( $table );

	my $tables	= $self->_defined_tables();

	if ( exists $tables->{ $table } ) {
		return 1;
	}

	return 0;
}
sub struct {

    my $self = shift;
    my $type = shift;

    $self->function_orders();

	my $type_is_known = $self->is_type( $type );

	if ( ! $type_is_known ) { 
		my $error = ISP::Error->new();
		$error->bad_data( "No such data type: $type" );
	}

	if ( wantarray ) {
		my @names;
		for my $name ( keys %{$self->_get_struct( $type )} ) {
			push @names, $name;
		}
		return @names;
	}

	return $self->_get_struct( $type );
}
sub _get_struct {

    my $self = shift;
    my $type = shift;

    $self->function_orders;

    my $subcall = "_defined_${type}";

    return $self->$subcall();
}
sub return_types {

    my $self = shift;
    $self->function_orders();
    return @types;

}
sub sanity_value_skip_permitted {

    my $self = shift;        

	$self->function_orders();

    my %permitted_to_skip = (

   		pap_date    => undef,                
		password    => undef,                
		comment     => undef,                
		started     => undef,            
		last_update	=> undef,
		dsl_number	=> undef,
		dob			=> undef,
		description	=> undef,
		hours_balance => undef,
		classification => undef,
		id			=> undef,
	);      

	return \%permitted_to_skip;    
}   
sub plan_classification {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $plan	= $params->{ plan };
	my $class;

	return if ! $plan;

	if ( $plan =~ /plan[abcd]/i ) {
		$class = 'dialup';
	}
	elsif ( $plan =~ /(resi|golden)dsl/i ) {
		$class = 'highspeed';
	}
	elsif ( $plan =~ /slipstream/i ) {
		$class = 'slipstream';
	}
	elsif ( $plan =~ /hotspot/i ) {
	  	$class = 'hotspot';	
	}
	else {
		$class = undef;
	}

	return $class;
}
sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}

=head1 NAME

ISP::Vars - Perl module used to store various variables used throughout the
ISP:: collection of modules.

=head1 VERSION

=cut
our $VERSION = sprintf ("%d", q$Revision: 165 $ =~ /(\d+)/);

=head1 SYNOPSIS

    use ISP::Vars;
    my $vardb = ISP::Vars->new();

    # Retrieve the different payment methods avaiable
    my %payment_options = $vardb->payment_methods();

=head1 DESCRIPTION

This module is used to be a single location to store commonly-used list-type
variables for ISP applications and modules.

=head1 METHODS

=head2 new

Instantiates a ISP::Var object. There is no config for this module.




=head2 compare({ type => TYPE, data => DATA, error =>ERROR })

Compares a user supplied data structure against the authoritative layout.

It checks for missing and/or extra attributes within the data structure.

TYPE is a mandatory scalar string, and contains one of: plan_info, plan_status,
plan, pap_method, pap_date, payment_method, billing_method.

DATA is a mandatory parameter, and is passed in as a hashref.

ERROR is a mandatory parameter, and is an ISP::Error object.

All parameters are passed in within a hash reference.

Will die if the structure is not correct.

Returns 0 upon success.




=head2 build_select({ type => TYPE, default => DEFAULT, name => NAME })

Builds an HTML select menu based on the different types.

TYPE is a mandatory scalar string that consists of the text name of one 
of the external methods within this module. 

DEFAULT is an optional  scalar string signifying which field you
want to use as the 'selected' value.

NAME is an optional scalar string signifying that you want to use NAME as the 
returned variable name, instead of using TYPE as the name.

All parameters are passed in within a hash reference.

Example use:

    my $plan_name_select  = $vardb->build_select({ plan => 'plan' });
    $self->pb_param( plan => $plan_name_select );

Returns an array reference of the parameters.




=head2 is_type( TYPE )

Checks whether a particular data type (structure) exists.

TYPE is an optional string parameter.

If called in list context, will return an array of all the known data
types.

Otherwise, it will return true if the type is known, and false if not.



=head2 is_credit_card( PAYMENT_METHOD )

Identifies whether a payment method is via a credit card.

PAYMENT_METHOD is a mandatory scalar string of the payment method to check.

Returns 1 if the payment method is a credit card and the configuration file
variable 'enable_bank_processing' is set to true, and 0 otherwise.



=head2 is_table( NAME )

True/false check to see if a database table schema exists.

NAME is the name of the table to check, and is a mandatory
parameter.

Returns 1 if the table exists, and 0 otherwise.




=head2 struct( TYPE )

TYPE is a mandatory string parameter.

Returns the complete definition of the data structure identified in TYPE.

Review the "Data Structures" section in this manual for known types.

If called in list context, returns the names of the type as an array,
otherwise returns a hash ref.




=head2 return_types

Takes no params. Returns an array of all the known data types.




=head2 sanity_value_skip_permitted

This method returns a hash ref of attribute names that ISP::Sanity is
allowed to bypass it's validate_value() check on.

The keys are the actual attributes allowed to be skipped, the values are
undef.

It's designed to be used as an 'exists' lookup table.



=head2 plan_classification({ plan => PLAN })

PLAN is the name of an account plan, passed in within a hash reference.

Returns the class the account plan is classified as, if possible. Otherwise,
returns undef.




=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steveb at cpan.org> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISP::Vars

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
