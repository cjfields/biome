use strict;
use warnings;

BEGIN {
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Factory::FTLocationFactory');
}

# these are being worked on...
my $simple_impl = "Biome::Location::Simple";
my $split_impl = "Biome::Location::Split";

# Holds strings and results. The latter is an array of expected class name,
# min/max start position and position type, min/max end position and position
# type, location type, the number of locations, and the strand.

my %testcases = (
   # note: the following are directly taken from 
   # http://www.ncbi.nlm.nih.gov/collab/FT/#location
    "467" => [0, $simple_impl,
        467, 467, "EXACT", 467, 467, "EXACT", "EXACT", 0, 1],
    "340..565" => [0, $simple_impl,
         340, 340, "EXACT", 565, 565, "EXACT", "EXACT", 0, 1],
    "<345..500" => [0, $simple_impl,
         undef, 345, "BEFORE", 500, 500, "EXACT", "EXACT", 0, 1],
    "<1..888" => [0, $simple_impl,
         undef, 1, "BEFORE", 888, 888, "EXACT", "EXACT", 0, 1],
    
    "(102.110)" => [0, $simple_impl,
         102, 102, "EXACT", 110, 110, "EXACT", "WITHIN", 0, 1],
    "(23.45)..600" => [0, $simple_impl,
         23, 45, "WITHIN", 600, 600, "EXACT", "EXACT", 0, 1],
    "(122.133)..(204.221)" => [0, $simple_impl,
         122, 133, "WITHIN", 204, 221, "WITHIN", "EXACT", 0, 1],
    "123^124" => [0, $simple_impl,
         123, 123, "EXACT", 124, 124, "EXACT", "IN-BETWEEN", 0, 1],
    "145^146" => [0, $simple_impl,
         145, 145, "EXACT", 146, 146, "EXACT", "IN-BETWEEN", 0, 1],
    "J00194:100..202" => [0, $simple_impl,
         100, 100, "EXACT", 202, 202, "EXACT", "EXACT", 0, 1],
    
    # these variants are not really allowed by the FT definition
    # document but we want to be able to cope with it
    
    "J00194:(100..202)" => ['J00194:100..202', $simple_impl,
         100, 100, "EXACT", 202, 202, "EXACT", "EXACT", 0, 1],
    "((122.133)..(204.221))" => ['(122.133)..(204.221)', $simple_impl,
         122, 133, "WITHIN", 204, 221, "WITHIN", "EXACT", 0, 1],
    
    # UNCERTAIN locations and positions (Swissprot)
    "?2465..2774" => [0, $simple_impl,
        2465, 2465, "UNCERTAIN", 2774, 2774, "EXACT", "EXACT", 0, 1],
    "22..?64" => [0, $simple_impl,
        22, 22, "EXACT", 64, 64, "UNCERTAIN", "EXACT", 0, 1],
    "?22..?64" => [0, $simple_impl,
        22, 22, "UNCERTAIN", 64, 64, "UNCERTAIN", "EXACT", 0, 1],
    "?..>393" => [0, $simple_impl,
        undef, undef, "UNCERTAIN", 393, undef, "AFTER", "EXACT", 0, 1],
    "<1..?" => [0, $simple_impl,
        undef, 1, "BEFORE", undef, undef, "UNCERTAIN", "EXACT", 0, 1],
    "?..536" => [0, $simple_impl,
        undef, undef, "UNCERTAIN", 536, 536, "EXACT", "EXACT", 0, 1],
    "1..?" => [0, $simple_impl,
        1, 1, "EXACT", undef, undef, "UNCERTAIN", "EXACT", 0, 1],
    "?..?" => [0, $simple_impl,
        undef, undef, "UNCERTAIN", undef, undef, "UNCERTAIN", "EXACT", 0, 1],
    "1..?12" => [0, $simple_impl,
        1, 1, "EXACT", 12, 12, "UNCERTAIN", "EXACT", 0, 1],
    # Not sure if this is legal...
    "?" => [0, $simple_impl,
        undef, undef, "UNCERTAIN", undef, undef, "EXACT", "EXACT", 0, 1],
    
    # SPLITS
    
    "join(AY016290.1:108..185,AY016291.1:1546..1599)"=> [0, $split_impl,
        108, 108, "EXACT", 185, 185, "EXACT", "JOIN", 2, undef],
    "join(12..78,134..202)" => [0, $split_impl,
        12, 12, "EXACT", 202, 202, "EXACT", "JOIN", 2, 1],
    "join(<12..78,134..202)" => [0, $split_impl,
        undef, 12, undef, 202, 202, "EXACT", "JOIN", 2, 1],
    "complement(join(2691..4571,4918..5163))" => [0, $split_impl,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1],
    "complement(join(4918..5163,2691..4571))" => [0, $split_impl,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1],
    "join(complement(4918..5163),complement(2691..4571))" => [
        'complement(join(2691..4571,4918..5163))', $split_impl,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1],
    "join(complement(2691..4571),complement(4918..5163))" => [
        'complement(join(4918..5163,2691..4571))', $split_impl,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1],
    "complement(34..(122.126))" => [0, $simple_impl,
        34, 34, "EXACT", 122, 126, "WITHIN", "EXACT", 0, -1],
    
    # complex, technically not legal FT types but we handle and resolve these as needed
    
    'join(11025..11049,join(complement(239890..240081),complement(241499..241580),complement(251354..251412),complement(315036..315294)))'
        => ['join(11025..11049,complement(join(315036..315294,251354..251412,241499..241580,239890..240081)))',
            $split_impl,11025,11025, 'EXACT', 315294, 315294, 'EXACT', 'JOIN', 2, undef],
    'join(11025..11049,complement(join(315036..315294,251354..251412,241499..241580,239890..240081)))'
        => [0, $split_impl,11025,11025, 'EXACT', 315294, 315294, 'EXACT', 'JOIN', 2, undef],
    'join(20464..20694,21548..22763,complement(join(314652..314672,232596..232990,231520..231669)))'
        => [0, $split_impl,20464,20464, 'EXACT', 314672, 314672, 'EXACT', 'JOIN', 3, undef],
    'join(20464..20694,21548..22763,join(complement(231520..231669),complement(232596..232990),complement(314652..314672)))'
        => ['join(20464..20694,21548..22763,complement(join(314652..314672,232596..232990,231520..231669)))',$split_impl,
            20464,20464, 'EXACT', 314672, 314672, 'EXACT', 'JOIN', 3, undef],
        
    # not passing yet, getting redundant commas, probably from recursive joins
    'join(1000..2000,join(3000..4000,join(5000..6000,7000..8000)),9000..10000)'
        => [0, $split_impl,1000,1000,'EXACT', 10000, 10000, 'EXACT', 'JOIN', 3, 1],
    
    'order(S67862.1:72..75,join(S67863.1:1..788,1..19))'
        => [0, $split_impl, 72, 72, 'EXACT', 75, 75, 'EXACT', 'ORDER', 2, undef],
          );

my $locfac = Biome::Factory::FTLocationFactory->new(-verbose => 1);

# sorting is to keep the order constant from one run to the next
foreach my $locstr (keys %testcases) {
    my ($replace, @rest) = @{$testcases{$locstr}};
    my $loc = $locfac->from_string($locstr);
    if (!$replace) {
        is($loc->to_string, $locstr, "compare round-trip on $locstr")
    } else {
        # these are ones we want converted.  They both have 
        is($loc->to_string, $replace, "compare conversion of $locstr to $replace");
    }
    
    isa_ok($loc, $rest[0]);
    is($loc->min_start(), $rest[1], "min_start: $locstr");
    is($loc->max_start(), $rest[2], "max_start: $locstr");
    is($loc->start_pos_type(), $rest[3], "start_pos_type: $locstr");
    is($loc->min_end(), $rest[4], "min_end: $locstr");
    is($loc->max_end(), $rest[5], "max_end: $locstr");
    is($loc->end_pos_type(), $rest[6], "end_pos_type: $locstr");
    is($loc->location_type(), $rest[7], "location_type: $locstr");
    my @locs = $loc->sub_Locations();
    is(@locs, $rest[8], "sub_Locations: $locstr");
    is($loc->strand(), $rest[9], "strand: $locstr");
}

done_testing();

