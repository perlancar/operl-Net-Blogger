{

=head1 NAME

Net::Blogger::Manila

=head1 SYNOPSIS

 TBW

=head1 DESCRIPTION

This package inherits I<Net::Blogger::Engine::Userland> and implements methods specific to  UserLand Manila server.

=cut

package Net::Blogger::Engine::Manila;
use strict;

$Net::Blogger::Engine::Manila::VERSION   = 0.2.1;
@Net::Blogger::Engine::Manila::ISA       = qw ( Exporter Net::Blogger::Engine::Userland );
@Net::Blogger::Engine::Manila::EXPORT    = qw ();
@Net::Blogger::Engine::Manila::EXPORT_OK = qw ();

use Exporter;
use Net::Blogger::Engine::Userland;

=head1 CONSTRUCTOR METHODS

=head2 Net::Blogger::Manila->new(%args)

TBW

=cut

sub new {
    my $pkg  = shift;
    my %args = @_;

    my $self = {};
    bless $self,$pkg;
    
    if (! $self->SUPER::init(%args)) {
	return 0;
    }

    return $self;
}

=head1 Blogger API METHODS

=head2 $pkg->getUsersBlogs()

=cut

sub getUsersBlogs {
    my $self = shift;
    $self->LastError("Unsupported method.");
    return 0;
}

=head1 VERSION

0.2.1

=head1 DATE

$Date: 2002/01/29 15:10:27 $

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

Switched base class to Net::Blogger::Engine::Userland

=item

Update POD.

=back

=head2 0.1.1

=over

=item

Modified Net::Blogger::Manila.pm I<Proxy> method to conform to the way Manila servers do XML-RPC.

=item 

Added Net::Blogger::Manila.pm I<MaxPostLength> method.

=item

Added Net::Blogger::Manila.pm private I<init> method to handle possible proxy argument.

=item

Updated POD.

=back

=head2 0.1

=over

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

return 1;

}
