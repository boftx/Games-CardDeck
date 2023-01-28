package Games::CardDeck;

use 5.010;
our $VERSION = 'v0.01_01';

use strictures;

use Data::Dumper ('Dumper');
$Data::Dumper::Indent = 1;

use Types::Standard qw( Str Int Enum ArrayRef );

use Games::CardDeck::Card;

use Moo;
use MooX::StrictConstructor;

# this is for the _machine shuffle method
use constant SHELF_CNT => 13;

use constant SUITS => [qw(Spades Hearts Diamonds Clubs)];

has style => (
    is      => 'ro',
    isa     => Enum [qw( standard pinochle euchre )],
    coerce  => sub { my $tmp = $_[0]; $tmp =~ tr[A-Z][a-z]; return $tmp; },
    default => 'standard',
);

has decks => (
    is      => 'ro',
    isa     => Int->where('$_ > 0 && $_ < 100'),
    default => 1,
);

has cards => (
    is       => 'rwp',
    default  => sub { [] },
    init_arg => undef,
);

sub BUILD {
    my $self = shift;

    my $deck_builder = '_' . $self->style;
    for ( 1 .. $self->decks ) {
        $self->$deck_builder();
    }

    return;
}

sub size {
    my $self = shift;

    return scalar( @{ $self->cards } );
}

# this will produce a deck in FACE DOWN New Deck Order (NDO) when usingr
# "shift" to take cards cards from a deck.
# the cards will appear in FACE UP NDO when using pop or Dumper to view
# the deck.
sub _standard {
    my $self = shift;

    my $cards = $self->cards;
    for my $suit (qw( Spades Diamonds )) {
        for ( 1 .. 13 ) {
            push(
                @{$cards},
                Games::CardDeck::Card->new( suit => $suit, rank => $_ )
            );
        }
    }
    for my $suit (qw( Clubs Hearts )) {
        for ( 0 .. 12 ) {
            push(
                @{$cards},
                Games::CardDeck::Card->new( suit => $suit, rank => 13 - $_ )
            );
        }
    }

    return;
}

sub _pinochle {
    my $self = shift;

    my $cards = $self->cards;
    for my $suit (qw( Spades Diamonds )) {
        for ( 9 .. 14 ) {
            push(
                @{$cards},
                Games::CardDeck::Card->new( suit => $suit, rank => $_ ),
                Games::CardDeck::Card->new( suit => $suit, rank => $_ )
            );
        }
    }
    for my $suit (qw( Clubs Hearts )) {
        for ( 0 .. 5 ) {
            push(
                @{$cards},
                Games::CardDeck::Card->new( suit => $suit, rank => 14 - $_ ),
                Games::CardDeck::Card->new( suit => $suit, rank => 14 - $_ )
            );
        }
    }

    return;
}

sub _euchre {
    my $self = shift;

    my $cards = $self->cards;
    for my $suit (qw( Spades Diamonds )) {
        for ( 9 .. 14 ) {
            push(
                @{$cards},
                Games::CardDeck::Card->new( suit => $suit, rank => $_ )
            );
        }
    }
    for my $suit (qw( Clubs Hearts )) {
        for ( 0 .. 5 ) {
            push(
                @{$cards},
                Games::CardDeck::Card->new( suit => $suit, rank => 14 - $_ )
            );
        }
    }

    return;
}

sub cut {
    my $self = shift;
    my %args = @_;

    my $split = delete( $args{split} );

    my $cutpoint = int( $self->size / 2 );
    return unless $cutpoint;

    my $fudge = int( rand( $self->size / 13 ) );
    $fudge *= -1 if $fudge && int( rand(2) );
    $cutpoint += $fudge;

    my $cards = $self->cards;
    my @top   = splice( @{$cards}, 0, $cutpoint );

    push( @{$cards}, @top ) && return unless $split;

    # NOTE: this leave the cards attribute as an empty array
    my @bottom = splice( @{$cards}, 0, $self->size );

    return [ \@top, \@bottom ];
}

sub shuffle {
    my $self = shift;
    my %args = @_;

    my $style = delete( $args{style} );

    $style = '_' . $style if $style;
    croak('unknown shuffle style') unless $self->can($style);

    $self->_swap;
    $self->_riffle;

    return;
}

sub _swap {
    my $self = shift;

    my $cards = $self->cards;
    my $size  = $self->size;

    # shuffle in place
    for ( 0 .. $size - 1 ) {
        my $swap = int( rand($size) );
        ( $cards->[$_], $cards->[$swap] ) = ( $cards->[$swap], $cards->[$_] );
    }

    return;
}

sub _riffle {
    my $self = shift;
    my %args = @_;

    my $cnt = delete( $args{cnt} ) || 7;

    for ( 1 .. $cnt ) {

        #my $parts  = $self->cut( split => 1 );
        #my $first  = $parts->{top};
        #my $second = $parts->{bottom};
        my ( $first, $second ) = @{ $self->cut( split => 1 ) };
        ( $first, $second ) = ( $second, $first ) if int( rand(2) );

        my $cards = $self->cards;
        do {
            my $grp1 = int( rand(3) ) + 1;
            $grp1 = scalar( @{$first} ) if $grp1 > @{$first};

            my $grp2 = int( rand(3) ) + 1;
            $grp2 = scalar( @{$second} ) if $grp1 > @{$second};

            push( @{$cards}, ( splice( @{$first},  0, $grp1 ) ) );
            push( @{$cards}, ( splice( @{$second}, 0, $grp2 ) ) );
        } while ( @{$first} || @{$second} );
    }

    return;
}

sub _stripcut {
    my $self = shift;

    my $deck_size = $self->size;
    return unless $deck_size > 1;

    my $max_strip_cnt = $self->decks * 5;
    my $avg_strip     = int( $self->size / $max_strip_cnt );

    my @tmp   = ();
    my $cards = $self->cards;
    while ( $self->size ) {
        my $stripsize = $avg_strip + int( rand(5) );
        unshift( @tmp, splice( @{$cards}, 0, $stripsize ) );
    }
    push( @{$cards}, @tmp );

    return;
}

sub _machine {
    my $self = shift;

    my $cards = $self->cards;

    my %shelves;
    $shelves{ $_ - 1 } = [] for 1 .. SHELF_CNT;

    while ( @{$cards} ) {
        push( @{ $shelves{ int( rand(SHELF_CNT) ) + 1 } },
            shift( @{$cards} ) );
    }
    for ( 1 .. SHELF_CNT ) {
        #print "SHELF $_ has " . @{ $shelves{$_} } . " cards\n";
        while ( @{ $shelves{$_} } ) {
            ( $_ % 2 )
              ? unshift( @{$cards}, shift( @{ $shelves{$_} } ) )
              : unshift( @{$cards}, pop( @{ $shelves{$_} } ) );
        }
    }

    return;
}

1;    # End of Games::CardDeck

__END__

=head1 NAME

Games::CardDeck - Create standard or custom card decks

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
