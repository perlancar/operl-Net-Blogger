{

=head1 NAME

Net::Blogger::Engine::Base

=head1 SYNOPSIS

 package Net::Blogger::Engine::SuperFly;

 use vars qw ( @ISA );
 @ISA = qw ( Net::Blogger::Engine::Base );
 use Net::Blogger::Engine::Base;

 sub new {
    my $pkg = shift;

    my $self = {};
    bless $self,$pkg;
    
    $self->SUPER::init(@_);
    return $self;
 }

=head1 DESCRIPTION

Base.pm is used a base class by implementation specific modules for the Blogger API.

If an implementation follows the Blogger API to the letter then, conceivably, all it's package would need to define is a constructor and I<Proxy> method to define the URI of it's XML-RPC server.

Base.pm inherits the functionality of Net::Blogger::Base::API and Net::Blogger::Base::Ext and defines private methods used by each.

=cut

package Net::Blogger::Engine::Base;
use strict;

use vars qw ( $AUTOLOAD );

$Net::Blogger::Engine::Base::VERSION        = 0.1.2;
@Net::Blogger::Engine::Base::ISA            = qw ( Exporter Net::Blogger::API::Core Net::Blogger::API::Extended );
@Net::Blogger::Engine::Base::ISA::EXPORT    = qw ();
@Net::Blogger::Engine::Base::ISA::EXPORT_OK = qw ();

use Carp;
use Error;
use Exporter;

use XMLRPC::Lite;

use Net::Blogger::API::Core;
use Net::Blogger::API::Extended;

=head1 CONSTRUCTOR METHODS

=head2 Blogger->new(%args)

Instantiate a new Blogger object.

Valid arguments are :

=over

=item B<appkey> 

String. The magic appkey for connecting to the Blogger XMLRPC server.

=item B<blogid>

String. The unique ID that Blogger uses for your weblog

=item B<username>

String. A valid username for blogid

=item B<password>

String. A valid password for the username/blogid pair.

=back

=cut

sub new {
    my $pkg = shift;
    
    my $self = {};
    bless $self,$pkg;

    $self->init(@_) || return undef;

    return $self;
}

sub init {
    my $self = shift;
    my $args = { @_ };

    $self->AppKey($args->{'appkey'});
    $self->Username($args->{'username'});
    $self->Password($args->{'password'});
    $self->BlogId($args->{'blogid'});

    $self->{'debug'}   = $args->{'debug'};
    $self->{"_posts"}  = [];

    return 1;
}

=head1 PUBLIC METHODS

There are no public methods. See Net::Blogger::Base::API and Net::Blogger::Base::Ext.

=cut

=pod

=head1 PRIVATE METHODS

=cut

=head2 $pkg->Proxy()

Get/set the URI of the Blogger API server.

=head2 $pkg->AppKey($key)

Get/set the magic appkey

=head2 $pkg->BlogId($id)

Get/set the blogid

=head2 $pkg->Username($username)

Get/set the username

=head2 $pkg->Password($password)

Get/set the password

=head2 $pkg->MaxPostLength()

Return the maximum number of characters a single post may contain.

=cut

=head2 $pkg->LastError($e)

Fetch the last recorded error message.

Returns a string.

=cut

sub LastError {
    my $self = shift;
    my $e    = shift;
    
    if ($e) {
	Error::Simple->record($e);
	return 1;
    }
    
    $e = Error->prior();
    chomp $e;

    return $e;
}

=head1 PRIVATE METHODS

=cut

=head2 $pkg->_Client()

Return an XML-RPC client object.

=cut

sub _Client {
    my $self = shift;

    if (ref($self->{"_xmlrpc"}) ne "XMLRPC::Lite") {
      my $client = XMLRPC::Lite->new()
	|| Error->throw(-text=>$!);

      $client->on_fault(\&_ClientFault);
      $client->proxy($self->Proxy); 

      if ($self->{'debug'}) {
	$client->on_debug(sub { print @_; });
      }

      $self->{"_xmlrpc"} = $client;
    }

    return $self->{"_xmlrpc"};
}

sub _ClientFault {
    my $client = shift;
    my $res    = shift;
    Error::Simple->record(join("\n",
			       "Fatal client error.",
			       ((ref $res) ? $res->faultstring() : $client->transport->status()))
			  );
    return 0; 
}

=head2 $pkg->_Type(%args)

=cut

sub _Type {
    my $self = shift;
    return XMLRPC::Data->type(@_);
}

sub DESTROY {
    return 1;
}

sub AUTOLOAD {
    my $self  = shift;
    $AUTOLOAD =~ s/.*:://;

    if ($AUTOLOAD eq "Publish") {
	$self->LastError("This method has been deprecated.");
	return undef;
    }

    unless ($AUTOLOAD =~ /^(Proxy|AppKey|BlogId|Username|Password)$/) {
	$self->LastError("Unkown method '$AUTOLOAD' called. Skipping.");
	return undef;
    }

    my $property = lc "_".$AUTOLOAD;

    if (my $arg = shift) { 
	$self->{ $property } = $arg; 
    }
   
    if ($AUTOLOAD eq "Proxy") {
	$self->{"_xmlrpc"} = undef;
    }

    return $self->{ $property };
}

=head1 VERSION

0.1.2

=head1 DATE

$Date: 2002/03/04 13:56:04 $

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<Net::Blogger::API::Core>

L<Net::Blogger::API::Extended>

L<SOAP::Lite>

=head1 CHANGES

=head2 0.1.2

=over

=item 

Updated POD

=back

=head2 0.1.1

=over

=item

The XML-RPC client is instantiated and set using a discreet object (rather than via a hash key for the Bloggger.pm object) because the I<XMLRPC::Lite::proxy> method and the I<Net::Blogger::Engine::Base::Proxy> method (which is AUTOLOAD-ed) are getting confused. (WTF?)

=item

No need to pass I<$self> to I<&_ClientFault>.

=back

=head2 0.1

=over

=item

Initial revision.

=back

=head1 LICENSE

Copyright (c) 2001-2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
