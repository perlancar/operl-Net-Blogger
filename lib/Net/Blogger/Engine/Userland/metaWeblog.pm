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

$Net::Blogger::Engine::Userland::metaWeblog::VERSION   = '0.3';

@Net::Blogger::Engine::Userland::metaWeblog::ISA       = qw ( Exporter Net::Blogger::Engine::Base );
@Net::Blogger::Engine::Userland::metaWeblog::EXPORT    = qw ();
@Net::Blogger::Engine::Userland::metaWeblog::EXPORT_OK = qw ();

use Exporter;
use Net::Blogger::Engine::Base;

use File::Basename;

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

=head2 $pkg->newMediaObject(%args)

Valid argument are :

=over

=item *

B<file>

String. Path to the file you're trying to upload.

If this argument is present the package will try to load I<MIME::Base64>
for automagic encoding.

=item *

B<name>

String. "It may be used to determine the name of the file that stores the object, 
or to display it in a list of objects. It determines how the weblog refers to 
the object. If the name is the same as an existing object stored in the weblog, 
it replaces the existing object." [1]

If a I<file> argument is present and no I<name> argument is defined, this property
will be defined using the I<File::Basename::basename> function.

=item *

B<type>

String. "It indicates the type of the object, it's a standard MIME type, 
like audio/mpeg or image/jpeg or video/quicktime." [1]

If a I<file> argument is present and no I<type> argument is defined, the package
will try setting this property using the I<File::MMagic> package.

=item *

B<bits>

Base64-encoded binary value. The content of the object.

If a I<file> argument is present, the package will try setting this property
using the I<MIME::Base64> package.

=back

=cut

sub newMediaObject {
  my $self  = shift;
  my %args = @_;

  #

  if ($args{file}) {

    my $pkg = "MIME::Base64";
    eval "require $pkg";

    if ($@) {
      $self->LastError("Failed to load $pkg for automagic encoding, $@");
      return 0;
    }

    open(FILE, $args{file}) or &{
      $self->LastError("Failed to open $args{file} for reading, $!");
      return 0;
    };

    my $buf = undef;

    while (read(FILE, $buf, 60*57)) {
      no strict "refs";
      $args{bits} .= &{$pkg."::encode_base64"}($buf);
    }

    close FILE;

    #

    if (! $args{type}) {
      my $pkg = "File::MMagic";
      eval "require $pkg";

      if ($@) {
	$self->LastError("Failed to load $pkg for automagic type checking $@");
	return undef;
      }

      #

      my $mm = undef;
      eval { $mm = $pkg->new(); };

      if ($@) {
	$self->LastError("Failed to instantiate $pkg for automagic type checking, $@");
	return 0;
      }

      $args{type} = $mm->checktype_filename($args{file});

      if (! $args{type}) {
	$self->LastError("Unable to determine file type ");
      }
    }

    #

    if (! $args{name}) {
      $args{name} = &basename($args{file});
    }
  }

  #

  else {
    foreach ("name","type","bin") {
      if (! $args{$_}) {
	$self->LastError("You must define a value for the $_ property.");
	return 0;
      }
    }
  }

  #

  my $call = $self->_Client->call(
				  "metaWeblog.newMediaObject",
				  $self->_Type(string=>$self->BlogId()),
				  $self->_Type(string=>$self->Username()),
				  $self->_Type(string=>$self->Password()),
				  $self->_Type(struct=>\%args),
				 );

  return ($call) ? $call->result() : undef;
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

0.3

=head1 DATE

January 10, 2003

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

http://www.xmlrpc.com/metaWeblogApi

http://groups.yahoo.com/group/weblog-devel/message/200

=head1 FOOTNOTES

=over

=item [1]

http://www.xmlrpc.com/discuss/msgReader$2393

=back 

=head1 CHANGES

=head2 0.3

=over

=item *

Added support for I<metaWeblog.newMediaObject> method.

=item *

Updated POD

=back

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

Copyright (c) 2002-2003 Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the
same terms as Perl itself.

=cut

return 1;

}
