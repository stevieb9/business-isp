package Business::ISP::GUI::Base;

use warnings;
use strict;
use Data::Dumper;
use vars qw( @ISA );

use base qw( Business::ISP::Object CGI::Application );

use CGI::Application::Plugin::PageBuilder;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::LinkIntegrity;
use CGI::Application::Plugin::Forward;
use CGI::Application::Plugin::Redirect;

use HTML::Menu::Select qw( menu options );

use DateTime;

use Business::ISP::User;
use Business::ISP::Vars;
use Business::ISP::Transac;
use Business::ISP::Sanity;
use Business::ISP::Error;

{

    # configure ourself

    my @config_vars = qw (
            ENABLE_URL_CHECKSUM
            URL_CHECKSUM_KEY
            URL_CHECKSUM_DIGEST
            DISPLAY_CONTACT_INFO
            RENDER_CODEFLOW
            RENDER_STACK_TRACING
            DIE_ON_BAD_PARAMS
            RENDER_SKIPPED_CHECKS
            DISPLAY_SOURCE_REPO
            DISPLAY_PLAN_STATS
            JAVASCRIPT_LIBRARY
            CLIENT_SESSION_EXPIRY
            CLIENT_COOKIE_EXPIRY
            CLIENT_LOGIN_TIMEOUT
        );

    for my $member (@config_vars) {
        no strict 'refs';
         
        *{$member} = sub {
            my $self = shift;
            return $self->{config}{$member};
        }
    }

} # end BEGIN            
   
        
sub cgiapp_prerun {

    my $self    = shift;
    my $runmode = shift;

    $self->function_orders();

    # if no operator is defined, force a login

    if ( $runmode ne 'login' && $runmode ne 'start' ) {
        
        my $operator = $self->_get_operator_info( 'operator' );
    
        if ( ! $operator ) {

            my $error = Business::ISP::Error->new();
            my $error_msg = "Your session has expired. You need to log back in";

            $error->add_trace();
            $error->add_message( $error_msg );
    
            my $app = $self->ACCT_APP();
            my $login_link  = '<a href="' . $app . '">' . $app . '</a>';

            $error->data({ 
                        session => 'expired',
                        login   => $login_link,
                    });

            $self->session->param( error => $error );
            $self->prerun_mode( 'error' );
        }
    }

    # likewise, if the op is no longer logged in, relogin

    my $logged_in = $self->session->param( 'logged_in' );

    if ( ! $logged_in && $runmode ne 'start' && $runmode ne 'login' && ! defined $self->session->param( 'error' )  ) {

        my $message = "Your login has expired.";
        $self->session->param( message => $message );
        $self->prerun_mode( 'start' );

    }

}
sub _blank_header {

    my $self = shift;

    $self->function_orders();

    my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( 
            "$template_dir/blank_header.html.tpl",
            die_on_bad_params => $self->DIE_ON_BAD_PARAMS(),
        );

    $self->platform();

    $self->pb_param( js_lib => $self->JAVASCRIPT_LIBRARY() );
}
sub display_config {

    my $self    = shift;
    
    $self->function_orders();

    my $config = $self->CURRENT_CONFIG_FILE();

    $self->_header();

    my $template_dir = $self->TEMPLATE_DIR();   
    my $template = $self->load_tmpl( "$template_dir/display_config.html.tpl" );


    my @file_array;
    my $manuals = $self->HTML_MANUAL_LOCATION();

    open CONFIG, '<', $config or die "Can't open the config file $config!: $!";

    while ( my $conf_line = <CONFIG> ) {

        my ( $conf_info, $comment ) = split /;/, $conf_line;

        $conf_info =~ s/\s+//g;
        my ( $directive, $value ) = split /=/, $conf_info;


        my %row;

        if ( $directive =~ m{ ^ \[ \w+  }xms ) {        
        
            my $link = $directive;

            if ( $directive =~ /::/ ) { 

                my $module  = $directive;
                $module     =~ s/\[//;
                $module     =~ s/\]//;

                $link = '<b><a href=' . "$manuals/$module\.html" . '>' . $directive . '</a></b>';   
            }
                        
            %row = (
                    directive   => $link,
                    value       => $value,
                    heading     => 1,
                );

            push @file_array, \%row;

        }
        else {      
            
            my $manual_link = '<b><a href=' . "$manuals/ISP.conf.html#$directive" . '>' . $directive . '</a></b>';  
            
            %row = ( 
                    directive   => $manual_link,
                    value       => $value,  
                );
        
            push @file_array, \%row;
        }

    }

    $template->param( config    => \@file_array );
    $template->param( config_location => $config );

    my $html .= $self->pb_build();
    $html    .= $template->output();

    return $html;
}
sub platform {

    my $self    = shift;

    $self->function_orders();

    my $software_version = $self->VERSION();

    if ( $software_version =~ /d$/ ) {
        my $is_devel_system = 1;
        $self->pb_param( is_devel_system => $is_devel_system );
    }
}
sub error {

    my $self    = shift;

    $self->function_orders();

    my $error = $self->session->param( 'error' );
    return $self->_process({ error => $error });
}
sub _footer {
    my $self = shift;
    $self->function_orders();

    my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( "$template_dir/page_footer.html.tpl" );
}
sub _get_operator_info {

    my $self        = shift;
    my $get_what    = shift;

    $self->function_orders();

    my $op_profile;

    if ( $self->session->param( 'OPERATOR_PROFILE' ) ) {

        my $extracted_profile_from_session 
            = $self->session->param( "OPERATOR_PROFILE" );

        $op_profile = $extracted_profile_from_session->[0]; 
    
    }
    else {
        return undef;
    }

    # return the entire profile hashref if no params supplied
    return $op_profile unless $get_what;

    my $op_item_value = $op_profile->{ $get_what };

    return $op_item_value if $op_item_value;

    return undef;
}
sub _header {
    
    my $self = shift;
    
    $self->function_orders();

    my $template_dir = $self->TEMPLATE_DIR();
    $self->pb_template( 
            "$template_dir/page_header.html.tpl",
            die_on_bad_params => $self->DIE_ON_BAD_PARAMS(),
        );

    my $software_version = $self->VERSION();

    $self->platform();

    $self->pb_param( version => $software_version );
    
    $self->pb_param( js_lib  => $self->JAVASCRIPT_LIBRARY() );

    # check to see if we're in db maintenance mode, and do something

    if ( $self->MASTER_LOCKED() ) {

        my $alert_msg = "" .
            "Master database is offline. System is in read-only mode.<br><br>" .
            "You will be notified if you attempt any write operations.";

        $self->pb_param( master_locked => $alert_msg );
    }

    # produce a link for displaying the config if the op is an admin

    my $opgroup     = $self->_get_operator_info( 'opgroup' );
    my $operator    = $self->_get_operator_info( 'operator' );

    if ( $opgroup eq 'admin' ) {

        my $config_link = $self->self_link(
                                do      => 'display_config',
                            );

        $self->pb_param( config_link => $config_link );

    }

    # create a link to the repo

    if ( $self->DISPLAY_SOURCE_REPO() ) {
        $self->pb_param( source_repo_link => $self->SOURCE_REPO_LINK() );
    }

    # create a devel docs link

    $self->pb_param( devdocs_link => $self->HTML_MANUAL_LOCATION() ); 
  
    # create a 'go home' link

    my $go_home_link    = $self->self_link(
                                do      => 'home',
                            );
    
    $self->pb_param( go_home_link => $go_home_link );

    # create the signout/logout link

    my $signout_link = $self->self_link(
                                do      => 'logout',
                            );

    $self->pb_param( signout_link   => $signout_link );
    $self->pb_param( operator       => $operator );

    # render the values that we aren't going to check for

    my $vardb = Business::ISP::Vars->new();

    my $value_checks_skipped = $vardb->sanity_value_skip_permitted();
    
    my $skipped_tests;

    if ( $value_checks_skipped ) {
    
        for my $entry ( keys %{ $value_checks_skipped } ) {
            $skipped_tests .= $entry;
            $skipped_tests .= ", ";
        }
    }

    if ( $self->RENDER_SKIPPED_CHECKS() && $skipped_tests ) {
        $self->pb_param( skipped_tests => $skipped_tests );
    }
} 
sub _load_operator_profile {

    my $self            = shift;
    my $operator_name   = shift;

    $self->function_orders();

    my $schema = $self->schema();

    my $op_rs = $schema->resultset( 'Operator' )->search({
                                                    operator => $operator_name,
                                                });

    return 1 if ! $op_rs->count();

    my $operator_profile = $self->schema({
                                    result  => $op_rs,
                                    extract => 'href',
                                })->first();

    my $profile_aref;

    push @$profile_aref, $operator_profile;

    $self->session->param( "OPERATOR_PROFILE", $profile_aref );

    return 0;
}
sub login {

    my $self        = shift;

    $self->function_orders();

    my $operator    = $self->query->param( 'operator' );
    my $password    = $self->query->param( 'password' );

    # perform some sanity checks...
    
    my $sanity  = Business::ISP::Sanity->new();
    my $error   = Business::ISP::Error->new();

    if ( ( length ( $operator )) > 16 ) {
        $error->add_message( "Operator field must be less than 10 characters" );
        $error->data( { operator_id => $operator } );
        $error->add_trace();
    }

    $sanity->check_word( "operator_id", $operator, $error );

    return $self->_process({ error => $error }) if $error->exists();

    my $operator_check = $self->_load_operator_profile( $operator );

    my $error_message;

    if ( $operator_check ) {

        my $error_message = "Operator name doesn't exist" ;

        $error->add_trace();
        $error->add_message( $error_message );
        $error->data( { 'operator' => $operator } );
        $error->data( { 'password' => $password } );

        return $self->_process({ error => $error });
    }

    my $stored_op_pw = $self->_get_operator_info( 'password' );

    if ( $password ne $stored_op_pw ) {
        my $error_message = "Invalid operator password";
        $error->add_trace();
        $error->add_message( $error_message );
        $error->data({ operator => $operator });

        return $self->_process({ error => $error });
    }

    $self->session->param( operator => $self->_get_operator_info( 'operator' ) );
    $self->session->param( opgroup  => $self->_get_operator_info( 'opgroup' ) );

    return $self->_process({ error => $error }) if $error->exists();

    $self->session->param( logged_in => 1 );

    return $self->forward( 'home' );
}
sub logout {

    my $self = shift;

    $self->function_orders();

    $self->session->delete();

    $self->forward( 'start' );

}
sub _process {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();
    
    my $error   = $params->{ error };
    my $data    = $params->{ data };

    $error->add_trace();
    $error->add_trace(1);
    $error->data($data) if $data;

    return $self->_render_error( $error );

    return $self->pb_build();
}
sub _render_error {

    my $self  = shift;
    my $error = shift;

    $self->function_orders();

    my %error_template_data = $error->render_gui_data();

    my $template_dir = $self->TEMPLATE_DIR();
    my $template 
        = $self->load_tmpl( "$template_dir/error.html.tpl" );

    $template->param( %error_template_data );
    
    return $template->output;

}
sub start {

    my $self        = shift;

    $self->function_orders();

    my $template_dir = $self->TEMPLATE_DIR();

    $self->pb_template( 
                "$template_dir/login.html.tpl",
                die_on_bad_params => $self->DIE_ON_BAD_PARAMS(),
            );

    $self->platform();

    my $software_version = $self->VERSION();
    $self->pb_param( version => $software_version );

    $self->session->param( 'do', 'login' );

    $self->pb_param( message => $self->session->param( 'message' ) );

    return $self->pb_build();
}
sub _write_protected {

    my $self    = shift;
    my $params  = shift;

    $self->function_orders();

    my $error = $params->{ error };

    my $message 
            = "Master database is offline. You can not perform write " .
              "operations while the system is in read-only mode";

    $error->add_message( $message );
    $error->add_trace();
    $error->data({ 
                master_server   => $self->MASTER_SOURCE(),
                database_status => 'offline',
                system_mode     => 'read only',
            });

    #   return $self->_process({ error => $error });
    return $error;
}

1;
