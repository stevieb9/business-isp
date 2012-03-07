package ISP::Email;

use warnings;
use strict;

use MIME::Lite::TT;

use vars qw(@ISA);
use base qw(ISP::Object);

BEGIN {
# config accessors
	my @config_vars = qw (
						ALL_EMAIL_TO_DEVEL
						COPY_EMAIL_TO_DEVEL
						SMTP_SERVER
						SMTP_FROM
						EMAIL_ADDR_DEVEL
						EMAIL_ADDR_ACCOUNTING
						EMAIL_ADDR_SUPPORT
						DEBUG_TO_STDOUT
					);

	for my $member (@config_vars) {
		no strict 'refs';
		*{$member} = sub {								
			my $self = shift;						
			return $self->{config}{$member};		
		}												
	}														
} # end BEGIN  

sub new {

	my $class		= shift;
	my $params		= shift;

	my $self = {};
	bless $self, $class;

	$self->configure();
	$self->function_orders();

	return $self;
}

sub email {

	my $self	= shift;
	my $params	= shift;

	my $to = ( $self->ALL_EMAIL_TO_DEVEL() )
		?	$self->EMAIL_ADDR_DEVEL()
		:	$params->{ to };

	my $cc = ( $self->COPY_EMAIL_TO_DEVEL() )
		?	$self->EMAIL_ADDR_DEVEL()
		:	'';

	my $subject	= $params->{ subject };
	my $tmpl	= $params->{ tmpl };
	my $data	= $params->{ data };
	my $from	= $self->SMTP_FROM();
	my $smtp	= $self->SMTP_SERVER();

	my $msg		= MIME::Lite::TT->new(
					
					From		=> $from,
					To			=> $to,
					Cc			=> $cc,
					Subject		=> $subject,
					Template	=> $tmpl,
					TmplParams	=> $data,
				);

	my @failed;
	
	$msg->send( 'smtp', $smtp, Debug=>$self->DEBUG_TO_STDOUT() );
}

sub _nothing{} # vim placeholder for folds

1;

__END__

=head1 NAME

ISP::Email - Emailing system for the ISP:: system.

=head1 VERSION

=cut

=head1 SYNOPSIS


=head1 DESCRIPTION

This is module performs all email functions.

=head1 METHODS



=head2 new

Instantiates a new ISP::Email object, and returns itself.



=head2 email({ to => TO, subject => SUBJECT, tmpl => TEMPLATE, data => DATA })

This is a wrapper for external modules that takes care of sending out
email. DATA is any type of data structure that your template can handle.

The parameters are pretty self-explanitory.








=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Report bugs to C<< <steveb at cpan.org> >>. I will be notified, and will report
back to you with any updates.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc ISP::Email

=head1 COPYRIGHT & LICENSE

Copyright 2012 Steve Bertrand, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
