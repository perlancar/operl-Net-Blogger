{

=head1 NAME

Net::Blogger::Engine::Userland - base class for UserLand Blogger API engines

=head1 SYNOPSIS

 TBW

=head1 DESCRIPTION

This package inherits I<Net::Blogger::Engine::Base> and implements shared methods for the UserLand Manila and RadioUserland XML-RPC servers.

This package should not be called directly. It is a base class used by I<Net::Blogger::Engine::Manila> and I<Net::Blogger::Engine::Radio>

=cut

package Net::Blogger::Engine::Userland;
use strict;

$Net::Blogger::Engine::Userland::VERSION   = '0.3.1';
@Net::Blogger::Engine::Userland::ISA       = qw ( Exporter Net::Blogger::Engine::Base );
@Net::Blogger::Engine::Userland::EXPORT    = qw ();
@Net::Blogger::Engine::Userland::EXPORT_OK = qw ();

use Net::Blogger::Engine::Base;

use Exporter;
use URI;

=head1 CONSTRUCTOR METHODS

=cut

=pod

=head2 $pkg->init(%args)

TBW

=cut

sub init {
    my $self  = shift;
    my %args = @_;

    my $child = caller();
    
    if (! $child =~ /^(Net::Blogger::Engine::(Manila|Radio))$/) {
	return 0;
    }

    if (exists $args{'proxy'}) {
	$self->Proxy($args{'proxy'});
	delete $args{'proxy'};
    }
    
    return $self->SUPER::init(%args);
}

=head1 PUBLIC METHODS

=head2 $pkg->Proxy($uri)

Get/set the URI of the Manila->Blogger proxy.

If no proxy is explicitly defined then the method determines the hostname for the Manila server using the current blogid.

"Just to clarify, the URI is /RPC2, even if your blogid (homepage url) is a sub-site url, like http://www.myserver.com/mysite/. It's never something like /mysite/RPC2." --Jake Savin (Userland)

=cut

sub Proxy {
    my $self  = shift;
    my $proxy = shift;

    if ($proxy) {
	$self->{"_proxy"} = $proxy;
	return $self->{"_proxy"};
    }

    if ($self->{"_proxy"}) {
	return $self->{"_proxy"};
    }
    
    if (my $blog = $self->BlogId()) {
	my $uri = URI->new($blog);
	$self->{"_proxy"} = $uri->scheme()."://".$uri->host()."/RPC2";

	$self->{"_client"} = undef;
	return $self->{"_proxy"};
    }

    $self->LastError("Unable to determine proxy explicitly or by parsing blogid.");
    return undef;
}

=head2 $pkg->AppKey()

Returns true. Manila does not require a Blogger API key, but specifies something (anything) all the same.

=cut

sub AppKey {
    my $self = shift;
    return 1;
}

=head2 $pkg->BlogId()

Get/Set the current blog id.

Ensures that the blogid contains a trailing slash, without which the Frontier engine freaks out.

=cut

sub BlogId {
  my $self = shift;
  my $id   = shift;

  if ($id) {
    unless ($id =~ /^(.*)\/$/) { $id .= "/"; }
    $self->{'_blogid'} = $id;
  }

  return $self->{'_blogid'};
}

=head2 $pkg->MaxPostLength()

By default, returns undef. In other words, there is no max post length for Manila.

"As far as I know there is no max length for a post, certainly nothing you have to enforce on your end." --Dave Winer (Userland)

=cut

sub MaxPostLength {
    my $self = shift;
    return undef;
}


=head1 metaWeblog API METHODS

=head2 $pkg->metaWeblog()

=cut

sub metaWeblog {
  my $self = shift;

  if (! $self->{__meta}) {

    require Net::Blogger::Engine::Userland::metaWeblog;
    my $meta = Net::Blogger::Engine::Userland::metaWeblog->new(debug=>$self->{debug});

    map { $meta->$_($self->$_()); } qw (BlogId Proxy Username Password );
    $self->{__meta} = $meta;
  }

  return $self->{__meta};
}

return 1;

=head1 VERSION

0.3.1

=head1 DATE

September 02, 2002

=head1 AUTHOR

Aaron Straup Cope

=head1 CHANGES

=head2 0.3.1

=over 4

=item *

Reset _client when I<Proxy> is called with a new value.

=item *

Updated POD

=back

=head2 0.3

=over 4 

=item *

Added $pkg->metaWeblog()

back

=head2 0.2.3

=over 4

=item *

Added quotes to I<$VERSION>

=back

=head2 0.2.2

=over 4

=item *

Updated POD

=back

=head2 0.2.1

=over 4

=item * 

Updated POD

=back

=head2 0.2

=over 4

=item *

Switched base class to Net::Blogger::Base

=item *

Update POD.

=back

=head2 0.1.1

=over 4

=item *

Modified Net::Blogger::Manila.pm I<Proxy> method to conform to the way Manila servers do XML-RPC.

=item 

Added Net::Blogger::Manila.pm I<MaxPostLength> method.

=item

Added Net::Blogger::Manila.pm private I<init> method to handle possible proxy argument.

=item

Updated POD.

=back

=head2 0.1

=over 4

=item

Initial setup.

=back

=head1 SEE ALSO

L<Blogger>

http://frontier.userland.com/emulatingBloggerInManila

=head1 LICENSE

Copyright (c) 2001-2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

}
