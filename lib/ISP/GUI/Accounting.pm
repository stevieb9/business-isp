package ISP::GUI::Accounting;

use warnings;
use strict;

use base qw( ISP::GUI::Base );
use HTML::Menu::Select qw( menu options );

sub setup {

    my $self = shift;        

	$self->function_orders();

	my $client_session_expiry	= $self->CLIENT_SESSION_EXPIRY();
	my $client_cookie_expiry	= $self->CLIENT_COOKIE_EXPIRY();
	my $login_timeout			= $self->CLIENT_LOGIN_TIMEOUT();

	$self->session_config(
				DEFAULT_EXPIRY	=> $client_session_expiry,
				COOKIE_PARAMS => {
								-expires => $client_cookie_expiry,
						},
		);
	$self->session->expire( 'logged_in', $login_timeout );

    $self->link_integrity_config(
        secret            => $self->URL_CHECKSUM_KEY(),
        digest_module     => $self->URL_CHECKSUM_DIGEST(),
        disable           => $self->ENABLE_URL_CHECKSUM(),
    );

    $self->start_mode('start');
    $self->mode_param( 'do' );
    $self->run_modes(
			start					=> 'start',					# start page
			login					=> 'login',					# auth
			logout					=> 'logout',				# logout
			home               		=> 'home',                  # home page
			find_this				=> 'find_this',				# search page
			perform_find			=> 'perform_find',
			load_client_profile		=> 'load_client_profile',	# client account
			client_info_detail		=> 'client_info_detail',
			client_add				=> 'client_add',			# add client
			client_delete			=> 'client_delete',			# delete client
			client_delete_confirm	=> 'client_delete_confirm',	# delete client confirm
			process_client_add		=> 'process_client_add',
			edit_info           	=> 'edit_info',
   			show_plan        		=> 'show_plan',             # plan
			display_edit_client		=> 'display_edit_client',	# client edit
			edit_client_info		=> 'edit_client_info',	
			display_edit_plan		=> 'display_edit_plan',
			edit_plan				=> 'edit_plan',
			edit_plan_complete		=> 'edit_plan_complete',
			display_add_plan    	=> 'display_add_plan',
            add_plan        		=> 'add_plan',
   			delete_plan				=> 'delete_plan',
   			edit_plan        		=> 'edit_plan',
            change_plan_status    	=> 'change_plan_status',
			show_notes				=> 'show_notes',			# notes
			add_notes				=> 'add_notes',
			process_notes			=> 'process_notes',		
			display_purchase_form   => 'display_purchase_form', # purchase
			confirm_purchase		=> 'confirm_purchase', 	
			process_purchase    	=> 'process_purchase',
            display_payment_form    => 'display_payment_form',  # payment
			confirm_payment			=> 'confirm_payment', 	
			process_payment        	=> 'process_payment',
			display_renew_form		=> 'display_renew_form',	# renewals
			display_renew_confirm	=> 'display_renew_confirm',	
			process_renew			=> 'process_renew',		
			display_uledger        	=> 'display_uledger',       # user ledger
			display_invoice			=> 'display_invoice',
			email_invoice			=> 'email_invoice',
			display_config			=> 'display_config',		# display config file
			error					=> 'error',					# call for prerun
			reports					=> 'reports',				# report list page
			exec_report				=> 'exec_report',			# report dispatcher
			income_by_payment_type	=> 'income_by_payment_type', # report daily activity
			income_by_item			=> 'income_by_item',		# report acct balance
			unused_service			=> 'unused_service',		# both hours and months
	);
}
sub home {

	my $self	= shift;
	my $params	= shift if @_;

	$self->function_orders();

	my $message	= $params->{ message } if exists $params->{ message };

	$self->_clear_session( { save_only_profile => 1 } );

	my $operator	= $self->session->param( 'operator' );
	my $opgroup		= $self->session->param( 'opgroup' );

	$self->_header();
	
	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( 
				"$template_dir/single_search.html.tpl",
		  		die_on_bad_params => $self->DIE_ON_BAD_PARAMS(), 
			);

	$self->pb_param( message => $message ) if $message;

	my $client_add_link = $self->self_link( do	=> 'client_add' );
	$self->pb_param( client_add_link	=> $client_add_link );

	my $client_delete_link = $self->self_link( do => 'client_delete' );
	$self->pb_param( client_delete_link => $client_delete_link );

	my $find_link	= $self->self_link( do => 'find_this' );
	$self->pb_param( find_link			=> $find_link );

	my $reports_link = $self->self_link( do => 'reports' );
	$self->pb_param( reports_link => $reports_link );

	$self->pb_param( action	=> '/cgi-bin/accounting.cgi' );
   	$self->pb_param( do		=> 'load_client_profile' );

	return $self->pb_build();
}
sub load_client_profile {

	my $self	= shift;

	$self->function_orders();

	my $sanity	= ISP::Sanity->new();
	my $error	= ISP::Error->new();

	my $username	= $self->query->param( 'search_for' );
	$username 		= $self->session->param( 'username' ) if ! $username;

	# sanity check

	$sanity->check_username( 'username', $username, $error );

	if ( $error->exists() ) {
		return $self->_process({ data => { 'username' => $username }, error => $error });
	}

	$self->session->param( username => $username );

	my $client = ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	$self->_footer();

	return $self->_process({ error => $error }) if $error->exists();

	return $self->pb_build();
}
sub client_add {

	my $self	= shift;

	$self->function_orders();

	$self->_header();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });
	}

	my $template_dir = $self->TEMPLATE_DIR();

	$self->pb_template( 
			"$template_dir/client_add.html.tpl",
	   		die_on_bad_params => $self->DIE_ON_BAD_PARAMS(),
		);

	my $operator	= $self->_get_operator_info( 'operator' );

	$self->pb_param( do => 'process_client_add' );
	
	$self->session->param( operator => $operator );

	return $self->pb_build();
}	
sub client_delete {

	my $self	= shift;

	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

	$self->_header();

	my $template_dir = $self->TEMPLATE_DIR();	
	$self->pb_template( "$template_dir/client_delete_request.html.tpl" );

	my $operator	= $self->_get_operator_info( 'operator' );
	my $opgroup		= $self->_get_operator_info( 'opgroup' );

	# crash and burn immediately if the op isn't an admin

	if ( $opgroup ne 'admin' ) {

		my $error = ISP::Error->new();
		
		$error->add_trace();
		$error->add_message( "The operator group you belong to is not authorized to remove a client." );
		$error->data({ 
					operator	=> $operator,
					group		=> $opgroup,
				});

		$self->_process({ error => $error });
	}

	my $captcha = $self->captcha();

	$self->pb_param( captcha => $captcha );

	return $self->pb_build();
}
sub client_delete_confirm {

	my $self		= shift;

	$self->function_orders();

	my $username	= $self->query->param( 'username' );
	my $captcha		= $self->query->param( 'captcha' );
	my $confirm		= $self->query->param( 'confirm' );

	my $error		= ISP::Error->new();

	if ( $self->captcha({ captcha => $captcha, input => $confirm }) ne 'ok' ) {		
		$error->add_trace();
		$error->add_message( "Incorrect captcha value when trying to delete client" );
		$error->data({ captcha => $captcha, confirm => $confirm });
		return $self->_process({ error => $error });
	}
	
	my $userdb	= ISP::User->new();

	my $delete_result = $userdb->delete_client({ username => $username });

	if ( ! $delete_result ) {
		$error->add_trace();
		$error->add_message( "User $username does not exist" );
		$error->data({ username => $username });
		return $self->_process({ error => $error });
	}

	$self->home({ message => "Client $username deleted successfully" });
}	
sub process_client_add {

	my $self	= shift;

	$self->function_orders();

	my $client_shell	= ISP::User->new();
	my $vardb			= ISP::Vars->new();

	my @client_items	= $vardb->struct( 'user_info' );
	
	my $new_client; # href

	# gather the proposed client data

	my $copy_billing_to_shipping = $self->query->param( 'billeqship' );

	for my $client_item ( @client_items ) {

		# if the item is declared in the struct, we'll
		# get a value from it

		if ( my $item_value = $self->query->param( $client_item ) ) {
			
			# if we're copying billing info to shipping

			if ( $client_item =~ m{ \A billing_ \w+ \z }xms && $copy_billing_to_shipping ) {

				$new_client->{ $client_item } = $item_value;
				$client_item =~ s/billing_/shipping_/;
				$new_client->{ $client_item } = $item_value;

				next();

			}

			$new_client->{ $client_item } = $self->query->param( $client_item );
		}
	}

	my $error	= ISP::Error->new();

	$client_shell->add_client({ error => $error, client_info => $new_client });

	return $self->_process({ error => $error }) if $error->exists();

}
sub find_this {

	my $self		= shift;

	$self->function_orders();

	$self->_header();
	
	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/find_this.html.tpl" );

	$self->pb_param( do => 'perform_find' );	
	
	return $self->pb_build();
}
sub perform_find {

	my $self	= shift;

	$self->function_orders();

	my $find_this	= $self->query->param( 'find_this' );
	my $search_data	= $self->query->param( 'search_data' );

	my %find_commands = (
				plan_by_id	=> \&_find_plan_by_id,
				invoice		=> \&_find_invoice,
			);
	
	$find_commands{ $find_this }( $self, $search_data );
}
sub _find_plan_by_id {

	my $self		= shift;
	my $search_data	= shift;

	$self->function_orders();

	my $client = ISP::User->new();

	my $plan	= $client->get_plan( $search_data );

	my $username = $plan->{ username };

	$self->session->param( username 	=> $username );
	$self->session->param( planid		=> $search_data );

	$self->forward( 'show_plan' );
}
sub _find_invoice {

	my $self			= shift;
	my $invoice_number	= shift;

	$self->function_orders();

	$self->display_invoice({
						is_method_call 	=> 1,
						invoice_number	=> $invoice_number,
					});
}
sub show_plan {

    my $self         = shift;

    $self->function_orders();

	my $username    = $self->session->param( 'username' );
 
	my $planid      = ( $self->query->param( 'planid') )
		? $self->query->param( 'planid' )
		: $self->session->param( 'planid' );

    my $client    	= ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table( $client );

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/plan_info.html.tpl" );

    my $plan    	= $client->get_plan( $planid );

	# calculate whether the plan is plana, and if so, figure
	# out if the hours are over/under

	if ( $plan->{ plan } =~ /plana/i ) {
	
		my $is_plana = 1;
		$self->pb_param( is_plana => $is_plana );
		
		if ( $plan->{ hours_balance } < 0 ) {
			my $hours_bal_string = $plan->{ hours_balance };
			$hours_bal_string =~ s/-//;
			$hours_bal_string .= ' Hours Left';
			$plan->{ hours_balance } = $hours_bal_string;
		}
		else {
			$plan->{ hours_balance } .= ' Hours Over';
		}

		# see if any hours have been used this month, and act

		my $hours_used_this_month = $client->get_month_hours_used({ plan => $plan });

		if ( $hours_used_this_month ) {
			$self->pb_param( this_month_hours => $hours_used_this_month );
		}

	}

    while (my ($key, $value) = each (%$plan)) {
        $self->pb_param( $key => $value );
    }    

	my $change_status_click = $self->query->param( 'change_status_click' );
	my $operator			= $self->_get_operator_info( 'operator' );

	if ( $change_status_click == 1) {
		
		my $error = ISP::Error->new();

		$client->change_plan_status( { 
								error		=> $error,
								plan_id		=> $planid,
								operator	=> $operator,
							} );
		
		return $self->_process({ error => $error }) if $error->exists();

		if ( $client->get_plan_status( $planid ) eq 'hold' ) {

			$client->radius_password({
								password => $client->captcha(),
							});
		}
		elsif ( $client->get_plan_status( $planid ) eq 'active' ) {

			$client->radius_password({
								password => $client->plan_password({ plan_id => $planid }),
							});
		}
	}
	
	my $plan_status = $client->get_plan_status( $planid );

	$self->pb_param( plan_status => $plan_status );

	my $status_link = $self->self_link(
        do     				=> 'show_plan',
        username 			=> $username,
        id     				=> $planid,
		plan_status			=> $plan_status,
		change_status_click => 1,
	);

	# edit plan

	my $display_edit_plan_link = $self->self_link(
		do		=> 'display_edit_plan',
		id		=> $planid,
	);

	$self->pb_param( display_edit_plan_link	=> $display_edit_plan_link );

	# generate a random captcha for account delete

	my $captcha = $self->captcha();

	$self->pb_param( captcha			=> $captcha );

	$self->pb_param( plan_status_link 	=> $status_link );
	$self->session->param( 'planid', $planid );

	# get the user's RADIUS pw
	
	my $user_radius_password = $client->radius_password();	
	$self->pb_param( 'radius_password' => $user_radius_password );

	$self->session->clear( [ 'change_status_click' ] );

	if ( $self->DISPLAY_PLAN_STATS ) {

		$self->_display_plan_stats({ 
						plan		=> $plan,
				   		client		=> $client,
					});
	}

	return $self->pb_build();
}    
sub display_edit_client {

	my $self = shift;

	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

	my $username = $self->session->param( 'username' );
	$self->session->param( username => $username );

	my $client	 = ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/client_info_display_edit.html.tpl" );

	my $client_info = $client->client_info();

	my @manual_params = qw( tax_exempt billing_to_shipping );

	my $tax_exempt = ( $client->tax_exempt() eq 'Y' )
		? 1
		: 0;

	$self->pb_param( tax_exempt => $tax_exempt );

	for my $manual_param ( @manual_params ) {

				delete $client_info->{ $manual_param };
	}

	while ( my ( $client_info_field, $client_info_value ) = each %{ $client_info } ) {
		$self->pb_param( $client_info_field => $client_info_value );
	}	

	return $self->pb_build();

}
sub edit_client_info {

	my $self	= shift;

	$self->function_orders();

	my $username = $self->session->param( 'username' );
	my $client	 = ISP::User->new({ username => $username });

	my $vardb = ISP::Vars->new();
	my @client_info_struct = $vardb->struct( 'user_info' );
	
	my $updated_client_data;

	$updated_client_data->{ 'status' } = '';

	my $copy_billing_to_shipping = $self->query->param( 'billeqship' );

	for my $client_item ( @client_info_struct ) {

		if ( defined $self->query->param( $client_item ) ) { 
		
			if ( $copy_billing_to_shipping && $client_item =~ m{ \A shipping_ }xms ) {
				next;
			}

			my $item_value = $self->query->param( $client_item );
		
			# if we're copying from bill to ship

			if ( $client_item =~ m{ \A billing_ }xms && $copy_billing_to_shipping ) {
				
			  	$updated_client_data->{ $client_item } = $item_value;	
				$client_item =~ s/billing_/shipping_/;
				$updated_client_data->{ $client_item } = $item_value;

				next;
			}
		
			$updated_client_data->{ $client_item } = $item_value;
		}


	}

	my $update_success = $client->client_info({ 
						client_info => $updated_client_data,
					});

	if ( $update_success != 0 ) {
		
		my $error = ISP::Error->new();
		$error->add_trace();
		$error->add_message( "Client edit did not succeed" );
		$error->data( $updated_client_data );
	
		$self->_process( $error );
	};

	$self->forward( 'load_client_profile' );
}
sub display_edit_plan {

	my $self = shift;
	
	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

	my $plan_id	= $self->query->param( 'id' );
	my $username	= $self->session->param( 'username' );

	my $client = ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/plan_display_edit.html.tpl" );

	$self->pb_param( id	=> $plan_id );

	my $plan_info = $client->get_plan( $plan_id );

	# we'll clean out the html select statements first, so that
	# we can delete them from the plan_info hash before its crumbs
	# are passed to the tmpl

	# load up vars
    my $vardb    = ISP::Vars->new();

    # billing_method
    my $billing_method_select       = $vardb->build_select({ 
											type 	=> 'billing_method', 
											default => lc($plan_info->{ billing_method }),
										});
    $self->pb_param( billing_method => $billing_method_select );

    # pap date
    my $pap_date_select 	  		= $vardb->build_select({
											type 	=> 'pap_date', 
											default => $plan_info->{ pap_date } 
										});
    $self->pb_param( pap_date 		=> $pap_date_select );

    # pap method
    my $pap_method_select    		= $vardb->build_select({
												type	=> 'pap_method', 
												default => lc($plan_info->{ pap_method }) 
											});
    $self->pb_param( pap_method 	=> $pap_method_select );

	foreach ( qw(	
				billing_method
				pap_date
				pap_method
				hours_balance	
  			)
		  ) 
	{
				delete $plan_info->{ $_ };
	}

	while ( my ( $plan_field, $plan_value ) = each %{ $plan_info } ) {
		$self->pb_param( $plan_field => $plan_value );
	}	

	return $self->pb_build();
}
sub edit_plan {

	my $self = shift;

	$self->function_orders();

	my $username 			= $self->session->param( 'username' );
	my $plan_id				= $self->session->param( 'planid' );

	my $client				= ISP::User->new({ username => $username });
	my $current_plan_info	= $client->get_plan( $plan_id );

	my ( @plan_changes, @original_plan_value, @new_plan_value, %gui_plan_data );
	
	my $vardb		= ISP::Vars->new();
	my @plan_items	= $vardb->struct( 'plan_info' );

	# figure out which params from the gui contain plan_info
	# items, and populate a hash with that data

	for my $plan_item ( @plan_items ) {

		if ( defined $self->query->param( $plan_item ) ) {
			$gui_plan_data{ $plan_item } = $self->query->param( $plan_item );
		}
	}

	# now compare the hashes, find out what has changed,
	# and update the plan accordingly

	while ( my ( $key, $value ) = each %$current_plan_info ) {
			
		if ( exists $gui_plan_data{ $key } && $gui_plan_data{ $key } ne $current_plan_info->{ $key } ) {
			push @plan_changes, $key;
			push @original_plan_value,  $value;

			$current_plan_info->{ $key } = $gui_plan_data{ $key };
			push @new_plan_value, $current_plan_info->{ $key };
		}
	}

	return 1 if ! @plan_changes;

	my $error = ISP::Error->new();

	$client->write_plan_changes({
							error	=> $error,
							id		=> $plan_id,
							plan	=> $current_plan_info,
							change	=> \@plan_changes,
						});

	# add some notes regarding the plan edit

	my $operator	= $self->_get_operator_info( 'operator' );

	my @notes;

	for my $plan_item_changed ( @plan_changes ) {
		my $orig	= shift @original_plan_value;
		my $new		= shift @new_plan_value;

		my $note_builder
				= 	$plan_item_changed . " " .
					"changed from: " .
					$orig . " " .
					"to: " .
					$new;
		
		push @notes, $note_builder;
	}
	
	unshift @notes, "Plan: $current_plan_info->{ plan } ($plan_id) ";

	my $note	= join( '</pre><pre>', @notes );
	my $tag		= 'plan_change';

	$client->add_notes({
					operator	=> $operator,
					note		=> $note,
					tag			=> $tag,
				});

	return $self->_process({ error => $error }) if $error->exists();

	$self->forward( 'show_plan' );
}
sub display_add_plan {

    my $self    	= shift;
    my $username    = $self->query->param( 'username' );

    $self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

    my $client      = ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table($client);
	
	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/plan_add.html.tpl" );

    $self->pb_param( do      	=> 'add_plan' );
    $self->pb_param( username 	=> $username );

    # load up vars
    my $vardb    = ISP::Vars->new();

    # plan name
    my $plan_name_select  = $vardb->build_select({ type => 'plan' });
    $self->pb_param( plan => $plan_name_select );

    # plan status
    my $plan_status_select     		= $vardb->build_select({ type => 'plan_status', default => 'active' });
    $self->pb_param( plan_status 	=> $plan_status_select );

    # billing_method
    my $billing_method_select       = $vardb->build_select({ type => 'billing_method', default => 'email' });
    $self->pb_param( billing_method => $billing_method_select );

    # pap date
    my $pap_date_select 	  		= $vardb->build_select({ type => 'pap_date', default => '0' });
    $self->pb_param( pap_date 		=> $pap_date_select );

    # pap method
    my $pap_method_select    		= $vardb->build_select({ type => 'pap_method', default => 'none' });
    $self->pb_param( pap_method 	=> $pap_method_select );

    return $self->pb_build();
}
sub add_plan {

    my $self      = shift;

    $self->function_orders();

    my $username  = $self->query->param( 'username' );
    my $client    = ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/plan_add_process.html.tpl" );

    #$self->pb_param( username => $username );

    my @params = $self->query->param();

	my %plan_info;
    for (@params) {
        $plan_info{$_} = $self->query->param($_);
    }

	delete $plan_info{ do };

	my $error = ISP::Error->new();

    $client->add_plan({ plan_info => \%plan_info, error => $error });

	$error->add_message( "Invalid data" ) if $error->exists;
	return $self->_process({ data => \%plan_info, error => $error }) if $error->exists();

	return $self->pb_build();
}
sub delete_plan {

	my $self		= shift;

	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

	my $username 	= $self->query->param( 'username' );
	my $plan_id		= $self->query->param( 'id' );
	my $captcha		= $self->query->param( 'captcha' );
	my $confirm		= $self->query->param( 'confirm' );

	my $client = ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	my $operator    = $self->_get_operator_info( 'operator' );	
	
	if ( $self->captcha({ captcha => $captcha, input => $confirm }) eq 'ok' ) {
		$client->delete_plan( $plan_id, $operator );
	}

	return $self->pb_build();
}
sub show_notes {

	my $self		= shift;	

	$self->function_orders();

	my $username	= $self->session->param( 'username' );
	my $client		= ISP::User->new({ username => $username });
	
	$self->_header();
	$self->_client_info_table( $client );

	my $notes = $client->get_notes();
	
	$self->session->param( 'notes_loop', $notes ) if $notes;

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( 
						"$template_dir/show_notes.html.tpl",
						associate			=> $self->session(),
					);

	$self->_clear_session();

	return $self->pb_build();
}
sub add_notes {

	my $self		= shift;

	$self->session->save_param();

	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });
	}

	my $username	= $self->session->param( 'username' );
	my $client		= ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );	

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/add_notes.html.tpl", associate=>$self->session );

	# example...couldn't set non-existent param do.
	# we need session!

	$self->pb_param( do	=> 'process_notes' );
	$self->session->param( username	=> $username );

	my $vardb	= ISP::Vars->new();

	my $notes_class_select	= $vardb->build_select({ type => 'note_classification', default => 'technical' });
	$self->session->param( classification	=> $notes_class_select );

	my $operator	= $self->_get_operator_info( 'operator' );
	$self->session->param( operator	=> $operator );

	return $self->pb_build();
}
sub process_notes {

	my $self	= shift;

	$self->session->save_param();

	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

	my $username	= $self->session->param( 'username' );
	my $client		= ISP::User->new({ username => $username });

	#$self->_header();
	#$self->_client_info_table( $client );


	my %note_data	= (
				note		=>	$self->session->param( 'note' ),
				tag			=>	$self->session->param( 'note_classification' ),
				operator	=>	$self->session->param( 'operator' ),	
			);

	$client->add_notes( \%note_data );

	$self->_clear_session();

	return $self->forward( 'show_notes' );
}
sub display_purchase_form {

    my $self     	= shift;
    my $username    = $self->query->param( 'username' );

    $self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

    my $client     	= ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/purchase.html.tpl" );

    $self->pb_param( do       => 'confirm_purchase' );
    $self->pb_param( username => $username );

    my $vardb = ISP::Vars->new();

    my $payment_method_select = $vardb->build_select({ type => 'payment_method', default => 'visa' });
        $self->pb_param( payment_method => $payment_method_select );

    for (1..5) {

        my $plan_names_select = $vardb->build_select({ type => 'plan', default => 'none', name => "plan$_" });
        my $plan_varname = "plan" . $_;

        $self->pb_param( $plan_varname => $plan_names_select );

        my $tax_select = menu (
            name     	=> "tax${_}",
            values     	=> ['Yes', 'No'],
            labels  	=> {
                    Yes => 'Yes', 
                    No  => 'No',
                },
            default 	=> 'Yes',
        );

        $self->pb_param ( "tax_select${_}" => $tax_select );

    }

    return $self->pb_build();

}
sub confirm_purchase {

    my $self     	= shift;
    my $username    = $self->query->param( 'username' );
    my $client    	= ISP::User->new({ username => $username });

    $self->function_orders();

    $self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/purchase_confirm.html.tpl" );

	$self->pb_param( username 	=> $username );
	$self->pb_param( do			=> 'process_purchase' );

	# loop 5 times to ensure we get all entries
    #FIXME...there has GOT to be a better way to do this

	my $error = ISP::Error->new();

    my @transaction_items;

	my $payment_method = $self->query->param( 'payment_method' );
  
	$self->pb_param( payment_method => $payment_method );

	my ( $grand_total_untaxed, $tax_total );

	for my $item_num (1..5) {

        last unless $self->query->param( "amount${item_num}");

		my $amount		= $self->query->param( "amount${item_num}" );
		my $quantity	= $self->query->param( "quantity${item_num}" );
		my $tax			= $self->query->param( "tax${item_num}" );
		my $comment		= $self->query->param( "comment${item_num}" );
		my $item_name	= $self->query->param( "plan${item_num}" );

		if ( $item_name =~ 'none' ) {
			
			$error->add_trace();
			$error->add_message( "The item field can not be left blank" );

			return $self->_process({ data => { Item => 'blank' }, error => $error });
		}

		$tax = ( $tax eq 'Yes' ) 
			? $self->tax_rate( 'hst' ) 
			: 0;

		my $item_total 			= ( $amount * $quantity );

		#FIXME: tax is being disregarded...we'll let Ledger deal with it
		# for now, until we get the core processes done 

		my $item_tax 			= ( $item_total * $tax );
		$tax_total				+= $item_tax;
	
		$grand_total_untaxed	+= $item_total;
		
		$item_total				= sprintf( '%.2f', $item_total );

		$self->pb_param( "item${item_num}"			=> 1 );
		$self->pb_param( "item${item_num}amount" 	=> $amount );
		$self->pb_param( "item${item_num}qty"		=> $quantity );
		$self->pb_param( "item${item_num}name"		=> $item_name );
		$self->pb_param( "item${item_num}tax"		=> $tax );
	}

	my $grand_total_with_tax	= ($grand_total_untaxed + $tax_total );
	$grand_total_with_tax		= sprintf ( '%.2f', $grand_total_with_tax );
	$grand_total_untaxed		= sprintf ( '%.2f', $grand_total_untaxed );
	$tax_total					= sprintf ( '%.2f', $tax_total );

	$self->pb_param( tax_total	=> $tax_total );
	$self->pb_param( subtotal	=> $grand_total_untaxed );
	$self->pb_param( total		=> $grand_total_with_tax );

	my $vardb = ISP::Vars->new();

	if ( $vardb->is_credit_card( $payment_method )) {
			$self->pb_param( cc => 1 );
	}

	$self->_footer();

	return $self->pb_build();
	
}
sub process_purchase {

    my $self     	= shift;
    my $username    = $self->query->param( 'username' );
    my $client    	= ISP::User->new({ username => $username });

    $self->function_orders();

    $self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
    #$self->pb_template( "$template_dir/purchase_complete.html.tpl" );

    # loop 5 times to ensure we get all entries
    #FIXME...there has GOT to be a better way to do this

    my @transaction_items;

	my $payment_method	= $self->query->param( 'payment_method' );
  	my $total_amount	= $self->query->param( 'total' );

   	for my $item_num (1..5) {

        last unless $self->query->param( "item${item_num}amount");

		my $amount			= $self->query->param( "item${item_num}amount" );
		my $quantity		= $self->query->param( "item${item_num}qty" );
		my $comment			= $self->query->param( "item${item_num}name" );
		my $item_name		= $self->query->param( "item${item_num}name" );
		my $payment			= 0;

        my $tax = $self->query->param( "item${item_num}tax" );
		$tax = 0 if ! $tax;

        my $transac_info = {
            item_name    	=> $item_name, 
            comment        	=> $comment, 
            amount        	=> $amount, 
            quantity    	=> $quantity, 
            payment_method  => $payment_method, 
            payment        	=> $payment,
            tax        		=> $tax,
        };

        push @transaction_items, $transac_info;

    }

    my $first_item = shift @transaction_items;

    my $error = ISP::Error->new();
	my $transac = ISP::Transac->create_transaction({
									data	=> $first_item, 
									error	=> $error
								});

    # error check
    return $self->_process({ data => $first_item, error => $error }) if $error->exists();

    for my $line_item (@transaction_items) {

        $transac->add_transaction_line({ 
							data => $line_item, 
							error => $error
						});

        # error check
        return $self->_process({ data => $line_item, error => $error }) if $error->exists();
    }
	
	my $payment_via_credit = $self->query->param( 'cc' );
	my $bank_response;
	
	if ( $payment_via_credit ) {

		$bank_response
			= $self->initialize_credit_payment({
								error	=> $error,
								amount	=> $total_amount,
							});

		# return the pb_build if there was a bank error!

		if ( $bank_response == 1 ) {
				return $self->pb_build();
		}
	}

    my $transac_invoice_number
		= $transac->purchase({
						client			=> $client, 
						bank_receipt	=> $bank_response,
						error			=> $error
					});

	$self->_clear_session();

	return $self->_process({ error => $error }) if $error->exists();

	$self->display_invoice({
						invoice_number	=> $transac_invoice_number,
						is_method_call	=> 1,
						print			=> 1,
					});
}
sub display_payment_form {

    my $self     	= shift;
    my $username    = $self->query->param( 'username' );

    $self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

    my $client = ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/payment.html.tpl" );
    
    # retrieve the payment methods
    
    my $vardb        = ISP::Vars->new();

    my $payment_method_select = $vardb->build_select({ type => 'payment_method', default => 'visa' });

    $self->pb_param( payment_method => $payment_method_select );
    $self->pb_param( date         	=> $self->string_date() );
    $self->pb_param( username     	=> $username );
    $self->pb_param( do         	=> 'confirm_payment' );
    
    $self->_footer();

    return $self->pb_build;

}
sub confirm_payment {

    my $self    	= shift;
    my $username    = $self->query->param( 'username' );

    $self->function_orders();
    my $client     = ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/payment_confirm.html.tpl" );

	$self->pb_param( do			=> 'process_payment' );  
	$self->pb_param( username	=> $username );
	

	my $payment_method	= $self->query->param( 'payment_method' );
	my $comment			= $self->query->param( 'comment' );
	my $payment			= $self->query->param( 'payment' );
	my $date			= $self->string_date(); 

	$self->pb_param( comment	=> $comment );
	$self->pb_param( payment	=> $payment );
	$self->pb_param( date		=> $date );

    my %payment_data = (
        payment_method  => $payment_method, 
        quantity    	=> 1,
        item_name    	=> 'ROA',
        comment        	=> $comment, 
        amount        	=> 0,
        payment        	=> $payment,  
        tax        		=> 0,
    );

	my $error = ISP::Error->new();
    return $self->_process({ data => \%payment_data, error => $error }) if $error->exists();

	$self->pb_param( payment_method => $payment_method );

	my $vardb = ISP::Vars->new();

	if ( $vardb->is_credit_card( $payment_method ) ) {
		$self->pb_param( cc => 1 );
	}

	$self->_footer();

	return $self->_process({ error => $error }) if $error->exists();
	return $self->pb_build();

}
sub process_payment {

    my $self    	= shift;
    my $username    = $self->query->param( 'username' );

    $self->function_orders();
 
	my $client     	= ISP::User->new({ username => $username });

	$self->_header();
    $self->_client_info_table($client);

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/payment_complete.html.tpl" );

	my $payment 		= $self->query->param( 'payment' );
	my $comment			= $self->query->param( 'comment' );
	my $payment_method	= $self->query->param( 'payment_method' );
	my $bank_response;

    my %payment_data = (
        payment_method  => $payment_method,
        quantity    	=> 1,
        item_name    	=> 'ROA',
        comment        	=> $comment,
        amount        	=> 0,
        payment        	=> $payment,
        tax       		=> 0,
    );

	my $error = ISP::Error->new();
    my $transaction = ISP::Transac->create_transaction({
										data	=> \%payment_data, 
										error	=> $error
									});

    # error check!
    return $self->_process({ data => \%payment_data, error => $error }) if $error->exists();

	# do the bank stuff...

	my $payment_via_credit = $self->query->param( 'cc' );

	if ( $payment_via_credit ) {
			
		$bank_response
			= $self->initialize_credit_payment({
								error	=> $error,
								amount	=> $payment,
							});

		# return the pb_build if there was a bank error!

		if ( $bank_response == 1 ) {
				return $self->pb_build();
		}
	}
	my $transac_invoice_number 
		= $transaction->payment({
						client			=> $client,
					    bank_receipt	=> $bank_response,	
						error			=> $error,
					});

	$self->_render_error( $error ) if $error->exists();

	$self->_clear_session();

	return $self->_process({ error => $error }) if $error->exists();

	$self->display_invoice({
				invoice_number	=> $transac_invoice_number,
				is_method_call	=> 1,
				print			=> 1,
			});

}    
sub display_renew_form {

	my $self		= shift;
	my $username	= $self->query->param( 'username' );

	$self->function_orders();

	if ( $self->MASTER_LOCKED() ) {
		my $error = ISP::Error->new();
		$error->add_trace();
		$self->_write_protected({ error => $error });

		return $self->_process({ error => $error });

	}

	my $client = ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/renew.html.tpl" );

	$self->pb_param( do			=> 'display_renew_confirm' );
	$self->pb_param( username 	=> $username );

	my @plans		= $client->get_plans();
	my $plan_iter	= 1;

	for my $plan ( @plans ) {

		if ( $plan->{ expires } =~ /0000/ && $plan->{ plan } !~ /plana/i ) {
			
			my $nothing_to_renew =	"" .
				"This client doesn't have any renewable plans.<br><br>" .
				"The plan may not have an expiry date set.<br>";

			$self->pb_param( 
						nothing_to_renew => $nothing_to_renew 
					);
			return $self->pb_build();
		}

		$self->pb_param( "plan${plan_iter}"			=> "plan${plan_iter}" ) ;
		$self->pb_param( "plan${plan_iter}name"		=> $plan->{plan} );
		$self->pb_param( "plan${plan_iter}id"		=> $plan->{id} );
		$self->pb_param( "plan${plan_iter}rate"		=> $plan->{rate} );
		$self->pb_param( "plan${plan_iter}expires"	=> $plan->{expires} );	
	
		$plan_iter++;
	}

	my $vardb 					= ISP::Vars->new();
	my $payment_method_select	= $vardb->build_select({ type => 'payment_method', default => 'visa' });
	$self->pb_param( payment_method => $payment_method_select );

	$self->_footer();
	
	return $self->pb_build();
}
sub display_renew_confirm {

	use ISP::User;

	my $self 		= shift;
	my $username	= $self->query->param( 'username' );

	$self->function_orders();

	my $client	= ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/renew_confirm.html.tpl" );

	$self->pb_param( do			=> 'process_renew' );
	$self->pb_param( username	=> $username );

	# 1..5 until we find a better way to handle numbered params

	my @renewal_entries;
	my $renewal_sub_total;

	COLLECT_PARAMS:

	for my $renew_count (1..5) {
	
		my $plan_id		= $self->query->param( "plan${renew_count}id" );
		my $quantity	= $self->query->param( "plan${renew_count}qty" );
		my $plan_name	= $self->query->param( "plan${renew_count}name" );
		my $plan_rate 	= $self->query->param( "plan${renew_count}rate" );

		next COLLECT_PARAMS 
			if ! defined $plan_id;  
		
		next COLLECT_PARAMS	
			if $quantity < 1;

		$renewal_sub_total  += ( $quantity * $plan_rate );
		
		$self->pb_param( "plan${renew_count}"			=> "plan${renew_count}" );
		$self->pb_param( "plan${renew_count}name"		=> $plan_name ); 
		$self->pb_param( "plan${renew_count}id"			=> $plan_id ); 
		$self->pb_param( "plan${renew_count}qty"		=> $quantity );
		$self->pb_param( "plan${renew_count}rate"		=> $plan_rate );
	}

	my $total_amount;

	my $tax_exempt = $client->tax_exempt();

	if ( $tax_exempt eq 'N' ) {
		my $tax_rate	= $self->tax_rate( 'hst' );
		my $tax 		= sprintf( '%.2f', ( $renewal_sub_total * $tax_rate ));
		$total_amount	= ( $renewal_sub_total + $tax );
		$self->pb_param( tax => $tax );
	}
	else {
		$total_amount = $renewal_sub_total;
	}

	$total_amount = sprintf( "%.2f", $total_amount );

	$self->pb_param( total_amount => $total_amount );

	my $payment_method = $self->query->param( 'payment_method' );
	$self->pb_param( payment_method => $payment_method );

	my $vardb = ISP::Vars->new();

	if ( $vardb->is_credit_card( $payment_method ) ) {
		$self->pb_param( cc => 1 );
	}

	$self->_footer();

	return $self->pb_build();
}
sub process_renew {

	my $self		= shift;
	my $username	= $self->query->param( 'username' );

	$self->function_orders();

	my $client		= ISP::User->new({ username => $username });
	my $error		= ISP::Error->new();

	$self->_header();
	$self->_client_info_table( $client );

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/renew_process.html.tpl" );

	my $amount			= $self->query->param( 'total_amount' );
	my $tax				= $self->query->param( 'tax' );
	my $payment_method	= $self->query->param( 'payment_method' );
	my $bank_response;

	my $payment_via_credit = $self->query->param( 'cc' );

	if ( $payment_via_credit ) {

		$bank_response 
			= $self->initialize_credit_payment({
								error	=> $error,
								amount	=> $amount,
							});

		# return the pb_build if there was a bank error!

		if ( $bank_response == 1 ) {
			return $self->pb_build();  
		}
	}

	my @renewal_line_items;

	COLLECT_PARAMS:

	for my $renew_count (1..5) {
	
		my $plan_id		= $self->query->param( "plan${renew_count}id" );
		my $quantity	= $self->query->param( "plan${renew_count}qty" );
		my $plan_name	= $self->query->param( "plan${renew_count}name" );
		my $plan_rate 	= $self->query->param( "plan${renew_count}rate" );

		next COLLECT_PARAMS
			if ! defined $plan_id;
	
		my $plan_ref	= $client->get_plan( $plan_id );
		my $item_name 	= "$quantity x $plan_name";

		my %renewal_transac_data = (	
							payment_method	=> $payment_method,
							amount			=> $plan_rate,
							comment			=> $item_name,
							payment			=> 0,
							quantity		=> $quantity,
							tax				=> $self->tax_rate( 'hst' ),
							item_name		=> $plan_name,
						);

		push @renewal_line_items, \%renewal_transac_data;

		my $plan_item_to_update;

		if ( $plan_name =~ /plana/i ) {

			my $new_hours = $client->plan_hours({
			   									error		=> $error,
												id			=> $plan_id,
												quantity	=> $quantity,
											});

			$plan_item_to_update = [ 'hours_balance', 'plan_status' ];

			$plan_ref->{ hours_balance }= $new_hours;
			
			# if the user is on hold, revert the password

			if ( $plan_ref->{ plan_status } eq 'hold' ) {

				$client->radius_password({
									password => $client->plan_password({ plan_id => $plan_id }),
								});


				my $note = "Renewal triggered account to change from hold to active. Password reset";

				$client->add_notes({
								tag			=> 'plan_change',
								note		=> $note,
							});
			}

			$plan_ref->{ plan_status } 	= 'active';
		}
		else {	

			my $new_expiry	= $client->modify_plan_expiry({
												error		=> $error,
												id			=> $plan_id,
												quantity	=> $quantity,
											});
	
			$plan_item_to_update = [ 'expires', 'plan_status' ];

			$plan_ref->{ expires } 		= $new_expiry;

			# reset the radius pw if the account was on hold

			if ( $plan_ref->{ plan_status } eq 'hold' ) {

				$client->radius_password({
								password => $client->plan_password({ plan_id => $plan_id }),
							 });

				 my $note = "Renewal triggered account to change from hold to active. Password reset";

				$client->add_notes({
								tag			=> 'plan_change',
								note		=> $note,
							});
			 }	 

			$plan_ref->{ plan_status }	= 'active';
		}

		return $self->_process({ data => $plan_ref, error => $error }) if $error->exists();	
		
		$client->write_plan_changes({
							error 	=> $error,
							id		=> $plan_id,
							plan	=> $plan_ref,
							change	=> $plan_item_to_update,
						});
	
		return $self->_process({ data => $plan_ref, error => $error }) if $error->exists();	
	}


	my $first_line_item = shift @renewal_line_items;

	my $sanity = ISP::Sanity->new();
	
	my $renewal_transac = ISP::Transac->create_transaction({
										data	=> $first_line_item,
										error	=> $error,
									});

	return $self->_process({ data => $first_line_item, error => $error }) if $error->exists();
	
	for my $new_line_item ( @renewal_line_items ) {
		

		$renewal_transac->add_transaction_line({
						data	=> $new_line_item,
						error	=> $error,
					});
		return $self->_process({ data => $new_line_item, error => $error }) if $error->exists();
	}
	
	my $transac_invoice_number
		= $renewal_transac->renew({
							client			=> $client, 
							bank_receipt	=> $bank_response,
							error			=> $error,
						});

	$self->_clear_session();
	
	$self->display_invoice({ 
						invoice_number	=> $transac_invoice_number,
						is_method_call	=> 1,
						print			=> 1,
					});

}
sub display_uledger {

    my $self     = shift;
    my $username = shift;

    $username = $self->query->param('username') unless $username;

    $self->function_orders;
    my $client    = ISP::User->new({ username => $username });

    $self->_header();
    $self->_client_info_table($client);

    my $ledger 	= ISP::Ledger->new();
    my $uledger = $ledger->get_uledger({ username => $username });

	for my $uledger_entry ( @$uledger ) {
		
		my $invoice_link = $self->self_link(
			do				=> 'display_invoice',
			invoice_number	=> $uledger_entry->{ invoice_number },
			username		=> $uledger_entry->{ username },
		);
		$uledger_entry->{ invoice_link } = $invoice_link ;
	}

    my $template_dir = $self->TEMPLATE_DIR();
	my $template 
		= $self->load_tmpl( "$template_dir/uledger.html.tpl" );

    $template->param(ULEDGER_ENTRIES => $uledger);
	my $html .= $self->pb_build();
	$html 	 .= $template->output;
	return $html;
}
sub display_invoice {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();
	
	my $is_method_call	= ( $params->{ is_method_call } )
		? $params->{ is_method_call }
		: 0;

	my $invoice_number	= ( $params->{ invoice_number } )
		? $params->{ invoice_number }
		: $self->query->param( 'invoice_number' );

	my $username = ( $self->query->param( 'username' ) )
		? $self->query->param( 'username' )
		: $self->session->param( 'username' );

	$username = $params->{ username } if $params->{ username };

	my $printable_invoice = ( $params->{ print } )
		? $params->{ print }
		: $self->query->param( 'print' );

	my $client = ISP::User->new({ username => $username });

	my $template_dir = $self->TEMPLATE_DIR();
	my $template = $self->load_tmpl( "$template_dir/display_invoice.html.tpl" );
	
	if ( ! $is_method_call && ! $printable_invoice ) {
		
		$self->_header();
		$self->_client_info_table( $client );

		my $email_invoice_link
			= $self->self_link(
						do				=> 'email_invoice',
						invoice_number	=> 'invoice_number',
					);

		my $printable_invoice_link 
			= $self->self_link(
						do				=>	'display_invoice',
						invoice_number	=> $invoice_number,
						username		=> $username,
						print	=> 1,
					);

		$template->param( email_invoice		=> $email_invoice_link );
		$template->param( printable_invoice => $printable_invoice_link );			
	}
	elsif ( ! $is_method_call && $printable_invoice ) {
		$template->param( print => 1 );
		$self->_receipt_header();
	}
	else {
		
		# it's a method call, so load the session

		$self->session();
		my $printable_invoice_link = $self->self_link(
			do				=> 'display_invoice',
			invoice_number	=> $invoice_number,
			print			=> 1,
		);
	
		my $email_invoice_link
			= $self->self_link(
						do				=> 'email_invoice',
						invoice_number	=> 'invoice_number',
					);


		$template->param( printable_invoice => $printable_invoice_link );
		$template->param( email_invoice		=> $email_invoice_link );

		$self->_blank_header();
	}

	$self->session->param( invoice_number		=> $invoice_number );	

	my $ledger	= ISP::Ledger->new();

	my $invoice	= $ledger->get_gledger({ invoice_number => $invoice_number });

	my $template_loop_data; # aref

	my $date			= $invoice->[0]->{ date };
	my $payment_method	= $invoice->[0]->{ payment_method };
	my $payment;

	my ( $tax, $sub_total, $grand_total, $is_poa );

	for my $line_item ( @$invoice ) {
		
		# grab out the GST/hst line item

		if ( $line_item->{ item_name } eq 'GST' || $line_item->{ item_name } eq 'Tax' ) {
			$tax	+= $line_item->{ total_price };
			next;
		}
		
		if ( $line_item->{ item_name } eq 'ROA' && ! $is_poa ) {
			$is_poa = 1;
			$template->param( is_poa => $is_poa );
			$line_item->{ is_poa } = $is_poa;
		}

		# delete the hash items we don't need anymore
		
		foreach ( qw( date id username payment_method invoice_number ) ) {
			delete $line_item->{ $_ };
		}

		$payment   += $line_item->{ payment };
		$sub_total += $line_item->{ total_price };

		push @$template_loop_data, $line_item;
	}

	$sub_total		= ( sprintf ( '%.2f', $sub_total ) );

	$tax = 0 if ! $tax;

	$tax = ( sprintf ( '%.2f', $tax ));

	$grand_total 	= ( sprintf ( '%.2f', ( $sub_total + $tax )) );

	# FIXME: dirty check for payment

	if ( $grand_total eq '0.00' ) {
		$grand_total = ( sprintf( '%.2f', $payment ) );
	}

	my $transac_type;

	if ( $payment_method eq 'invoice' ) {
		$transac_type = 'Invoice';
	}
	else {
		$transac_type = 'Receipt';
	}

	$template->param( invoice_number	=> $invoice_number );
	$template->param( username			=> $username );
	$template->param( type				=> $transac_type );
	$template->param( items				=> $template_loop_data );
	$template->param( tax 				=> $tax );
	$template->param( date				=> $date );
	$template->param( payment_method 	=> $payment_method );
	$template->param( sub_total 		=> $sub_total );
	$template->param( grand_total 		=> $grand_total );

	# prep to display the bank statement

	my $vardb = ISP::Vars->new();
	my $is_credit_payment = $vardb->is_credit_card( $payment_method );

	if ( $is_credit_payment ) {

		my $bank_receipt
			= $ledger->bank_receipt({ invoice_number => $invoice_number });
		$template->param( bank_receipt => $bank_receipt );
	}

	my $html	.= $self->pb_build();
	$html	 	.= $template->output();

	return $html;
}
sub email_invoice {

	my $self	= shift;

	$self->function_orders();

	$self->_header();

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template(
			"$template_dir/email_invoice_to_client.html.tpl"
		);

	my $invoice_number = $self->_session_extract( 'invoice_number', 1 );

	my $username		= $self->session->param( 'username' );

	$self->pb_param( username		=> $username );
	$self->pb_param( invoice_number	=> $invoice_number );

	my $billing = ISP::Billing->new();

	my $email_ok = $billing->email_bill({ invoice => $invoice_number });

	if ( $email_ok ) {
		$self->pb_param( success => 1 );
	}

	return $self->pb_build();
}
sub initialize_credit_payment {

		my $self 	= shift;
		my $params	= shift;
	
		$self->function_orders();

		my $amount	= $params->{ amount };
		my $error	= $params->{ error };

		# do the standard death if we don't receive
		# an error obj

		if ( ! defined $error ) {
			my $error = ISP::Error->new();
			$error->bad_api();
		}

		my $card_number	= $self->query->param( 'ccn' );
		my $card_expiry = $self->query->param( 'cce' );
		my $card_holder = $self->query->param( 'chn' );

		my %transaction_data = (
						DollarAmount	=> $amount,
						Card_Number		=> $card_number,
						Expiry_Date		=> $card_expiry,
						CardHoldersName	=> $card_holder,
					);

		my $transac 	= ISP::Transac->new();

		my @bank_response 
			= $transac->credit_card_payment({
						error				=> $error,
						transaction_data	=> \%transaction_data,
					});	
		
		my $bank_response 
			= $self->process_bank_response( @bank_response );

		return $bank_response;
}
sub process_bank_response {
	
	my $self					= shift;
	my @bank_response			= @_;

	$self->function_orders();

	my $bank_response_code 		= $bank_response[0];
	my $bank_response_msg		= $bank_response[1];

	my $bank_response_receipt	= $bank_response[2] 
		if exists $bank_response[2];

	my $bank_response_errstr	= "$bank_response_code: $bank_response_msg";
			
	if ( $bank_response_code eq '00' ) {

		return $bank_response_receipt;
	}
	else {
	
		$self->pb_param( bank_response => $bank_response_errstr );

		# caller is looking for "is_error", so return true
		# if there is one

		return 1; 
	}
}
sub _receipt_header {

	my $self = shift;

	$self->function_orders();

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( 
			"$template_dir/receipt_header.html.tpl",
	   		die_on_bad_params => $self->DIE_ON_BAD_PARAMS(),
		);

	# same as _header()...
	# check to see if we're operating on a development system and
	# notify the user. We don't want to confuse production boxes
	# and development ones

	my $software_version = $self->VERSION();
	
	if ( $software_version =~ /d$/ ) {

		my $is_devel_system = 1;
		$self->pb_param( is_devel_system => $is_devel_system );
	}

	$self->pb_param( js_lib => $self->JAVASCRIPT_LIBRARY() );
}

#
# client info and stats
#
sub _client_info_table {

    my $self   = shift;
	my $client = shift;
    
	$self->function_orders();

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( 
			"$template_dir/client_info_table.html.tpl",
	   		die_on_bad_params => $self->DIE_ON_BAD_PARAMS(),
		);

    my $username = $client->username();
   
   	# return the build if no such user

	if ( ! $username ) {
		$self->pb_param( 'no_user_found', "No such user found" );
		return $self->pb_build();
	}

	my @plans = $client->get_plans();

    my $plan_iter = 1;
    my $link;

    for (@plans) {

        my $planid = $_->{id};
        
        $link = $self->self_link( 
                do     		=> 'show_plan',
                username 	=> $username,
                planid     	=> $planid,
         );

        $self->pb_param( "plan${plan_iter}_link" => $link );
        $self->pb_param( "plan${plan_iter}"     => $_->{plan} );

        $plan_iter++;
    }

    $self->pb_param( user => $username );

    my $links = [

        # renewal
        $self->self_link( username => $username, do => 'display_renew_form', ),

        # payment
        $self->self_link( username => $username, do => 'display_payment_form', ),

        # purchase
        $self->self_link( username => $username, do => 'display_purchase_form',    ),

        # add_plan
        $self->self_link( username => $username, do => 'display_add_plan', ),

        # display uledger
        $self->self_link( username => $username, do => 'display_uledger', ),

        # see notes
        $self->self_link( username => $username, do => 'show_notes', ),

        # add notes
        $self->self_link( username => $username, do => 'add_notes', ),
    ];

    $self->pb_param( renewal_link   => @$links[0]);
    $self->pb_param( payment_link   => @$links[1]);
    $self->pb_param( purchase_link  => @$links[2]);
    $self->pb_param( add_plan_link  => @$links[3]);
    $self->pb_param( uledger_link   => @$links[4]);
    $self->pb_param( show_notes_link => @$links[5]);
    $self->pb_param( add_notes_link => @$links[6]);

	my $ledger  = ISP::Ledger->new();
	my $balance = $ledger->balance({ username => $username });

	$self->pb_param( balance => $balance );

	# go back to client main screen
    my $client_home_link = $self->self_link(
        do        	=> 'load_client_profile',
        username    => $username,
    );

    $self->pb_param( client_home_link => $client_home_link );

    if ($self->DISPLAY_CONTACT_INFO() and $self->query->param('do') eq 'load_client_profile') {
        $self->_contact_info_table($client);
    }

	$self->session->param( username => $username );
}
sub client_info_detail {

	my $self		= shift;
	
	$self->function_orders();

	my $username 		= $self->session->param( 'username' );
	my $client			= ISP::User->new({ username => $username });

	$self->_header();
	$self->_client_info_table( $client );

	my $template_dir	= $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/client_info_detail.html.tpl" );

	my $client_info 	= $client->client_info();

	for ( keys %$client_info ) {
		$self->pb_param( $_ => $client_info->{ $_ } );
	}

	return $self->pb_build();
}
sub _display_plan_stats {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $plan		= $params->{ plan };
	my $client		= $params->{ client };

	my $plan_stats = $client->get_monthly_login_totals({ plan => $plan });

	if ( $plan_stats ) {
		my $template_dir = $self->TEMPLATE_DIR();
		$self->pb_template( "$template_dir/plan_stats.html.tpl" );
		$self->pb_param( plan_stats	=> $plan_stats );
	}
}
sub  _contact_info_table {

    my $self   = shift;
    my $client = shift;

    $self->function_orders();

	my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/contact_info_table.html.tpl" );

    my %contact_info = (
            street         	=> $client->street,
            name         	=> $client->fullname,
            city        	=> $client->billing_town,
            zip        		=> $client->billing_postal_code,
            work_phone    	=> $client->work_phone,
            home_phone    	=> $client->home_phone,
            fax        		=> $client->fax,
    );

    for (keys %contact_info) {
        $self->pb_param( $_ => $contact_info{$_} );
    }

	my $display_edit_client_link = $self->self_link(
		do		=> 'display_edit_client',
	);

	my $display_client_details_link = $self->self_link(
			do	=> 'client_info_detail',
	);

	$self->pb_param( display_edit_client_link	=> $display_edit_client_link );
	$self->pb_param( display_client_details_link => $display_client_details_link );
}            

#
# Reporting
#
sub reports {

	my $self	= shift;

	$self->function_orders();

	$self->_header();

	my $template_dir	= $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/reports.html.tpl" );

	return $self->pb_build();
}
sub exec_report {

	my $self	= shift;
	$self->function_orders();

	# create an aref containing an href for the session
	# data prior to storage

	my $report_to_exec = $self->query->param( 'report' );

	my $report_session_data  
	  = {			
				report	=> $report_to_exec,
				opt1	=> $self->query->param( 'opt1' ),
				opt2	=> $self->query->param( 'opt2' ),
		};

	$self->session->param( 'REPORT', $report_session_data );

	$self->forward( $report_to_exec );
}
sub income_by_payment_type {

	use ISP::Reports;

	my $self	= shift;

	$self->function_orders();
	
	my $options 
	  = $self->_session_extract( 'REPORT', 1 );

	my $date					= $options->{ opt1 };
	my $distribution_account 	= $options->{ opt2 };

	$self->_header();

	my $report = ISP::Reports->new();

	my $report_data	
	  = $report->income_by_payment_type({
											account => $distribution_account,
											date => $date,
										});

	for my $account ( @$report_data ) {

		for my $entry ( @{ $account->{ entries } } ) {

			my $invoice_link = $self->self_link(
					do				=> 'display_invoice',
					invoice_number	=> $entry->{ invoice_number },
					username		=> $entry->{ username },
				);

			$entry->{ invoice_link } = $invoice_link ;
		}
	}

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/income_by_payment_type.html.tpl" );

	$self->pb_param( report_data => $report_data );

	return $self->pb_build();
}
sub income_by_item {

	my $self	= shift;

	$self->function_orders();	

	my $options
	  = $self->_session_extract( 'REPORT', 1 );

	my $date	= $options->{ opt1 };
	my $item	= $options->{ opt2 };

	$self->_header();

	my $report 		= ISP::Reports->new();
	my $report_data	= $report->income_by_item({
									date	=> $date,
									item	=> $item,
								});

	my $template_dir = $self->TEMPLATE_DIR();
	$self->pb_template( "$template_dir/income_by_item.html.tpl" );

	$self->pb_param( report_data => $report_data );

	return $self->pb_build();
}
sub unused_service {

	my $self	= shift;

	my $options
	  = $self->_session_extract( 'REPORT', 1 );

	my $type = $options->{ opt1 }; # hours/months
	
	$self->_header();

	my $report	= ISP::Reports->new();
	my $report_data;

	my $template_dir = $self->TEMPLATE_DIR;

	if ( $type eq 'months' ) {

		$report_data = $report->unused_service();
		
		$self->pb_template( "$template_dir/unused_service_months.html.tpl" );
		$self->pb_param( report_name => 'Unused Service -- Months' );
	}
	else {

		my $error = ISP::Error->new();

		$self->pb_template( "$template_dir/unused_service_hours.html.tpl" );
		$self->pb_param( report_name => 'Unused Service -- Hours' );

		$report_data = $report->unused_service({
											hours	=> 1,
											error	=> $error,
										});

		if ( ref( $report_data ) eq 'ISP::Error' ) {

			$error = $report_data;
			return $self->_process({ error => $error }) if $error->exists();
	
		}
	}

	my $service_totals = shift @$report_data;
	my $service_data = shift @$report_data;

	$self->pb_param( service_totals => $service_totals );
	$self->pb_param( service_data => $service_data );

	return $self->pb_build();
}
#
# session
#
sub _clear_session {

	my $self	= shift;
	my $params	= shift;

	$self->function_orders();

	my $only_save_profile = $params->{ except_profile };

	if ( $only_save_profile ) {

		my $profile		= $self->session->param( 'OPERATOR_PROFILE' );
		my $login_status	= $self->session->param( 'logged_in' );
		
		$self->session->clear();
	
		$self->session->param( 'OPERATOR_PROFILE', $profile );
		$self->session->param( 'logged_in', $login_status );
	}
	else {
		
		my $profile			= $self->session->param( 'OPERATOR_PROFILE' );
		my $username		= $self->session->param( 'username' );
		my $login_status	= $self->session->param( 'logged_in' );

		$self->session->clear();

		$self->session->param( 'OPERATOR_PROFILE', $profile );
		$self->session->param( 'username', $username );
		$self->session->param( 'logged_in', $login_status );
	}
	
	return 0;
}
sub _session_extract {

	my $self			= shift;
	my $section			= shift;
	my $delete_after	= shift;

	my $session_data = $self->session->param( $section );

	if ( $delete_after ) {

		$self->session->clear( $section );
		$self->session->flush();
	}

	return $session_data;
}

sub DESTROY {
                 
        my $self = shift;
        $self->function_orders();
}

=head1 NAME

ISP::GUI::Accounting - This module is the complete web GUI for the ISP accounting system.

=head1 VERSION

=cut

our $VERSION = sprintf ("%d", q$Revision: 165 $ =~ /(\d+)/);

=head1 SYNOPSIS

    # In the CGI script visible to the web server (accounting.cgi)

    use ISP::GUI::Accounting;
    my $gui = ISP::GUI::Accounting->new();
    $gui->run();

=head1 DESCRIPTION

This module is responsible for generating HTML pages and providing API's for all
operations relating to the ISP Accounting web GUI.

=head1 METHODS

=head2 setup ()

Initializes an empty CGI::Application, defines the run modes, and sets the starting
run mode.

The mode parameter for this module is 'do'.

Takes no arguments, and there is no return.

=head2 home (USERNAME)

Generates the users plan information that is included in each accounting web page.

If the optional scalar string USERNAME is not supplied, we will look for it within 
any incoming CGI parameters. If both fail, we will default to supplying a text box
where the operator can enter the USERNAME in directly.

This method MUST call $self->_header() and $self->_footer(). It SHOULD call
$self->_client_info_table().

=head2 show_plan

Displays the details of the current user's plan. Takes no params, there is no
return.

=head2 display_add_plan

Provides an input form for the addition of a new plan for the current user.

Takes no params, returns to the add_plan template.

=head2 add_plan

Sends the collected new plan data into User for verification.

Takes no params, there is no return.


=head2 display_purchase_form

Generates the payment form

Takes no parameters. All parameters are passed in via CGI. Returns the pb_build.

This method MUST call $self->_header() and $self->_footer(). It SHOULD call
$self->_client_info_table().

=head2 process_purchase

This method takes the input from the display_purchase_form(), and hands off to ISP::Transac
for final processing.

=head2 display_payment_form

Generates the payment form.

Takes no parameters. All parameters are passed in via CGI. Returns the pb_build.

This method MUST call $self->_header() and $self->_footer(). It SHOULD call
$self->_client_info_table().

=head2 process_payment ()

This method takes the input from the display_payment_form(), and hands off to ISP::Transac
for final processing.

=head2 _process(\%DATA)

This method is used for processing items that require error checking, and for finalizing the
data before it is passed back to the calling CGI. It takes care of returning either the populated
error template or the successful template to the calling CGI.

DATA is an optional hashref parameter of the data you want inserted into the error
page template.

Returns either a rendered ISP::Error page template, or a pb_build.

If called in list context, this method will skip processing the success template and return
control to the calling method. Otherwise, you signify that you are done, and want the return
to be sent to the calling CGI.

=head2 _render_error ()

Builds and creates the HTML template that displays the error messages via the template.

Uses ISP::Error->render_gui_data() to format the data for the template.

=head2 initialize_credit_payment ( NAME => VALUE )

Reusable method to instantiate a credit card transaction. Calls
process_bank_response().

The two mandatory parameters are:

	-amount => float
	-error	=> ISP::Error object

Returns success (0) if everything went properly and 1 if not.

=head2 process_bank_response ( BANK_RESPONSE )

Reusable method that takes the array provided by calling 
ISP::Transac->credit_card_payment() as it's only mandatory parameter.

Returns/renders to the GUI immediately if the transaction failed, thereby
halting the rest of the transaction processing.

Returns 0/success if the transac succeeded, and 1 if not. The page builder
params are updated with specific information returned from the bank.

Which data this is, is dependent on whether the bank returned success or
failure.

=head2 _header ()

Generates the header to be printed at the top of the web page, and opens the
HTML tags.

Takes no parameters, there is no return.

=head2 _footer ()

Generates the footer to be printed at the bottom of the web page. It also
closes out the HTML tags.

Takes no parameters, there is no return.

=head2 _client_info_table (USERNAME)

Generates the users plan information that is included in each accounting web page.

The mandatory parameter USERNAME is an ISP::User object.

=head2 _contact_info_table (USERNAME)

Generates the users contact-type information. This method is only called by
_client_info_table(), and will only print this table if run mode is 'home', and it
is not disabled in the config.

The mandatory parameter USERNAME is an ISP::User object. There is no return.

=head2 _clear_session ( { NAME => VALUE } )

Clears the current operators session.

Takes an optional hash reference as a parameter:

	{ only_save_profile	=> 1 }

If set, all collected session parameters are cleared except the operators
profile. Otherwise, the 'username' parameter will be retained along with the
profile.

Returns 0 upon completion.



=head2 _session_extract( FIELD_NAME, DELETE_AFTER )

Extracts a data structure from a session. Created originally to be called
by the individual report subs, it can extend beyond that.

FIELD_NAME is the name of the session data structure to retrieve, and is
a mandatory scalar string parameter.

DELETE_AFTER is an optional parameter. If set to true, the named session
variable will be deleted from the session after the data has been extracted.

Returns a data structure. It is up to the caller to know/deal with what
type of data structure is returned.




=head2 _write_protected ({ error => ERROR })

This method is called from all operations that have the potential to attempt
write operations on the database when the master database server is locked
out while in maintenance mode.

It is responsible for generating relevant error messages.

The parameters are passed in within a hash reference. ERROR is an ISP::Error
object, and is mandatory.

Returns the ISP::Error object. It is the responsibility of the caller
to act on it.

=head2 income_by_payment_type()

Reports income per day, sorted by payment method.




=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steveb at cpan.org> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISP::GUI::Accounting

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut



1;
