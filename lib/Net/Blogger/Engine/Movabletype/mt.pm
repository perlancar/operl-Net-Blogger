{

=head1 NAME

mt - Adds support for the MovableType XML-RPC API

=head1 SYNOPSIS

 use Net::Blogger;
 
 use Carp;
 use Data::Dumper;

 my $mt = Net::Blogger->new(engine=>"movabletype");
  
 $mt->Proxy("http://yaddayadda.com/mt-xmlrpc.cgi");
 $mt->Username("asc");
 $mt->Password("*****");
 $mt->BlogId(123);
  
 $mt->newPost(postbody=>\&fortune(),publish=>1)
   || croak $mt->LastError();
  
 my $id = $mt->metaWeblog()->newPost(title=>"test:".time,
  				     description=>&fortune(),
				      publish=>1)
   || croak $mt->LastError();
    
 my $categories = $mt->mt()->getCategoryList()
   || croak $mt->LastError();
  
 my $cid = $categories->[0]->{categoryId};
    
 $mt->mt()->setPostCategories(postid=>$id,
                              categories=>[{categoryId=>$cid}])
   || croak $mt->LastError();
  
 print &Dumper($mt->mt()->getPostCategories(postid=>$id));
  
 sub fortune {
   local $/;
   undef $/;
  
   system ("fortune > /home/asc/tmp/fortune");
  
   open F, "</home/asc/tmp/fortune";
   my $fortune = <F>;
   close F;
  
   return $fortune;
 }
  
=head1 DESCRIPTION

Adds support for the MovableType XML-RPC API

=cut

package Net::Blogger::Engine::Movabletype::mt;
use strict;

use Exporter;
use Net::Blogger::Engine::Base;

$Net::Blogger::Engine::Movabletype::mt::VERSION   = '0.1.2';

@Net::Blogger::Engine::Movabletype::mt::ISA       = qw ( Exporter Net::Blogger::Engine::Base );
@Net::Blogger::Engine::Movabletype::mt::EXPORT    = qw ();
@Net::Blogger::Engine::Movabletype::mt::EXPORT_OK = qw ();

=head1 OBJECT METHODS

=head2 $pkg->getCategoryList()

Returns an array ref of hash references.

=cut

sub getCategoryList {
  my $self = shift;

  my $call = $self->_Client()->call(
				    "mt.getCategoryList",
				    $self->_Type(string=>$self->BlogId()),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    );

  return ($call) ? $call->result() : undef;
}

=head2 $pkg->getPostCategories(%args)

Valid arguments are 

=over

=item *

B<postid>

String. Required.

=back

Returns an array ref of hash references

=cut

sub getPostCategories {
  my $self = shift;
  my $args = {@_};

  if (! $args->{'postid'}) {
    $self->LastError("You must specify a postid");
    return undef;
  }

  my $call = $self->_Client()->call(
				    "mt.getPostCategories",
				    $self->_Type(string=>$args->{'postid'}),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    );

  return ($call) ? $call->result() : undef;
}

=head2 $pkg->setPostCategories(%args)

Valid argument are

=over

=item *

B<postid>

String. Required

B<categories>

Array ref. Required.

The MT docs state that :

=over

=item 

The array categories is an array of structs containing 

=over

=item 

B<categoryId>

String.

=item

B<isPrimary>

Using isPrimary to set the primary category is optional--in the absence of this flag, the first struct in the array will be assigned the primary category for the post

=back

=back

=back

Returns true or false

=cut

sub setPostCategories {
  my $self = shift;
  my $args = {@_};
  
  if (! $args->{'postid'}) {
    $self->LastError("You must specify a postid");
    return undef;
  }

  if (ref($args->{'categories'}) ne "ARRAY") {
    $self->LastError("You must pass category data as an array reference.");
    return undef;
  }

  foreach my $struct (@{$args->{'categories'}}) {
    if (! $struct->{'categoryId'}) {
      $self->LastError("Category struct requires a categoryId.");
      return undef;
    }
  }

  my $call = $self->_Client()->call(
				    "mt.setPostCategories",
				    $self->_Type(string=>$args->{'postid'}),
				    $self->_Type(string=>$self->Username()),
				    $self->_Type(string=>$self->Password()),
				    $self->_Type(array=>$args->{'categories'}),
				    );

  return ($call) ? $call->result() : undef;
}

=head2 $pkg->supportMethods()

Returns an array reference.

=cut

sub supportedMethods {
  my $self = shift;
  my $call = $self->_Client()->call("mt.setPostCategories");
  return ($call) ? $call->result() : undef;
}

=head1 VERSION

0.1.2

=head1 DATE

May 04, 2002

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO 

L<Net::Blogger::Engine::Base>

http://www.movabletype.org/mt-static/docs/mtmanual_programmatic.html#xmlrpc%20api

=head1 LICENSE

Copyright (c) 2002, Aaron Straup Cope. All Rights Reserved.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
