{

=head1 NAME

Net::Blogger::API::Core - Blogger API methods

=head1 SYNOPSIS

 TBW

=head1 DESCRIPTION

Net::Blogger::API::Core defined methods that correspond to the Blogger API.

It is inherited by I<Net::Blogger::Engine::Base.pm>

=cut

package Net::Blogger::API::Core;
use strict;

$Net::Blogger::API::Core::VERSION   = '0.1.3';
@Net::Blogger::API::Core::ISA       = qw ( Exporter );
@Net::Blogger::API::Core::EXPORT    = qw ();
@Net::Blogger::API::Core::EXPORT_OK = qw ();

use Exporter;

=head1 Blogger API METHODS

=head2 $pkg->getUserBlogs()

Fetch the I<blogid>, I<url> and I<blogName> for each of the Blogger blogs the current user is registered to.

Returns an array ref of hashes.

=cut

sub getUsersBlogs {
    my $self  = shift;
    my $blogs = [];
    
    my $call = $self->_Client->call(
				    "blogger.getUsersBlogs",
				    $self->_Type(string=>$self->AppKey()),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    );

    ($call) ? return $call->result() : return [];
}

=head2 $pkg->newPost(%args)

Add a new post to the Blogger server. 

Valid arguments are :

=over

=item *

B<postbody> (required)

Scalar ref.

=item *

B<publish> 

Boolean.

=back

If the length of I<postbody> exceeds maximum length allowed by the Blogger servers -- 65,536 characters -- currently  the text will be chunked into smaller pieces are each piece will be posted separately.

Returns an array containing one, or more, post ids.

=cut

sub newPost {
    my $self = shift;
    my $args = { @_ };

    my $postbody = $args->{'postbody'};

    if (ref($postbody) ne "SCALAR") {
	$self->LastError("You must pass postbody as a scalar reference.");
	return 0;
    }

    if (($self->MaxPostLength()) && (length($$postbody) > $self->MaxPostLength())) {
	return $self->_PostInChunks(%$args);
    }

    my $publish = ($args->{'publish'}) ? 1 : 0;

    my $call = $self->_Client->call(
				    "blogger.newPost",
				    $self->_Type(string=>$self->AppKey()),
				    $self->_Type(string=>$self->BlogId()),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    $self->_Type(string=>$$postbody),
				    $self->_Type(boolean=>$publish),
				    );
    
    return ($call) ? $call->result() : return 0;
}

=head2 $pkg->getPost($postid)

Returns a hash ref, containing the following keys : userid, postid, content and dateCreated.

=cut

sub getPost {
    my $self   = shift;
    my $postid = shift;

    if (! $postid) {
	$self->LastError("You must specify a postid.");
	return 0;
    }
    
    my $call = $self->_Client->call(
				    "blogger.getPost",
				    $self->_Type(string=>$self->AppKey()),
				    $self->_Type(string=>$postid),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    );

    if (! $call) { return 0; }

    my $post = $call->result();

    # See KNOWN ISSUES

    if ($post eq "0") {
	$self->LastError("Unable to locate post.");
	return 0;
    }
    
    #$post->{'dateCreated'} = $post->{'dateCreated'}->repr();
    return $post;
}

=head2 $pkg->getRecentPosts(%args)

Fetch the latest (n) number of posts for a given blog. The most recent posts are returned first.

Valid arguments are 

=over

=item *

B<numposts>

Int. If no argument is passed to the method, default is 1.

"NumberOfPosts is limited to 20 at this time. Let me know if this 
gets annoying. Letting this number get too high could result in some 
expensive db access, so I want to be careful with it." --Ev

=back

Returns true or false, followed by an array of hash refs. Each hash ref contains the following keys : postid,content,userid,dateCreated

=cut

sub getRecentPosts {
    my $self = shift;
    my %args = @_;

    my $num   = (defined $args{'numposts'}) ? $args{'numposts'} : 1;
    my $posts = [];
    
    unless ($num =~ /^(\d+)$/) {
      $self->LastError("Argument $args{'numposts'} isn't numeric.");
	return (0,undef);
    }

    unless (($num >= 1) && ($num <= 20)) {
      $self->LastError("You must specify 'numposts' as an integer between 1 and 20.");
	return (0,undef);
    }

    my $call = $self->_Client->call(
				  "blogger.getRecentPosts",
				  $self->_Type(string=>$self->AppKey()),
				  $self->_Type(string=>$self->BlogId()),
				  $self->_Type(string=>$self->Username()),
				  $self->_Type(string=>$self->Password()),
				  $self->_Type(int=>$num),
				  );

    my @posts = ($call) ? (1,@{$call->result()}) : (0,undef);
    return @posts;
}

=head2 $pkg->editPost(%args)

Update the Blogger database. Set the body of entry $postid to $body.

Valid arguments are :

=over

=item *

B<postbody> (required)

Scalar ref or a valid filehandle.

=item *

B<postid> (required)

String.

=item *

B<publish> 

Boolean.

=back

If the length of I<postbody> exceeds maximum length allowed by the Blogger servers -- 65,536 characters -- currently  the text will be chunked into smaller pieces are each piece will be posted separately.

Returns an array containing one, or more, post ids.

=cut

sub editPost {
    my $self = shift;
    my $args = { @_ };

    my $postbody = $args->{'postbody'};
    my $postid   = $args->{'postid'};

    if (! $postid) { 
	$self->LastError("You must specify a postid.");
	return 0; 
    }
    
    if (ref($postbody) ne "SCALAR") {
	$self->LastError("You must pass postbody as a scalar reference.");
	return 0;
    }
    
    if (($self->MaxPostLength()) && (length($$postbody) > $self->MaxPostLength())) {
	return $self->_PostInChunks(%$args);
    }

    my $publish = ($args->{'publish'}) ? 1 : 0;

    my $ok = undef;

    my $call= $self->_Client->call(
				   "blogger.editPost",
				   $self->_Type(string=>$self->AppKey()),
				   $self->_Type(string=>$postid),
				   $self->_Type(string=>$self->Username()),
				   $self->_Type(string=>$self->Password()),
				   $self->_Type(string=>$$postbody),
				   $self->_Type(boolean=>$publish),
				   );

    ($call) ? return $call->result() : return 0;
}

=head2 $pkg->deletePost(%args) 

Delete a post from the Blogger server.

Valid arguments are 

=over

=item *

B<postid> (required)

String.

=item *

B<publish> 

Boolean.

=back

Returns true or false.

=cut

sub deletePost {
    my $self = shift;
    my $args = { @_ };

    my $postid = $args->{'postid'};

    if (! $postid) {
	$self->LastError("No post id.");
	return 0;
    }

    my $publish = ($args->{'publish'}) ? 1 : 0;

    my $call = $self->_Client->call(
				    "blogger.deletePost",
				    $self->_Type(string=>$self->AppKey()),
				    $self->_Type(string=>$postid),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    $self->_Type(boolean=>$publish),
				    );

    ($call) ? return $call->result() : return 0;
}

=head2 $pkg->setTemplate(%args)

Set the body of the template matching type I<$type>.

<quote src = "ev">template is the HTML (XML, whatever -- Blogger can output any sort of text). Must contain opening and closing <Blogger> tags to be valid and accepted.</quote>

Valid arguments are 

=over

=item *

B<template>  (required)

Scalar ref.

=item *

B<type> (required)

String. Valid types are "main" and "archiveIndex"

=back

Returns true or false.

=cut

sub setTemplate {
    my $self = shift;
    my $args = { @_ };
    
    my $template = $args->{'template'};
    my $type     = $args->{'type'};

    if (ref($template) ne "SCALAR") {
      $self->LastError("You must pass template as a scalar reference.");
	return 0;
    }
    
    unless ($type =~ /^(main|archiveIndex)$/) {
	$self->LastError("Valid template types are 'main' and 'archiveIndex'.");
	return 0;
    }

    # see also : The Perl Cookbook, chapter 6.15
    unless ($$template =~ /(<Blogger>)[^<]*(?:(?! <\/?Blogger>)<[^<]*)*(<\/Blogger>)/m) {
	$self->LastError("Your template must contain opening and closing <Blogger> tags.");
	return 0;
    }

    my $call = $self->_Client->call(
				    "blogger.setTemplate",
				    $self->_Type(string=>$self->AppKey()),
				    $self->_Type(string=>$self->BlogId()),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    $self->_Type(string=>$$template),
				    $self->_Type(string=>$type),
				    );

    ($call) ? return $call->result() : return 0;
}

=head2 $pkg->getTemplate(%args)

Fetch the body of the template matching type I<$type>.

Valid types are 

=over

=item *

B<type> (required)

String. Valid types are "main" and "archiveIndex"

=back

Returns a string.

=cut

sub getTemplate {
    my $self = shift;
    my $args = { @_ };
    
    unless ($args->{'type'} =~ /^(main|archiveIndex)$/) {
	$self->LastError("Valid template types are 'main' and 'archiveIndex'.");
	return 0;
    }
    
    my $call = $self->_Client->call(
				    "blogger.getTemplate",
				    $self->_Type(string=>$self->AppKey()),
				    $self->_Type(string=>$self->BlogId()),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    $self->_Type(string=>$args->{'type'}),
				    );

    ($call) ? return $call->result() : return 0;
}

=head1 VERSION

0.1.3

=head1 DATE

May 04, 2002

=head1 CHANGES

=head2 0.1.3

=over

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

Initial revision.

=back

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<Net::Blogger::Engine::Base>

L<Net::Blogger::API::Extended>

=head1 LICENSE

Copyright (c) 2001-2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
