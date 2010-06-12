# -*-Perl-*- Test Harness script for Biome

use strict;

BEGIN { 
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
}

{
    package Foo;
    use Biome;
    use Biome::Types qw(Segment_Pos_Type Segment_Type);
    has pos_type      => (
        isa     => Segment_Pos_Type,
        is      => 'rw',
        coerce  => 1
    );

    has segment_type      => (
        isa     => Segment_Type,
        is      => 'rw',
        coerce  => 1
    );
    
    no Biome;
}

my %real_types = (
    'segment_type' => {
                       map { $_ => 1}
                       qw(.. ^ . EXACT IN_BETWEEN WITHIN)
                       },
    'pos_type' => {
                   map { $_ => 1}
                   qw(< > . ? .. EXACT BEFORE AFTER WITHIN UNCERTAIN)
                   }
);

map {$_ => 1} qw(. .. ^ ? < > EXACT WITHIN IN-BETWEEN BEFORE AFTER UNCERTAIN);

my %symbols = (
    'segment_type' => {
        '..'         => 'EXACT',
        '^'          => 'IN-BETWEEN',
        '.'          => 'WITHIN',
    },
    'pos_type' => {
        '..'         => 'EXACT',        
        '<'          => 'BEFORE',
        '>'          => 'AFTER',
        '.'          => 'WITHIN',
        '?'          => 'UNCERTAIN'
    },
);

for my $st (qw(. .. ^ ? ! < > : EXACT WITHIN BETWEEN BEFORE
            UNDER AFTER OVER UNCERTAIN)) {
    my $test_obj;
    for my $att (qw(segment_type pos_type)) {
        if (exists $real_types{$att}{$st}) {
            lives_ok {
                $test_obj = Foo->new("-$att" => $st);
                } "$st is a valid Segment $att type";
            if (exists $symbols{$att}{$st}) {
                is($test_obj->$att, $symbols{$att}{$st},
                   "$st coerced to ".$symbols{$att}{$st});
            }
        } else {
            throws_ok {
                $test_obj = Foo->new("-$att" => $st)
                } qr/Attribute\s\($att\)\sdoes\snot\spass/xms,
            "$st is not a valid LocationType";
        }
    }
}

done_testing();