{

=head1 NAME

Net::Blogger - an OOP-ish interface for accessing a weblog via the Blogger XML-RPC API.

=head1 SYNOPSIS

 use Net::Blogger;
 my $b = Net::Blogger->new(appkey=>APPKEY);

 $b->BlogId(BLOGID);
 $b->Username(USERNAME);
 $b->Password(PASSWORD);

 $b->BlogId($b->GetBlogId(blogname=>'superfoobar'));

 # Get recent posts

 my ($ok,@p) = $b->getRecentPosts(numposts=>20);

 if (! $ok) {
   croak $b->LastError();
 }

 map { print "\t $_->{'postid'}\n"; } @p;

 # Post from a file

 my ($ok,@p) = $b->PostFromFile(file=>"/usr/blogger-test");

 if (! $ok) {
   croak $b->LastError();
 }

 # Deleting posts

 map {
   $b->deletePost(postid=>"$_") || croak $b->LastError();
 } @p;

 # Getting and setting templates

 my $t = $b->getTemplate(type => 'main');
 $b->setTemplate(type=>'main',template=>\$t) || croak $b->LastError();

 # New post

 my $txt = "hello world.";
 my $id = $b->newPost(postbody=>\$txt) || croak $b->LastError();

 # Get post

 my $post = $b->getPost($id) || croak $b->LastError();
 print "Text for last post was $post->{'content'}\n";

=head1 DESCRIPTION

Blogger.pm provides an OOP-ish interface for accessing a weblog via the Blogger XML-RPC API.

=head1 ENGINES

Blogger.pm relies on "engines" to implement it's functionality. The Blogger.pm package itself is little more than a wrapper file that happens to use a default "Blogger" engine is none other is specified.

   my $manila = Net::Blogger->new(engine=>"manila");

But wait!, you say. It's an API that servers implements and all I should have to do is changed the login data. Why do I need an engine?

Indeed. Every server pretty much gets the spirit of the API right, but each implements the details slightly differently. For example :

The MovableType XML-RPC server follows the spec for the I<getRecentPost> but because of the way Perl auto-vivifies hashes it turns out you can slurp all the posts for a blog rather than the just the 20 most recent.
 
The Userland Manila server doesn't support the I<getUsersBlogs> method; the Userland RadioUserland server does.

The Blogger server imposes a limit on the maximum length of a post. Other servers don't. (Granted the server in question will return a fault, if necessary, but Blogger.pm tries to do the right thing and check for these sorts of things before adding to the traffic on the network.)

Lots of weblog-like applications don't support the Blogger API but do have a traditional REST interface. With the introduction of Blogger.pm "engines", support for these applications via the API can be added with all the magic happening behind the curtain, so to speak.

=cut

package Net::Blogger;
use strict;

use Exporter;

use vars qw ( $AUTOLOAD $LAST_ERROR );

$Net::Blogger::VERSION   = '0.7';
@Net::Blogger::ISA       = qw (Exporter);
@Net::Blogger::EXPORT    = qw ();
@Net::Blogger::EXPORT_OK = qw ();


=head1 CONSTRUCTOR METHODS

=head2 $pkg = Net::Blogger->new(%args)

Instantiate a new Blogger object.

Valid arguments are :

=over

=item *

B<engine> (required)

String. Default is "blogger".

=item * 

B<appkey> 

String. The magic appkey for connecting to the Blogger XMLRPC server.

=item * 

B<blogid>

String. The unique ID that Blogger uses for your weblog

=item * 

B<username>

String. A valid username for blogid

=item * 

B<password>

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

    my $engine = $args->{'engine'} || "blogger";
    my $class  = join("::",__PACKAGE__,"Engine",ucfirst $engine);
 
    eval "require $class";

    if ($@) {
	print $@,"\n";
	$LAST_ERROR = "Unrecognized implementation of the Blogger API.";
	return 0;
    }

    $self->{"_class"} = $class->new(%$args) 
	|| &{ $LAST_ERROR = Error->prior(); return 0; };
    
    return 1;
}

=head1 Blogger API METHODS

=head2 $pkg->getUserBlogs()

Fetch the I<blogid>, I<url> and I<blogName> for each of the Blogger blogs the current user is registered to.

Returns an array ref of hashes.

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

=head2 $pkg->getPost($postid)

Returns a hash ref, containing the following keys : userid, postid, content and dateCreated.

=head2 $pkg->getRecentPosts(%args)

Fetch the latest (n) number of posts for a given blog. The most recent posts are returned first.

Valid arguments are 

=over

=item * 

B<numposts>

Int. If no argument is passed to the method, default is 1.

"NumberOfPosts is limitemd to 20 at this time. Let me know if this 
gets annoying. Letting this number get too high could result in some 
expensive db access, so I want to be careful with it." --Ev

=back

Returns true or false, followed by an array of hash refs. Each hash ref contains the following keys : postid,content,userid,dateCreated

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

"template is the HTML (XML, whatever -- Blogger can output any sort of text). Must contain opening and closing <Blogger> tags to be valid and accepted." --Evan

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

=head2 $pkg->getTemplate(%args)

Fetch the body of the template matching type I<$type>.

Valid types are 

=over

=item * 

B<type> (required)

String. Valid types are "main" and "archiveIndex"

=back

Returns a string.

=head1 EXTENDED METHODS

=head2 $pkg->MaxPostLength()

TBW

=head2 $pkg->GetBlogId(%args) 

Return the unique blogid for I<$args{'blogname'}>.

Valid arguments are 

=over

=item * 

B<blogname> 

String.

=back

Returns a string. If no blogname is specified, the current blogid for the object is returned.

=head2 $pkg->DeleteAllPosts(%args)

TBW

=head2 $pkg->PostFromFile(%args)

Open a filehandle, and while true, post to Blogger. If the length of the amount read from the file exceeds the per-post limit assigned by the Blogger servers -- currently 65,536 characters -- the contents of the file will be posted in multiple "chunks".

Valid arguments are 

=over 

=item *

B<file> (required)

/path/to/file

=item * 

B<postid> 

String.

=item * 

B<publish> 

Boolean.

=item * 

B<tail> 

Boolean.

If true, the method will not attempt to post data whose length exceeds the limit set by the Blogger server in the order that the data is read. Translation : last in becomes last post becomes the first thing you see on your weblog.

=back

If a I<postid> argument is present, the method will call the Blogger API I<editPost> method with postid. Otherwise the method will call the Blogger API I<newPost> method.

Returns true or false, followed by an array of zero, or more, postids. 

=head2 $pkg->PostFromOutline(%args)

Like I<PostFromFile>, only this time the file is an outliner document. 

This method uses Simon Kittle's Text::Outline::asRenderedHTML method for posting. As of this writing, the Text::Outline package has not been uploaded to the CPAN. See below for a link to the homepage/source.

Valid outline formats are OPML, tabbed text outline, Emacs' outline-mode format, and the GNOME Think format.

Valid arguments are 

=over 

=item * 

B<file> (required)

/path/to/file

=item * 

B<postid> 

String.

=item * 

B<publish> 

Boolean.

=back

If a I<postid> argument is present, the method will call the Blogger API I<editPost> method with postid. Otherwise the method will call the Blogger API I<newPost> method.

Returns true or false, followed by an array of zero, or more, postids. 

=cut

sub DESTROY {
    return 1;
}

sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s/.*:://;
    return $self->{"_class"}->$AUTOLOAD(@_);
}

=head1 VERSION

0.7

=head1 DATE

May 04, 2002

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

L<Net::Blogger::API::Core>

L<Net::Blogger::Engine::Base>

http://plant.blogger.com/api/

=head1 CHANGES

=head2 0.6.4

=over

=item *

Added support for the I<metaWeblog> API to the Movabletype engine.

=item *

Added quotes to all the VERSION numbers

=back

=head2 0.6.3

=over

=item *

Updated POD for I<Net::Blogger> and all child packages.

=back

=head2 0.6.2.2

=over

=item *

No changes. But, since I uploaded the current codebase to the CPAN as v 0.6.1.2, I decided to upload a new version with a new version number just to keep everyone on first.

=back

=head2 0.6.2.1

=over

=item * 

Updated POD.

=back

=head2 0.6.2

=over

=item * 

Added support for the UserLand metaWeblog API in the I<RadioUserLand> engine

=back

=head2 0.6.1

=over

=item *

Bugs fixes in I<Net::Blogger::Engine::Base>

=back

=head2 0.6

=over

=item *

Moved most of the code in to I<Net::Blogger::API::Core>, I<Net::Blogger::API::Extended>, I<Net::Blogger::Engine::Base> and I<Net::Blogger::Engine::Blogger>

=item *

Replaced use of Frontier::Client with XMLRPC::Litem (in I<Net::Blogger::Engine::Base>)

=item * 

Updated POD

=back

=head2 0.5.1

=over

=item *

Modified internals to load implementation specific subclass based on the I<engine> argument passed to the constructor. Props to Simon Kittles for the smack upside the head about the right way to do this :-)

=item * 

Updated POD.

=back

=head2 0.5

=over

=item * 

Added Blogger API I<getPost> method.

=item *

Updated POD.

=back

=head2 0.4.6.1

=over

=item *

Added conditional, where necessary, to see if a maximum post length is applicable.

=back

=head2 0.4.6

=over

=item *

Added Blogger.pm I<BLOGGER_PROXY> constant.

=item *

Added Blogger.pm I<Proxy> and I<MaxPostPostLength> accessors for corresponding constants. Previously, these values were either read from a scalar constant or an AUTOLOAD method. The change allows [insert blogger-mimicking interface here] subclasses to override the methods and specify an approriate value.

=item * 

Updated POD

=back

=head2 0.4.5

=over

=item * 

Added Blogger API I<getRecentPosts> method.

=item *

Updated POD

=back

=head2 0.4.4.1

=over

=item *

Clarified a few error messages;

=item *

Fixed remaining instances of "Error::Simple->record() and return 0" in &AUTOLOAD

=back

=head2 0.4.4

=over

=item * 

Added use of Error.pm

=item * 

Added Blogger.pm I<LastError> method.

=item * 

Wrapped Frontier::Client method calls in eval statements to prevent unnecessary die-ing.

=item * 

Added stub function and methods calls for Blogger.pm private I<_TrimPostBody> method.

=item * 

Changed return value of Blogger.pm I<PostFromFile> to (boolean, array)

=item * 

Updated POD.

=back

=head2 0.4.3

=over

=item * 

Made sure all Blogger.pm methods begin with title case.

=back

=head2 0.4.2

=over

=item * 

Added private Blogger.pm I<_Encode> method. Code courtesy of Matt Sergeant's rssmirror.pl script. I<Someone, give this guy a YAS grant.>

=item *

Added --tail flag to Blogger.pm I<PostFromFile> method.

=item * 

Fixed a bug in Blogger.pm I<_PostInChunks> method where I would end up subscripting outside of the string.

=back

=head2 0.4.1

=over

=item *

Added idiot-level escaping of entities in Blogger.pm I<newPost> and I<editPost> methods. Duh.

=back

=head2 0.4

=over

=item *

Switched to named-based pair arguments.

=item *

Added Blogger API I<deletePost> method.

=item * 

Added the Blogger.pm I<PostFromFile> method. I<Experimental>

=item *

Changed Blogger.pm MAX_POSTLENGTH constant.

=item *

Updated POD

=back

=head2 0.3.1

=over

=item *

Updated POD

=back

=head2 0.3

=over

=item *

Added the Blogger API I<getTemplate> and I<setTemplate> methods.

=item * 

Added the Blogger.pm I<_PostInChunks> method.

=item * 

Changed the order in which parameters are passed to I<editPost>.

=item * 

Changed the return value of both the Blogger API I<newPost> and I<editPost> methods.

=back

=head2 0.2

=over

=item * 

Added the Blogger API I<getUsersBlogs> and I<editPost> methods.

=item * 

Adde the Blogger.pm I<GetBlogId> method.

=item * 

Removed the Blogger.pm I<Publish> method.

=item *

Modifed the Blogger API I<newPost> method to accept the option to publish. 


=back

=head2 0.1

=over

=item *

Initial setup.

=item *

Added the constructor methods.

=item *

Added the Blogger API I<newPost> method.

=item *

Added the Blogger.pm I<Publish> method.


=back

=head1 LICENSE

Copyright (c) 2001-2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
