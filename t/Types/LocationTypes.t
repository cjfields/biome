# -*-Perl-*- Test Harness script for Biome

use strict;

BEGIN { 
    use lib '.';
    use Test::More tests => 22;
    use Test::Moose;
    use Test::Exception;
}

{
    package Foo;
    use Biome;
    use Biome::Types qw(LocationType LocationSymbol);
    has pos_type      => (
        isa     => LocationType,
        is      => 'rw',
        coerce  => 1
    );
    
    no Biome;
}

my %real_types = map {$_ => 1} qw(. .. ^ ? < > EXACT WITHIN BETWEEN BEFORE AFTER UNCERTAIN);

my %symbols = (
    '..'         => 'EXACT',
    '<'          => 'BEFORE',
    '>'          => 'AFTER',
    '.'          => 'WITHIN',
    '^'          => 'BETWEEN',
    '?'          => 'UNCERTAIN'
    );

for my $st (qw(. .. ^ ? ! < > : EXACT WITHIN BETWEEN BEFORE UNDER AFTER OVER UNCERTAIN)) {
    my $test_obj;
    if (exists $real_types{$st}) {
        lives_ok {
            $test_obj = Foo->new(-pos_type => $st);
            } "$st is a valid LocationType";
        if (exists $symbols{$st}) {
            is($test_obj->pos_type, $symbols{$st}, "$st coerced to $symbols{$st}");
        }
    } else {
        throws_ok {
            $test_obj = Foo->new(-pos_type => $st)
            } qr/Unknown Location type/, "$st is not a valid LocationType";
    }
}
