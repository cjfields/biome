# -*-Perl-*- Test Harness script for Biome

use strict;

BEGIN { 
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::SeqIO');
}

ok my $in = Biome::SeqIO->new(-format => 'fasta');

does_ok($in, 'Biome::SeqIO::fasta');
isa_ok($in, 'Biome::SeqIO');

done_testing;
