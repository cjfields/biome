use strict;
use warnings;

BEGIN {
	use lib '.';
	use Test::More;
	use Test::Moose;
	use Test::Exception;
    use_ok('Biome::Location::Split');
}

use Biome::Location::Simple;

# split location tests
my $container = Biome::Location::Split->new();

# most complex Range role
does_ok($container, 'Biome::Role::Location::Split');
does_ok($container, 'Biome::Role::Location::Locatable');

my $f = Biome::Location::Simple->new(-start  => 13,
				  -end    => 30,
				  -strand => 1);
$container->add_sub_Location($f);
is($f->start, 13);
is($f->min_start, 13);
is($f->max_start,13);

$f = Biome::Location::Simple->new(-start  =>30,
			       -end    =>90,
			       -strand =>1);
$container->add_sub_Location($f);

$f = Biome::Location::Simple->new(-start  =>18,
			       -end    =>22,
			       -strand =>1);
$container->add_sub_Location($f);

$f = Biome::Location::Simple->new(-start  =>19,
			       -end    =>20,
			       -strand =>1);

$container->add_sub_Location($f);

$f = Biome::Location::Simple->new(
                  -start_pos_type => '<',
                  -start  => 50,
			      -end    => 61,
			      -strand => 1);
is($f->start, 50);
is($f->to_string(), '<50..61');

ok(! defined $f->min_start);
is($f->max_start, 50);

is($container->num_sub_Locations(), 4);

is($container->max_end, 90);
is($container->min_start, 13);
is($container->start, 13);
is($container->end, 90);

$container->add_sub_Location($f);
is($container->num_sub_Locations(), 5);

my $simple = Biome::Location::Simple->new(location_string => '10..20');

my $fuzzy = Biome::Location::Simple->new( location_string  => '<10..20');

$fuzzy->strand(-1);
is($fuzzy->to_string(), 'complement(<10..20)');


is($simple->to_string(), '10..20');
$simple->strand(-1);
is($simple->to_string(), 'complement(10..20)');
is( $container->to_string(),
    'join(13..30,30..90,18..22,19..20,<50..61)');

# test for bug #1074
$f = Biome::Location::Simple->new(-start  => 5,
			       -end    => 12,
			       -strand => -1);
$container->add_sub_Location($f);
is( $container->to_string(),
    'join(13..30,30..90,18..22,19..20,<50..61,complement(5..12))',
	'Bugfix 1074');
$container->strand(-1);

TODO: {
    local $TODO = "Check this test, may not be correct with this implementation";
    is( $container->to_string(),
    'complement(join(13..30,30..90,18..22,19..20,<50..61,5..12))');
}

# test that can call seq_id() on a split location;
$container = Biome::Location::Split->new(seq_id => 'mysplit1');
is($container->seq_id,'mysplit1', 'seq_id() on Bio::Location::Split');
is($container->seq_id('mysplit2'),'mysplit2');

done_testing();

__END__