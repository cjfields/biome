use strict;
use warnings;

BEGIN {
    use lib '.';
    use Test::More tests => 62;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Segment::Simple');
}

# this implementation should cover both Simple and Fuzzy implementations

=head1 Segments

Segments are Bio::Role::Rangeable consumers that allow for more fuzzily defined
start/end points, but are also more lightweight in nature than BioPerl's
Locations.

In keeping with this, by default these are NOT layered (i.e. there is no
Splitlocation-type Segment).

=cut

my $simple = Biome::Segment::Simple->new(
    -start  => 10,
    -end    => 20,
    -strand => 1,
    -seq_id => 'my1');
isa_ok($simple, 'Biome::Segment::Simple');
does_ok($simple, 'Biome::Role::Segment',  'does Segment');
does_ok($simple, 'Biome::Role::Rangeable',  'has Rangeable');

is($simple->start, 10, 'has a start location');
is($simple->end, 20,  'has an end location');
is($simple->seq_id, 'my1',  'has an identifier');
is($simple->start_pos_type, 'EXACT', 'pos_type is EXACT for start');
is($simple->end_pos_type, 'EXACT', 'pos_type is EXACT for end');
ok($simple->valid_Segment);
is($simple->segment_type, 'EXACT',  'has a default segment type');

is ($simple->pos_string('start'), '10', 'start pos_string');
is ($simple->pos_string('end'), '20', 'end pos_string');
is ($simple->to_FTstring, '10..20', 'full FT string');

#my ($loc) = $simple->all_Segments();
#ok($loc);
#is("$loc", "$simple",  'is a Biome::Segment::Simple object');

# test that even when end < start that length is always positive
my $f = Biome::Segment::Simple->new(
        -strict  => -1,
        -start   => 100, 
        -end     => 20, 
        -strand  => 1);

is($f->length, 81, 'Positive length');
is($f->strand,-1,  'Negative strand' );

is ($f->pos_string('start'), '20', 'start pos_string');
is ($f->pos_string('end'), '100', 'end pos_string');
is ($f->to_FTstring, 'complement(20..100)','full FT string');

my $exact = Biome::Segment::Simple->new(
                    -start         => 10, 
                    -end           => 11,
                    -segment_type  => 'BETWEEN',
                    -strand        => 1,
                    -seq_id        => 'my2');

is($exact->start, 10, 'Biome::Segment::Simple BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->segment_type, 'BETWEEN');

is ($exact->pos_string('start'), '10', 'start pos_string');
is ($exact->pos_string('end'), '11', 'end pos_string');
is ($exact->to_FTstring, '10^11','full FT string');

# check coercions with segment_type and strand
$exact = Biome::Segment::Simple->new(
                    -start         => 10, 
                    -end           => 11,
                    -segment_type  => '^',
                    -strand        => '+', 
                    -seq_id        => 'my2');

is($exact->start, 10, 'Bio::Segment::Simple BETWEEN');
is($exact->end, 11);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->segment_type, 'BETWEEN');
is($exact->start_pos_type, 'BETWEEN');
is($exact->end_pos_type, 'BETWEEN');

is($exact->pos_string('start'), '10', 'start pos_string');
is($exact->pos_string('end'), '11', 'end pos_string');
is($exact->to_FTstring, '10^11', 'full FT string');

$exact = Biome::Segment::Simple->new(
                    -start          => 10, 
                    -end            => 20,
                    -start_pos_type => '<',
                    -end_pos_type   => '>', # this should default to 'EXACT'
                    -strand         => '+', 
                    -seq_id         => 'my2');

is($exact->start, 10);
is($exact->end, 20);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, 'my2');
is($exact->length, 11);
is($exact->segment_type, 'EXACT');
is($exact->start_pos_type, 'BEFORE');
is($exact->end_pos_type, 'AFTER');

is($exact->pos_string('start'), '<10', 'start pos_string');
is($exact->pos_string('end'), '20>', 'end pos_string');
is($exact->to_FTstring, '<10..20>', 'full FT string');

# check coercions with start/end_pos_type, and length determination
$exact = Biome::Segment::Simple->new(
                    -start          => 10, 
                    -end            => 20,
                    -start_pos_type => '<',
                    -strand         => '+', 
                    -seq_id         => 'my2');

is($exact->start, 10);
is($exact->end, 20);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, 'my2');
is($exact->length, 11);
is($exact->segment_type, 'EXACT');
is($exact->start_pos_type, 'BEFORE');
is($exact->end_pos_type, 'EXACT');

is($exact->pos_string('start'), '<10', 'start pos_string');
is($exact->pos_string('end'), '20', 'end pos_string');
is($exact->to_FTstring, '<10..20', 'full FT string');

# check exception handling
throws_ok { $exact = $exact = Biome::Segment::Simple->new(
                    -start          => 10, 
                    -end            => 12,
                    -start_pos_type => '>',
                    -strand         => '+') }
    qr/Start position can't have type AFTER/,
    'Check start_pos_type constraint';

throws_ok { $exact = $exact = Biome::Segment::Simple->new(
                    -start          => 10, 
                    -end            => 12,
                    -end_pos_type   => '<',
                    -strand         => '+') }
    qr/End position can't have type BEFORE/,
    'Check end_pos_type constraint';
    
=head1 Old BioPerl tests

These will gradually be converted over and used as a test base

=cut

__END__

# fuzzy location tests
my $fuzzy = Bio::Location::Fuzzy->new('-start'  =>'<10',
                                     '-end'    => 20,
                                     -strand   =>1, 
                                     -seq_id   =>'my2');

is($fuzzy->strand, 1, 'Bio::Location::Fuzzy tests');
is($fuzzy->start, 10);
is($fuzzy->end,20);
ok(!defined $fuzzy->min_start);
is($fuzzy->max_start, 10);
is($fuzzy->min_end, 20);
is($fuzzy->max_end, 20);
is($fuzzy->location_type, 'EXACT');
is($fuzzy->start_pos_type, 'BEFORE');
is($fuzzy->end_pos_type, 'EXACT');
is($fuzzy->seq_id, 'my2');
is($fuzzy->seq_id('my3'), 'my3');

($loc) = $fuzzy->each_Location();
ok($loc);
is("$loc", "$fuzzy");

# split location tests
my $splitlocation = Bio::Location::Split->new();
my $f = Bio::Location::Simple->new(-start  => 13,
                                  -end    => 30,
                                  -strand => 1);
$splitlocation->add_sub_Location($f);
is($f->start, 13, 'Bio::Location::Split tests');
is($f->min_start, 13);
is($f->max_start,13);


$f = Bio::Location::Simple->new(-start  =>30,
                               -end    =>90,
                               -strand =>1);
$splitlocation->add_sub_Location($f);

$f = Bio::Location::Simple->new(-start  =>18,
                               -end    =>22,
                               -strand =>1);
$splitlocation->add_sub_Location($f);

$f = Bio::Location::Simple->new(-start  =>19,
                               -end    =>20,
                               -strand =>1);

$splitlocation->add_sub_Location($f);

$f = Bio::Location::Fuzzy->new(-start  =>"<50",
                              -end    =>61,
                              -strand =>1);
is($f->start, 50);
ok(! defined $f->min_start);
is($f->max_start, 50);

is(scalar($splitlocation->each_Location()), 4);

$splitlocation->add_sub_Location($f);

is($splitlocation->max_end, 90);
is($splitlocation->min_start, 13);
is($splitlocation->end, 90);
is($splitlocation->start, 13);
is($splitlocation->sub_Location(),5);


is($fuzzy->to_FTstring(), '<10..20');
$fuzzy->strand(-1);
is($fuzzy->to_FTstring(), 'complement(<10..20)');
is($simple->to_FTstring(), '10..20');
$simple->strand(-1);
is($simple->to_FTstring(), 'complement(10..20)');
is( $splitlocation->to_FTstring(), 
    'join(13..30,30..90,18..22,19..20,<50..61)');

# test for bug #1074
$f = Bio::Location::Simple->new(-start  => 5,
                               -end    => 12,
                               -strand => -1);
$splitlocation->add_sub_Location($f);
is( $splitlocation->to_FTstring(), 
    'join(13..30,30..90,18..22,19..20,<50..61,complement(5..12))',
        'Bugfix 1074');
$splitlocation->strand(-1);
is( $splitlocation->to_FTstring(), 
    'complement(join(13..30,30..90,18..22,19..20,<50..61,5..12))');

$f = Bio::Location::Fuzzy->new(-start => '45.60',
                              -end   => '75^80');

is($f->to_FTstring(), '(45.60)..(75^80)');
$f->start('20>');
is($f->to_FTstring(), '>20..(75^80)');

# test that even when end < start that length is always positive

$f = Bio::Location::Simple->new(-verbose => -1,
                               -start   => 100, 
                               -end     => 20, 
                               -strand  => 1);

is($f->length, 81, 'Positive length');
is($f->strand,-1);

# test that can call seq_id() on a split location;
$splitlocation = Bio::Location::Split->new(-seq_id => 'mysplit1');
is($splitlocation->seq_id,'mysplit1', 'seq_id() on Bio::Location::Split');
is($splitlocation->seq_id('mysplit2'),'mysplit2');


# Test Bio::Location::Exact

ok(my $exact = Bio::Location::Simple->new(-start    => 10, 
                                         -end      => 20,
                                         -strand   => 1, 
                                         -seq_id   => 'my1'));
isa_ok($exact, 'Bio::LocationI');
isa_ok($exact, 'Bio::RangeI');

is( $exact->start, 10, 'Bio::Location::Simple EXACT');
is( $exact->end, 20);
is( $exact->seq_id, 'my1');
is( $exact->length, 11);
is( $exact->location_type, 'EXACT');

ok ($exact = Bio::Location::Simple->new(-start         => 10, 
                                      -end           => 11,
                                      -location_type => 'IN-BETWEEN',
                                      -strand        => 1, 
                                      -seq_id        => 'my2'));

is($exact->start, 10, 'Bio::Location::Simple IN-BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->location_type, 'IN-BETWEEN');

eval {
    $exact = Bio::Location::Simple->new(-start         => 10, 
                                       -end           => 12,
                                       -location_type => 'IN-BETWEEN');
};
ok( $@, 'Testing error handling' );

# testing error when assigning 10^11 simple location into fuzzy
eval {
    ok $fuzzy = Bio::Location::Fuzzy->new(-start         => 10, 
                                         -end           => 11,
                                         -location_type => '^',
                                         -strand        => 1, 
                                         -seq_id        => 'my2');
};
ok( $@ );

$fuzzy = Bio::Location::Fuzzy->new(-location_type => '^',
                                  -strand        => 1, 
                                  -seq_id        => 'my2');

$fuzzy->start(10);
eval { $fuzzy->end(11) };
ok($@);

$fuzzy = Bio::Location::Fuzzy->new(-location_type => '^',
                                  -strand        => 1, 
                                  -seq_id        =>'my2');

$fuzzy->end(11);
eval {
    $fuzzy->start(10);
};
ok($@);

# testing coodinate policy modules

use_ok('Bio::Location::WidestCoordPolicy');
use_ok('Bio::Location::NarrowestCoordPolicy');
use_ok('Bio::Location::AvWithinCoordPolicy');

$f = Bio::Location::Fuzzy->new(-start => '40.60',
                              -end   => '80.100');
is $f->start, 40, 'Default coodinate policy';
is $f->end, 100;
is $f->length, 61;
is $f->to_FTstring, '(40.60)..(80.100)';
isa_ok($f->coordinate_policy, 'Bio::Location::WidestCoordPolicy');

# this gives an odd location string; is it legal?
$f->coordinate_policy(Bio::Location::NarrowestCoordPolicy->new());
is $f->start, 60, 'Narrowest coodinate policy';
is $f->end, 80;
is $f->length, 21;
is $f->to_FTstring, '(60.60)..(80.80)';
isa_ok($f->coordinate_policy, 'Bio::Location::NarrowestCoordPolicy');

# this gives an odd location string
$f->coordinate_policy(Bio::Location::AvWithinCoordPolicy->new());
is $f->start, 50, 'Average coodinate policy';
is $f->end, 90;
is $f->length, 41;
is $f->to_FTstring, '(50.60)..(80.90)';
isa_ok($f->coordinate_policy, 'Bio::Location::AvWithinCoordPolicy');

# to complete the circle
$f->coordinate_policy(Bio::Location::WidestCoordPolicy->new());
is $f->start, 40, 'Widest coodinate policy';
is $f->end, 100;
is $f->length, 61;
is $f->to_FTstring, '(40.60)..(80.100)';
isa_ok($f->coordinate_policy, 'Bio::Location::WidestCoordPolicy');
