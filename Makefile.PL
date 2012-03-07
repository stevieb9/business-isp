#!/usr/bin/perl

use strict;
use warnings;
use ExtUtils::MakeMaker;

use Config::Tiny;
use Data::Dumper;
use File::Copy;

my $conf_file = ( -e 'ISP.conf-dist' )
	? 'ISP.conf-dist'
	: 'src/conf/ISP.conf-dist';

my $config = Config::Tiny->read( $conf_file );

print "\n\n\n" .
	  "#########################################\n\n" .
	  "Welcome to the ISP:: installer.\n\n" .
	  "#########################################\n\n"; 

# remind the potential users of our shortcomings

if ( $^O eq 'MSWin32' ) {

	print "\n\nAt this time, ISP:: modules completely assume that you are " .
		  "running under a Unix platform.\n\n" .
		  "I have never tested on Windows, so let me know how you make out\n";
}

if ( $] > 5.008009 ) {
	print "\n\nYou are using a version of perl that is higher than 5.8.9.\n\n" .
		  "Some of the prerequisites are known to need custom patches at 5.9.x I've " .
		  "sent patches to the maintainers of the project(s) in question, and " .
		  "hope they will be included prior to my release on CPAN.\n\n" .
		  "If not, I'll integrate the mechanisms into the installer.\n\n";
}

print <<EOT;


We need to ask a few questions regarding the location of certain
directories.

This won't take long ;)



EOT

#
# these are the config file directives
#

my %directives = (
				config_dir		=> "Where should I install the config file [$config->{ Constants }->{ config_dir }]: ",
				template_dir	=> "Where will the templates be stored [$config->{ Constants }->{ template_dir }]: ",
				http_server		=> "What is the URL of your web server [$config->{ Constants }->{ http_server }]: ",
				web_dir			=> "Where is your web data directory [$config->{ Constants }->{ web_dir }]: ",
				cgi_dir			=> "Where is your CGI-BIN directory [$config->{ Constants }->{ cgi_dir }]: ",
				image_dir		=> "Where do you want the images directory placed [$config->{ Constants }->{ image_dir }]: ",
				script_dir		=> "Binary scripts will be installed here [$config->{ Constants }->{ script_dir }]: ",
				enable_bank_processing => "Exact::Transaction users only. Do not enable! [$config->{ Constants }{ enable_bank_processing }]: ",
			);

my %email_directives = (
				smtp_server			=> "FQDN of the SMTP server for outbound email [$config->{ 'ISP::Email' }->{ smtp_server }]: ",
				smtp_from			=> "Email address that will appear in the From: field of all email [$config->{ 'ISP::Email' }->{ smtp_from }]: ",
				email_addr_devel	=> "System Administrator's email address [$config->{ 'ISP::Email' }->{ email_addr_devel }]: ",
				email_addr_accounting	=> "Accounting department's email address [$config->{ 'ISP::Email' }->{ email_addr_accounting }] : ",
				email_addr_support	=> "Support department's email address [$config->{ 'ISP::Email' }->{ email_addr_support }] : ",
			);

for my $directive ( keys %directives ) {

	print "$directives{ $directive }";
	
	my $response = <STDIN>;
	chomp $response;
	
	$config->{ Constants }{ $directive } = $response if $response;

}

print "\n\n";

for my $directive ( keys %email_directives ) {

	print "$email_directives{ $directive }";

	my $response = <STDIN>;
	chomp $response;

	$config->{ 'ISP::Email' }{ $directive } = $response if $response;
}

$config->{ Constants }{ acct_app }
	= $config->{ Constants }{ http_server }
	. '/cgi-bin/accounting.cgi';

my $http_man_dir = $config->{ Constants }{ web_dir } . '/ispmanual';


$config->write( 'ISP.conf-dist' );

#
# now configure the actual system
#

my %system_info = (
				WWWUSER		=> "What is the UID of your web servers username [www]: ",
			);

for my $sys_directive ( keys %system_info ) {

	print "$system_info{ $sys_directive }";
	my $response = <STDIN>;
	chomp $response;

	$system_info{ $sys_directive } = ( $response )
		? $response
		: 'www';
}

# install the test db

copy 'src/schema/isp_test.db', 't/';
copy 'ISP.conf-dist', 't/';

sub MY::postamble {
	
"

CONFDIR 	= $config->{ Constants }{ config_dir }
CGIDIR		= $config->{ Constants }{ cgi_dir }
WEBMANDIR	= $http_man_dir
CSSDIR		= $config->{ Constants }{ template_dir } 
IMAGEDIR	= $config->{ Constants }{ image_dir } 
SCRIPTDIR	= $config->{ Constants }{ script_dir } 
TEMPLATEDIR	= $config->{ Constants }{ template_dir } 
HTTPSERVER	= $config->{ Constants }{ http_server }
WEBDIR		= $config->{ Constants }{ web_dir }
WWWUSER		= $system_info{ WWWUSER }

"

.

'
install:: all cgi conf graphics docs libs templates retest
clean::	clean_sourcedirs clean_test

cgi:
	install -m 0500 -o www -g www src/cgi-bin/accounting.cgi ${CGIDIR}

clean_sourcedirs:
	rm -f doc/*.html
	rm -f doc/*.conf

clean_test:
	rm -f t/isp_test.db
	rm -f t/ISP.conf-dist

clean_dist:
	rm -f exact.conf.A00990-01.bak
	rm -f exact.conf.A00990-01
	rm -f saf.dat
	rm -f Makefile.old
	rm -f ISP.conf-dist
	rm -f MANIFEST.bak 

conf:
	install -m 0640 -o ${WWWUSER} -g ${WWWUSER} ISP.conf-dist ${CONFDIR}
	#rm ISP.conf-dist

database:
	#install -m 0640 -o ${WWWUSER} -g ${WWWUSER} src/schema/isp_maintenance.db /tmp

graphics:
	install -d ${IMAGEDIR}
	install src/graphics/* ${IMAGEDIR}

docs:
	pod2text lib/ISP/ISP.conf.pod	> doc/ISP.conf 
	pod2html --title="ISP.conf" lib/ISP/ISP.conf.pod > doc/ISP.conf.html	

	pod2html --title="ISP::Conversion" 		lib/ISP/Conversion.pm 	> doc/ISP::Conversion.html
	pod2html --title="ISP::Error" 			lib/ISP/Error.pm 		> doc/ISP::Error.html
	pod2html --title="ISP::Database" 		lib/ISP/Database.pm 	> doc/ISP::Database.html
	pod2html --title="ISP::Ledger" 			lib/ISP/Ledger.pm 		> doc/ISP::Ledger.html
	pod2html --title="ISP::Object" 			lib/ISP/Object.pm 		> doc/ISP::Object.html
	pod2html --title="ISP::Sanity" 			lib/ISP/Sanity.pm 		> doc/ISP::Sanity.html
	pod2html --title="ISP::Transac" 		lib/ISP/Transac.pm 		> doc/ISP::Transac.html
	pod2html --title="ISP::User" 			lib/ISP/User.pm 		> doc/ISP::User.html
	pod2html --title="ISP::Vars" 			lib/ISP/Vars.pm 		> doc/ISP::Vars.html
	pod2html --title="ISP::GUI::Accounting" lib/ISP/GUI/Accounting.pm > doc/GUI::Accounting.html
	pod2html --title="ISP::Email" 			lib/ISP/Email.pm 		> doc/ISP::Email.html
	pod2html --title="ISP::Billing" 		lib/ISP/Billing.pm 		> doc/ISP::Billing.html
	pod2html --title="ISP::Reports" 		lib/ISP/Reports.pm 		> doc/ISP::Reports.html

	install -o ${WWWUSER} -g ${WWWUSER} -d ${WEBMANDIR}
	install -o ${WWWUSER} -g ${WWWUSER} -m 0444 doc/*.html ${WEBMANDIR}

	rm pod2htm*

libs:
	install -o ${WWWUSER} -g ${WWWUSER} src/libraries/* ${WEBDIR}

templates:
	install src/templates/*.tpl ${TEMPLATEDIR}
	install	src/templates/*.css ${CSSDIR}

retest:
	install src/schema/isp_test.db t
	install ISP.conf-dist t
';

}

sub nothing{} # fold placeholder for vim

WriteMakefile(
    NAME                => 'ISP',
    AUTHOR              => 'Steve Bertrand <steveb@cpan.org>',
    VERSION_FROM		=> 'lib/ISP/Object.pm',

    ABSTRACT       		=> 'ISP:: core modules',
	($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' 							=> 0,
		'Cwd'									=> 0,
		'DateTime'								=> 0,
		'CGI::Application'						=> 0,
		'CGI::Application::Plugin::PageBuilder' => 0, # needs patch for perl5.10
		'CGI::Application::Plugin::Session'		=> 0,
		'CGI::Application::Plugin::LinkIntegrity' => 0,
		'CGI::Application::Plugin::Forward'		=> 0,
		'Config::Tiny'							=> 0,
		'HTML::Menu::Select'					=> 0,
		'CGI::HTMLError'						=> 0,
		'DBI'									=> 0,
		'DBD::mysql'							=> 0,
		'DBIx::Recordset'						=> 0, # deprecate
		'DBIx::Class'							=> 0,
		'Data::Types'							=> 0, # deprecate
		'ISP::RADIUS'							=> 0.02,
		'EagleUser'								=> 0, # deprecate
		'Exact::Transaction'					=> 0, # deprecate due to licensing
		'MIME::Lite::TT'						=> 0,
	},
    META_MERGE => {
        resources => {
            bugtracker  =>      'https://bitbucket.org/spek/isp/issues',
            repository  =>      'https://bitbucket.org/spek/isp',
        },
    },


    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'ISP-*' },

);

upgrade_check();

sub upgrade_check {

	my $existing_config = '/usr/local/etc/ISP.conf';
	my $source_config	= 'src/conf/ISP.conf-dist';
	
	my %existing_entry;
	my %source_entry;

	my ( $existing_version, $source_version );
	my ( $e_section, $s_section ); # existing, source
	
	if ( open EXISTING, '<', $existing_config ) {
		
		while ( my $line = <EXISTING> ) {
	
	
			if ( $line =~ m{ \A ( \[|\s+) }xms ) {
				$line =~ s/[\[\]\s+]//g;
				$e_section = $line;
			}
			else {		
		
				my ( $directive, $value ) = split( /=/, $line );
				$directive 	=~ s/\s+//g;
				$value		=~ s/\s+//g;
			
				$existing_entry{ $e_section }{ $directive } = $value;
			}
		}
		close EXISTING;
	
		# source config
	
		open SOURCE, '<', $source_config;
	
		while ( my $line = <SOURCE> ) {
	
			if ( $line =~ m{ \A ( \[|\s+ ) }xms ){
				$line =~ s/[\[\]\s+]//g;
				$s_section = $line;
			}
			else {
	
				my ( $directive, $value ) = split( /=/, $line );
				$directive	=~ s/\s+//g;
				$value		=~ s/\s+//g;
	
				$source_entry{ $s_section }{ $directive } = $value;
			}
		}
		close SOURCE;

	}
	# check for version change
	
	$existing_version = $existing_entry{ Version }{ version };
	$source_version		= $source_entry{ Version }{ version };
	
	if ( $existing_version ne $source_version ) {
	
		print "\n\n*** This is an upgrade from version $existing_version to $source_version ***\n\n";
	
		my @added;
		my @removed;
	
		# source config
	
		for my $section ( keys %source_entry ) {
			
			for my $directive ( keys %{ $source_entry{ $section } } ) {
				
				my $changed_str = "Section: $section\n- directive: $directive\n";
				
				push @added, $changed_str if ! exists $existing_entry{ $section }{ $directive };
			}
		}
	
		# existing config
	
		for my $section ( keys %existing_entry ) {
			for my $directive ( keys %{ $existing_entry{ $section } } ) {
				
				my $changed_str = "Section: $section\n- directive: $directive\n";
				push @removed, $changed_str if ! exists $source_entry{ $section }->{ $directive };
			}
		}
	
		print "********  New config file directives added:  *********\n\n" .
		  join( "\n", @added ) . "\n\n" if @added;
	
		print "********  Config file directives removed:  *********\n\n" .
		  join( "\n", @removed ) . "\n\n" if @removed;
	
	}
	else {
	}
}
1;
