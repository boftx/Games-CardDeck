#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Games::CardDeck' ) || print "Bail out!\n";
}

diag( "Testing Games::CardDeck $Games::CardDeck::VERSION, Perl $], $^X" );
