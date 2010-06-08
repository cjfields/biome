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

my $simple = Biome::Segment::Simple->new('-start' => 10, '-end' => 20,
				       '-strand' => 1, -seq_id => 'my1');

#my ($loc) = $simple->each_Location();
#ok($loc);
#is("$loc", "$simple",  'is a Bio::Location::Simple object');

# test that even when end < start that length is always positive
