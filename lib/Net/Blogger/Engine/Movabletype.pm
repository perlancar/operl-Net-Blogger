{

=head1 NAME 

Net::Blogger::Engine::Movabletype

=head1 SYNOPSIS

 TBW

=head1 DESCRIPTION

This package inherits I<Net::Blogger::Engine::Base> and implements methods specific to a MovableType XML-RPC server.

=cut

package Net::Blogger::Engine::Movabletype;
use strict;

$Net::Blogger::Engine::Movabletype::VERSION   = 0.1.1;
@Net::Blogger::Engine::Movabletype::ISA       = qw ( Exporter Net::Blogger::Engine::Base );
@Net::Blogger::Engine::Movabletype::EXPORT    = qw ();
@Net::Blogger::Engine::Movabletype::EXPORT_OK = qw ();

use Exporter;
use Net::Blogger::Engine::Base;

=head1 Blogger API METHODS

=head2 $pkg->getRecentPosts(%args)

=cut

sub getRecentPosts {
    my $self = shift;
    my %args = @_;

    my $num   = (defined $args{'numposts'}) ? $args{'numposts'} : 1;
    my $posts = [];

    unless ($num =~ /^(-)*(\d+)$/) {
	$self->LastError("Argument $args{'numposts'} isn't numeric.");
        return 0;
    }

    if ($num > -1) { $num = 0; }

    return $self->SUPER::getRecentPosts(%args);
}

=head1 VERSION

0.1.1

=head1 DATE

$Date: 2002/01/29 15:13:16 $

=head1 AUTHOR

Aaron Straup Cope

=head1 SEE ALSO

http://aaronland.net/weblog/archive/3719

=head1 CHANGES

=head2 0.1.1

=over

=item 

Updated POD

=back

=head2 0.1

=over

=item 

Initial revision

=back

=head1 LICENSE

Copyright (c) 2001-2002 Aaron Straup Cope.

This is free software, you may use it and distribute it under the same terms as Perl itself.

=cut

return 1;

}
