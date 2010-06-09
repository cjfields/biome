use strict;
use warnings;

BEGIN {
	use lib '.';
	use Test::More;
	use Test::Moose;
	use Test::Exception;
    use_ok('Biome::Segment::Split');
}

use Biome::Segment::Simple;

# split location tests
my $container = Biome::Segment::Split->new();
my $f = Biome::Segment::Simple->new(-start  => 13,
				  -end    => 30,
				  -strand => 1);
$container->add_sub_Segment($f);
is($f->start, 13);
is($f->min_start, 13);
is($f->max_start,13);

$f = Biome::Segment::Simple->new(-start  =>30,
			       -end    =>90,
			       -strand =>1);
$container->add_sub_Segment($f);

$f = Biome::Segment::Simple->new(-start  =>18,
			       -end    =>22,
			       -strand =>1);
$container->add_sub_Segment($f);

$f = Biome::Segment::Simple->new(-start  =>19,
			       -end    =>20,
			       -strand =>1);

$container->add_sub_Segment($f);

$f = Biome::Segment::Simple->new(
                  -start_pos_type => '<',
                  -start  => 50,
			      -end    => 61,
			      -strand => 1);
is($f->start, 50);
is($f->to_string(), '<50..61');

TODO: {
    local $TODO = 'Not implemented for fuzzy locations yet';
    ok(0);
    #ok(! defined $f->min_start);
    #is($f->max_start, 50);
}

is($container->num_sub_Segments(), 4);

#is($container->max_end, 90);
#is($container->min_start, 13);
is($container->start, 13);
is($container->end, 90);

$container->add_sub_Segment($f);
is($container->num_sub_Segments(), 5);

done_testing();

__END__

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