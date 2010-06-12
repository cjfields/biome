# -*-Perl-*- Test Harness script for Biome

use strict;

BEGIN { 
    use lib '.';
    use Test::More tests => 13;
    use Test::Moose;
    use Test::Exception;
}

{
    package Foo;
    use Biome;
    use Biome::Types qw(Sequence_Strand);
    has strand      => (
        isa     => Sequence_Strand,
        is      => 'rw',
        coerce  => 1
    );
    
    no Biome;
}

my %results = map {$_ => 1} (-1..1, qw(+ - .));

my %symbols = (
    '+'     => 1,
    '.'     => 0,
    '-'     => -1
    );

for my $st ((-2..2, qw(+ . - ? ^))) {
    my $test_obj;
    if (exists $results{$st}) {
        lives_ok {
            $test_obj = Foo->new(-strand => $st);
            } "$st is a valid Sequence symbol";
        if (exists $symbols{$st}) {
            is($test_obj->strand, $symbols{$st}, "$st coerced to $symbols{$st}");
        }
    } else {
        throws_ok {$test_obj = Foo->new(-strand => $st)} qr/Strand can be -1/,
            "$st is not a valid LocationType";
    }
}
