use strict;
use warnings;

BEGIN {
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Segment::Simple');
}

# this implementation should cover both Simple and Fuzzy implementations

=head1 Segments

Segments are Bio::Role::Range consumers that allow for more fuzzily defined
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
does_ok($simple, 'Biome::Role::Range',  'has Range');

is($simple->start, 10, 'has a start location');
is($simple->end, 20,  'has an end location');
is($simple->seq_id, 'my1',  'has an identifier');
is($simple->start_pos_type, 'EXACT', 'pos_type is EXACT for start');
is($simple->end_pos_type, 'EXACT', 'pos_type is EXACT for end');
ok($simple->valid_Segment);
is($simple->segment_type, 'EXACT',  'has a default segment type');
ok(!$simple->is_fuzzy);

is ($simple->to_string, 'my1:10..20', 'full FT string');

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

is ($f->to_string, 'complement(20..100)','full FT string');

my $exact = Biome::Segment::Simple->new(
                    -start         => 10,
                    -end           => 11,
                    -segment_type  => 'IN-BETWEEN',
                    -strand        => 1, 
                    -seq_id        => 'my2');

is($exact->start, 10, 'Biome::Segment::Simple IN-BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->segment_type, 'IN-BETWEEN');
ok(!$exact->is_fuzzy);

is ($exact->to_string, 'my2:10^11','full FT string');

# check coercions with segment_type and strand
$exact = Biome::Segment::Simple->new(
                    -start         => 10, 
                    -end           => 11,
                    -segment_type  => '^',
                    -strand        => '+');

is($exact->start, 10, 'Bio::Segment::Simple IN-BETWEEN');
is($exact->end, 11);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, undef);
is($exact->length, 0);
is($exact->segment_type, 'IN-BETWEEN');
is($exact->start_pos_type, 'EXACT');
is($exact->end_pos_type, 'EXACT');

is($exact->to_string, '10^11', 'full FT string');

$exact = Biome::Segment::Simple->new(
                    -start          => 10, 
                    -end            => 20,
                    -start_pos_type => '<',
                    -end_pos_type   => '>', # this should default to 'EXACT'
                    -strand         => '+');

is($exact->start, 10);
is($exact->end, 20);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, undef);
is($exact->length, 11);

# this doesn't seem correct, shouldn't it be 'FUZZY' or 'UNCERTAIN'?
is($exact->segment_type, 'EXACT');

is($exact->start_pos_type, 'BEFORE');
is($exact->end_pos_type, 'AFTER');
ok($exact->is_fuzzy);

is($exact->to_string, '<10..>20', 'full FT string');

# check coercions with start/end_pos_type, and length determination
$exact = Biome::Segment::Simple->new(
                    -start          => 10, 
                    -end            => 20,
                    -start_pos_type => '<',
                    -strand         => '+');

is($exact->start, 10);
is($exact->end, 20);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, undef);
is($exact->length, 11);
is($exact->segment_type, 'EXACT');
is($exact->start_pos_type, 'BEFORE');
is($exact->end_pos_type, 'EXACT');

is($exact->to_string, '<10..20', 'full FT string');

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
  
  
throws_ok {$exact = Biome::Segment::Simple->new(-start         => 10, 
                                   -end           => 12,
                                   -segment_type => 'IN-BETWEEN')}
    qr/length of segment with IN-BETWEEN/,
    'IN-BETWEEN must have length of 1';  

# fuzzy location tests
my $fuzzy = Biome::Segment::Simple->new(
                                     -start    => 10,
                                     -start_pos_type => '<',
                                     -end      => 20,
                                     -strand   => 1, 
                                     -seq_id   =>'my2');

is($fuzzy->strand, 1, 'Biome::Segment::Simple tests');
is($fuzzy->start, 10);
is($fuzzy->end,20);
#ok(!defined $fuzzy->min_start);
#is($fuzzy->max_start, 10);
#is($fuzzy->min_end, 20);
#is($fuzzy->max_end, 20);
is($fuzzy->segment_type, 'EXACT');
is($fuzzy->start_pos_type, 'BEFORE');
is($fuzzy->end_pos_type, 'EXACT');
is($fuzzy->seq_id, 'my2');
is($fuzzy->seq_id('my3'), 'my3');

=head1 Old BioPerl tests

These will gradually be converted over and used as a test base

=cut

#($loc) = $fuzzy->each_Location();
#ok($loc);
#is("$loc", "$fuzzy");
#
## split location tests
#my $splitlocation = Bio::Location::Split->new();
#my $f = Bio::Location::Simple->new(-start  => 13,
#                                  -end    => 30,
#                                  -strand => 1);
#$splitlocation->add_sub_Location($f);
#is($f->start, 13, 'Bio::Location::Split tests');
#is($f->min_start, 13);
#is($f->max_start,13);

#$f = Bio::Location::Simple->new(-start  =>30,
#                               -end    =>90,
#                               -strand =>1);
#$splitlocation->add_sub_Location($f);
#
#$f = Bio::Location::Simple->new(-start  =>18,
#                               -end    =>22,
#                               -strand =>1);
#$splitlocation->add_sub_Location($f);
#
#$f = Bio::Location::Simple->new(-start  =>19,
#                               -end    =>20,
#                               -strand =>1);
#
#$splitlocation->add_sub_Location($f);
#
#$f = Bio::Location::Fuzzy->new(-start  =>"<50",
#                              -end    =>61,
#                              -strand =>1);
#is($f->start, 50);
#ok(! defined $f->min_start);
#is($f->max_start, 50);
#
#is(scalar($splitlocation->each_Location()), 4);
#
#$splitlocation->add_sub_Location($f);
#
#is($splitlocation->max_end, 90);
#is($splitlocation->min_start, 13);
#is($splitlocation->end, 90);
#is($splitlocation->start, 13);
#is($splitlocation->sub_Location(),5);

#is($fuzzy->to_string(), '<10..20');
#$fuzzy->strand(-1);
#is($fuzzy->to_string(), 'complement(<10..20)');
#is($simple->to_string(), '10..20');
#$simple->strand(-1);
#is($simple->to_string(), 'complement(10..20)');
#is( $splitlocation->to_string(), 
#    'join(13..30,30..90,18..22,19..20,<50..61)');

# test for bug #1074
#$f = Bio::Location::Simple->new(-start  => 5,
#                               -end    => 12,
#                               -strand => -1);
#$splitlocation->add_sub_Location($f);
#is( $splitlocation->to_string(), 
#    'join(13..30,30..90,18..22,19..20,<50..61,complement(5..12))',
#        'Bugfix 1074');
#$splitlocation->strand(-1);
#is( $splitlocation->to_string(), 
#    'complement(join(13..30,30..90,18..22,19..20,<50..61,5..12))');

#$f = Bio::Location::Fuzzy->new(-start => '45.60',
#                              -end   => '75^80');
#
#is($f->to_string(), '(45.60)..(75^80)');
#$f->start('20>');
#is($f->to_string(), '>20..(75^80)');

# test that even when end < start that length is always positive

$f = Biome::Segment::Simple->new(
                               -strict  => -1,
                               -start   => 100, 
                               -end     => 20, 
                               -strand  => 1);

is($f->length, 81, 'Positive length');
is($f->strand,-1);

# test that can call seq_id() on a split location;
#$splitlocation = Bio::Location::Split->new(-seq_id => 'mysplit1');
#is($splitlocation->seq_id,'mysplit1', 'seq_id() on Bio::Location::Split');
#is($splitlocation->seq_id('mysplit2'),'mysplit2');

# Test Biome::Segment::Simple

ok($exact = Biome::Segment::Simple->new(-start    => 10, 
                                         -end      => 20,
                                         -strand   => 1, 
                                         -seq_id   => 'my1'));
does_ok($exact, 'Biome::Role::Range');

is( $exact->start, 10, 'Biome::Segment::Simple EXACT');
is( $exact->end, 20);
is( $exact->seq_id, 'my1');
is( $exact->length, 11);
is( $exact->segment_type, 'EXACT');

ok ($exact = Biome::Segment::Simple->new(-start         => 10, 
                                      -end           => 11,
                                      -segment_type => 'IN-BETWEEN',
                                      -strand        => 1, 
                                      -seq_id        => 'my2'));

is($exact->start, 10, 'Biome::Segment::Simple BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->segment_type, 'IN-BETWEEN');

# 'fuzzy' segments are combined with simple ones in Biome

my $error = qr/length of segment with IN-BETWEEN position type cannot be larger than 1/;

# testing error when assigning 10^12 simple location into fuzzy
throws_ok {
    $fuzzy = Biome::Segment::Simple->new(
                                        -start         => 10, 
                                        -end           => 12,
                                        -segment_type  => '^',
                                        -strand        => 1, 
                                        -seq_id        => 'my2');
} $error, 'Exception:IN-BETWEEN locations should be contiguous';

$fuzzy = Biome::Segment::Simple->new(-segment_type => '^',
                                  -strand        => 1, 
                                  -seq_id        => 'my2');

$fuzzy->start(10);
throws_ok { $fuzzy->end(12) } $error, 'Exception:IN-BETWEEN locations should be contiguous';

$fuzzy = Biome::Segment::Simple->new(-segment_type => '^',
                                  -strand        => 1, 
                                  -seq_id        =>'my2');

$fuzzy->end(12);
throws_ok { $fuzzy->start(10); } $error, 'Exception:IN-BETWEEN locations should be contiguous';

####### No coordinate policies #######

done_testing;

__END__

