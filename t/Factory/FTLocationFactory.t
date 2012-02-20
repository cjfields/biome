use strict;
use warnings;

BEGIN {
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
}

use Biome::Factory::FTLocationFactory;

# Holds strings and results. The latter is an array of expected class name,
# min/max start position and position type, min/max end position and position
# type, location type, the number of locations, and the strand.

my %testcases = (
   # note: the following are directly taken from
   # http://www.ncbi.nlm.nih.gov/collab/FT/#location
    "467" => [0,
        467, 467, "EXACT", 467, 467, "EXACT", "EXACT", 0, 1, undef],
    "340..565" => [0,
         340, 340, "EXACT", 565, 565, "EXACT", "EXACT", 0, 1, undef],
    "<345..500" => [0,
         undef, 345, "BEFORE", 500, 500, "EXACT", "EXACT", 0, 1, undef],
    "<1..888" => [0,
         undef, 1, "BEFORE", 888, 888, "EXACT", "EXACT", 0, 1, undef],

    "(102.110)" => [0,
         102, 102, "EXACT", 110, 110, "EXACT", "WITHIN", 0, 1, undef],
    "(23.45)..600" => [0,
         23, 45, "WITHIN", 600, 600, "EXACT", "EXACT", 0, 1, undef],
    "(122.133)..(204.221)" => [0,
         122, 133, "WITHIN", 204, 221, "WITHIN", "EXACT", 0, 1, undef],
    "123^124" => [0,
         123, 123, "EXACT", 124, 124, "EXACT", "IN-BETWEEN", 0, 1, undef],
    "145^146" => [0,
         145, 145, "EXACT", 146, 146, "EXACT", "IN-BETWEEN", 0, 1, undef],
    "J00194:100..202" => [0,
         100, 100, "EXACT", 202, 202, "EXACT", "EXACT", 0, 1, 'J00194'],

    # these variants are not really allowed by the FT definition
    # document but we want to be able to cope with it

    "J00194:(100..202)" => ['J00194:100..202',
         100, 100, "EXACT", 202, 202, "EXACT", "EXACT", 0, 1, 'J00194'],
    "((122.133)..(204.221))" => ['(122.133)..(204.221)',
         122, 133, "WITHIN", 204, 221, "WITHIN", "EXACT", 0, 1, undef],

    # UNCERTAIN locations and positions (Swissprot)
    "?2465..2774" => [0,
        2465, 2465, "UNCERTAIN", 2774, 2774, "EXACT", "EXACT", 0, 1, undef],
    "22..?64" => [0,
        22, 22, "EXACT", 64, 64, "UNCERTAIN", "EXACT", 0, 1, undef],
    "?22..?64" => [0,
        22, 22, "UNCERTAIN", 64, 64, "UNCERTAIN", "EXACT", 0, 1, undef],
    "?..>393" => [0,
        undef, undef, "UNCERTAIN", 393, undef, "AFTER", "EXACT", 0, 1, undef],
    "<1..?" => [0,
        undef, 1, "BEFORE", undef, undef, "UNCERTAIN", "EXACT", 0, 1, undef],
    "?..536" => [0,
        undef, undef, "UNCERTAIN", 536, 536, "EXACT", "EXACT", 0, 1, undef],
    "1..?" => [0,
        1, 1, "EXACT", undef, undef, "UNCERTAIN", "EXACT", 0, 1, undef],
    "?..?" => [0,
        undef, undef, "UNCERTAIN", undef, undef, "UNCERTAIN", "EXACT", 0, 1, undef],
    "1..?12" => [0,
        1, 1, "EXACT", 12, 12, "UNCERTAIN", "EXACT", 0, 1, undef],
    # Not sure if this is legal...
    "?" => [0,
        undef, undef, "UNCERTAIN", undef, undef, "EXACT", "EXACT", 0, 1, undef],

    # SPLITS

    # this isn't a legal split location string AFAIK (can't have two remote
    # locations), though it is handled. In this case the parent location can't
    # be used in any location-based analyses (has no start, end, etc.)

    "join(AY016290.1:108..185,AY016291.1:1546..1599)"=> [0,
        undef, undef, "EXACT", undef, undef, "EXACT", "JOIN", 2, 0, undef],

    "complement(join(3207..4831,5834..5902,8881..8969,9276..9403,29535..29764))",
        [0, 3207, 3207, "EXACT", 29764, 29764, "EXACT", "JOIN", 5, -1, undef],
    "join(complement(29535..29764),complement(9276..9403),complement(8881..8969),complement(5834..5902),complement(3207..4831))",
        ["complement(join(3207..4831,5834..5902,8881..8969,9276..9403,29535..29764))",
        3207, 3207, "EXACT", 29764, 29764, "EXACT", "JOIN", 5, -1, undef],
    "join(12..78,134..202)" => [0,
        12, 12, "EXACT", 202, 202, "EXACT", "JOIN", 2, 1, undef],
    "join(<12..78,134..202)" => [0,
        undef, 12, "BEFORE", 202, 202, "EXACT", "JOIN", 2, 1, undef],
    "complement(join(2691..4571,4918..5163))" => [0,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, undef],
    "complement(join(4918..5163,2691..4571))" => [0,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, undef],
    "join(complement(4918..5163),complement(2691..4571))" => [
        'complement(join(2691..4571,4918..5163))',
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, undef],
    "join(complement(2691..4571),complement(4918..5163))" => [
        'complement(join(4918..5163,2691..4571))',
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, undef],
    "complement(34..(122.126))" => [0,
        34, 34, "EXACT", 122, 126, "WITHIN", "EXACT", 0, -1, undef],

    # complex, technically not legal FT types but we handle and resolve these as needed

    'join(11025..11049,join(complement(239890..240081),complement(241499..241580),complement(251354..251412),complement(315036..315294)))'
        => ['join(11025..11049,complement(join(315036..315294,251354..251412,241499..241580,239890..240081)))',
            11025,11025, 'EXACT', 315294, 315294, 'EXACT', 'JOIN', 2, 0, undef],
    'join(11025..11049,complement(join(315036..315294,251354..251412,241499..241580,239890..240081)))'
        => [0, 11025,11025, 'EXACT', 315294, 315294, 'EXACT', 'JOIN', 2, 0, undef],
    'join(20464..20694,21548..22763,complement(join(314652..314672,232596..232990,231520..231669)))'
        => [0, 20464,20464, 'EXACT', 314672, 314672, 'EXACT', 'JOIN', 3, 0, undef],
    'join(20464..20694,21548..22763,join(complement(231520..231669),complement(232596..232990),complement(314652..314672)))'
        => ['join(20464..20694,21548..22763,complement(join(314652..314672,232596..232990,231520..231669)))',
            20464,20464, 'EXACT', 314672, 314672, 'EXACT', 'JOIN', 3, 0, undef],

    'join(1000..2000,join(3000..4000,join(5000..6000,7000..8000)),9000..10000)'
        => [0, 1000,1000,'EXACT', 10000, 10000, 'EXACT', 'JOIN', 3, 1, undef],

    # not passing yet, working out 'order' semantics
    'order(S67862.1:72..75,1..788,S67864.1:1..19)'
        => [0,  undef, undef, 'EXACT', undef, undef, 'EXACT', 'ORDER', 3, 0, undef],
          );

my $locfac = Biome::Factory::FTLocationFactory->new(-verbose => 1);

# sorting is to keep the order constant from one run to the next
foreach my $locstr (keys %testcases) {
    my ($replace, @rest) = @{$testcases{$locstr}};
    my $loc = $locfac->from_string($locstr);
    if (!$replace) {
        is($loc->to_string, $locstr, "compare round-trip on $locstr")
    } else {
        is($loc->to_string, $replace, "compare conversion of $locstr to $replace");
    }

    isa_ok($loc, 'Biome::Location::Simple');
    is($loc->min_start(), $rest[0], "min_start: $locstr");
    is($loc->max_start(), $rest[1], "max_start: $locstr");
    is($loc->start_pos_type(), $rest[2], "start_pos_type: $locstr");
    is($loc->min_end(), $rest[3], "min_end: $locstr");
    is($loc->max_end(), $rest[4], "max_end: $locstr");
    is($loc->end_pos_type(), $rest[5], "end_pos_type: $locstr");
    is($loc->location_type(), $rest[6], "location_type: $locstr");
    my @locs = $loc->sub_Locations();
    is(@locs, $rest[7], "sub_Locations: $locstr");
    is($loc->strand(), $rest[8], "strand: $locstr");

    # seq_id, where the location string is defined (does not automatically mean
    # the location is remote, only that the ID may be explictly defined)
    is($loc->seq_id, $rest[9]);
}

done_testing();
