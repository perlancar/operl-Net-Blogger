{

=head1 NAME

Net::Blogger::Engine::Radio

=head1 SYNOPSIS

 my $radio = Blogger->new(engine=>"radio");
 $radio->Proxy(PROXY);
 $radio->Username(USERNAME);
 $radio->Password(PASSWORD);

 $radio->newPost(
                 postbody => \"hello world",
		 publish=>1,
		 );

 $radio->metaWeblog()->newPost(
	   		       title=>"hello",
			       description=>"world",
			       publish=>1,
			      );

=head1 DESCRIPTION

This package inherits I<Net::Blogger::Engine::Userland> and implements methods specifc to a RadioUserLand XML-RPCserver.

=cut

package Net::Blogger::Engine::Radio;
use strict;

$Net::Blogger::Engine::Radio::VERSION   = 0.2.1;
@Net::Blogger::Engine::Radio::ISA       = qw (
                                         Exporter
                                         Net::Blogger::Engine::Userland
                                         );
@Net::Blogger::Engine::Radio::EXPORT    = qw ();
@Net::Blogger::Engine::Radio::EXPORT_OK = qw ();

use Exporter;
use Net::Blogger::Engine::Userland;

=head1 CONSTRUCTOR METHODS

=head2 $pkg = Net::Blogger::Engine::Radio->new(%args)

TBW

=cut

sub new {
    my $pkg  = shift;
    my %args = @_;

    my $self = {};
    bless $self,$pkg;
    
    if (! $self->SUPER::init(%args)) {
	return undef;
    }

    return $self;
}

=head1 Blogger API METHODS

=head2 $pkg->GetBlogId()

"blogid is ignored. (Radio only manages one weblog, but something interesting could be done here with categories. In your code you must pass "home", all other blogid's cause an error.)"

 -- http://radio.userland.com/emulatingBloggerInRadio#howTheBloggerApiMapsOntoRadioWeblogs

This method overrides I<Net::Blogger::API::Extended::getBlogId> method

=cut

sub GetBlogId {
    my $self = shift;
    return "home";
}

=head2 $pkg->BlogId()

See docs for I<GetBlogId>

=cut

sub BlogId {
  my $self = shift;
  return $self->GetBlogId();
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

=head1 VERSION

0.2.1

=head1 DATE

$Date: 2002/03/18 22:54:56 $

=head1 AUTHOR

Aaron Straup Cope

=head1 CHANGES

=head2 0.2.1

=over

=item 

Updated POD

=back

=head2 0.2

=over

=item

Added hooks to enable I<metaWeblog> methods

=item

Updated POD

=back

=head2 0.1

=over

=item

Initial revision.

=back

=head1 SEE ALSO

L<Net::Blogger::Engine::Userland>

L<Net::Blogger::Engine::Userland::metaWeblog>

http://frontier.userland.com/emulatingBloggerInManila

=head1 LICENSE

Copyright (c) 2001-2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
