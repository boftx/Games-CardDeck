package Games::CardDeck::Card;

use 5.010;
our $VERSION = 'vb0.01_01';

use strictures;

use Types::Standard qw( Str Int );

use Moo;
use MooX::StrictConstructor;

use constant RANKNAMES => {
    1  => 'Ace',
    2  => 'Deuce',
    3  => 'Trey',
    4  => 'Four',
    5  => 'Five',
    6  => 'Six',
    7  => 'Seven',
    8  => 'Eight',
    9  => 'Nine',
    10 => 'Ten',
    11 => 'Jack',
    12 => 'Queen',
    13 => 'King',
    14 => 'Ace',
};

use constant RANKSNAMES => {
    1  => 'A',
    2  => '2',
    3  => '3',
    4  => '4',
    5  => '5',
    6  => '6',
    7  => '7',
    8  => '8',
    9  => '9',
    10 => 'T',
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    14 => 'A',
};

has suit => (
    is       => 'ro',
    required => 1,
);

has rank => (
    is       => 'ro',
    isa      => Int->where( '$_ >= 1 && $_ <= 14' ),
    required => 1,
);

has rank_name => (
    is  => 'lazy',
    isa => Str,
);

has rank_sname => (
    is  => 'lazy',
    isa => Str,
);

has color => ( is => 'ro', );

has name => (
    is  => 'lazy',
    isa => Str,
);

has sname => (
    is  => 'lazy',
    isa => Str,
);

sub BUILD {
    my $self = shift;

    #$self->rank_name;
    #$self->rank_sname;
    $self->name;
    $self->sname;
}

sub _build_rank_name {
    my $self = shift;

    return RANKNAMES()->{ $self->rank };
}

sub _build_rank_sname {
    my $self = shift;

    return RANKSNAMES()->{ $self->rank };
}

sub _build_name {
    my $self = shift;

    return join( ' of ', $self->rank_name, $self->suit );
}

sub _build_sname {
    my $self = shift;

    return join( '', $self->rank_sname, lc( substr( $self->suit, 0, 1 ) ) );
}

1;    # End of Games::CardDeck

__END__

=head1 NAME

Games::CardDeck::Card - Create a single playing card

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Games::CardDeck;

    my $foo = Games::CardDeck->new();
    ...

=head1 EXPORT

Not appicable.

=head1 CONSTRUCTOR

=head1 ACCESSORS

=head1 METHODS

=head2 function1

=head1 AUTHOR

Jim Bacon, C<< <boftx at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-games-carddeck at rt.cpan.org>, or through the web interface at
L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-CardDeck>.

I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::CardDeck

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Games-CardDeck>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Games-CardDeck>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Games-CardDeck>

=item * Search CPAN

L<https://metacpan.org/release/Games-CardDeck>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2023 by Jim Bacon.

This is free software, licensed under any of the following:
  
  The Artistic License 2.0 (GPL Compatible)
  The same terms as Perl itself, either Perl version 5.8.8
  Any later version of Perl 5 you may have available.
  
=cut
