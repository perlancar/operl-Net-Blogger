{

=head1 NAME

Net::Blogger::Engine::Userland::metaWeblog - UserLand metaWeblog API engine

=head1 SYNOPSIS

 my $radio = Blogger->new(engine=>"radio");
 $radio->Proxy(PROXY);
 $radio->Username(USERNAME);
 $radio->Password(PASSWORD);

 $radio->metaWeblog()->newPost(
	   		       title=>"hello",
			       description=>"world",
			       publish=>1,
			      );

=head1 DESCRIPTION

Implements the UserLand metaWeblog API functionality.

This package is meant to be subclassed. It should not be used on it's own.

=cut

package Net::Blogger::Engine::Userland::metaWeblog;
use strict;

$Net::Blogger::Engine::Userland::metaWeblog::VERSION   = '0.2';

@Net::Blogger::Engine::Userland::metaWeblog::ISA       = qw ( Exporter Net::Blogger::Engine::Base );
@Net::Blogger::Engine::Userland::metaWeblog::EXPORT    = qw ();
@Net::Blogger::Engine::Userland::metaWeblog::EXPORT_OK = qw ();

use Exporter;
use Net::Blogger::Engine::Base;

=head1 PUBLIC METHODS

=head2 $pkg->newPost(%args)

=cut

sub newPost {
  my $self = shift;
  my $args = {@_};

  my $publish = 0;

  if (exists $args->{publish}) {
    $publish = $args->{publish};
    delete $args->{publish};
  }

  my $call = $self->_Client->call(
				  "metaWeblog.newPost",
				  $self->_Type(string=>$self->BlogId()),
				  $self->_Type(string=>$self->Username()),
				  $self->_Type(string=>$self->Password()),
				  $self->_Type(hash=>$args),
				  $self->_Type(boolean=>$publish),
				 );

  return ($call) ? $call->result() : return 0;
}

=head2 $pkg->editPost(%args)

TBW 

=cut

sub editPost {
  my $self = shift;
  my $args = {@_};

  my $postid = $args->{postid};

  if (! $postid) {
    $self->LastError("You must specify a postid");
    return 0;
  }

  delete $args->{postid};

  if (($args->{categories}) && (ref($args->{categories}) ne "ARRAY")) {
    $self->LastError("Categories must be passed as an array reference.");
    return 0;
  }

  my $publish = 0;

  if (exists $args->{publish}) {
    $publish = $args->{publish};
    delete $args->{publish};
  }

  my $call = $self->_Client->call(
				  "metaWeblog.editPost",
				  $postid,
				  $self->_Type(string=>$self->Username()),
				  $self->_Type(string=>$self->Password()),
				  $self->_Type(struct=>$args),
				  $self->_Type(boolean=>$publish),
				 );

  return ($call) ? $call->result() : undef;
}

=head2 $pkg->getPost(%args)

TBW

=cut

sub getPost {
  my $self = shift;
  my $args = {@_};

  my $postid = $args->{postid};

  if (! $postid) {
    $self->LastError("You must specify a postid");
    return 0;
  }

  my $call = $self->_Client->call(
				  "metaWeblog.getPost",
				  $postid,
				  $self->_Type(string=>$self->Username()),
				  $self->_Type(string=>$self->Password()),
				 );

  return ($call) ? $call->result() : undef;
}

=head2 $pkg->getCategories()

TBW

=cut

sub getCategories {
  my $self = shift;

  if ($self->{'__parent'} eq "Movabletype") {
    $self->LastError("This method is not supported by the $self->{'__parent'} engine.");
    return undef;
  }

  my $call = $self->_Client()->call(
				    "metaWeblog.getCategories",
				    $self->_Type(string=>$self->BlogId()),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    );

  return ($call) ? $call->result() : undef;
}

=head1 VERSION

0.2

=head1 DATE

May 04, 202

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

http://www.xmlrpc.com/metaWeblogApi

http://groups.yahoo.com/group/weblog-devel/message/200

=head1 CHANGES

=head2 0.2

=over

=item *

Added hooks to I<getCategories> to catch call by Movabletype engine.

=item *

Added quotes to I<$VERSION>

=back

=head2 0.1.2

=over

=item * 

Updated POD

=back

=head2 0.1.1

=over

=item * 

Updated POD

=back

=head2 0.1

=over

=item * 

Initial revision

=back

=head1 LICENSE

Copyright (c) 2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
