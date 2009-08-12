# -*-Perl-*- Test Harness script for Bioperl
# $Id: IUPAC.t 15112 2008-12-08 18:12:38Z sendu $

use strict;

BEGIN { 
	use lib '.';
    use Test::More tests => 12;
    use Test::Moose;
    use Test::Exception;
	use_ok('Biome::Tools::IUPAC');
}

# test class methods

# ambiguous codes - DNA
my $table = Biome::Tools::IUPAC->iupac_dna;
isa_ok($table, 'HASH');
is(Biome::Tools::IUPAC->count_iupac_dna, 17);
is(Biome::Tools::IUPAC->get_iupac_dna('N'), 'ACGT');

# ambiguous codes - DNA
$table = Biome::Tools::IUPAC->iupac_rev_dna;
isa_ok($table, 'HASH');
is(Biome::Tools::IUPAC->count_iupac_rev_dna, 16);
is(Biome::Tools::IUPAC->get_iupac_rev_dna('ACGT') , 'N');

# ambiguous codes - protein
$table = Biome::Tools::IUPAC->iupac_aa;
isa_ok($table, 'HASH');
is(Biome::Tools::IUPAC->count_iupac_aa, 27);
is(Biome::Tools::IUPAC->get_iupac_aa('N') , 'N');

$table = Biome::Tools::IUPAC->map_aa_1_3;
isa_ok($table, 'HASH');

$table = Biome::Tools::IUPAC->map_aa_3_1;
isa_ok($table, 'HASH');

# NYI

#my $ambiseq = Bio::Seq->new(-seq => 'ARTCGTTGR',
#			    -alphabet => 'dna'); 
#
#my $stream  = Bio::Tools::IUPAC->new('-seq' => $ambiseq);
#is $stream->count(), 4;

#my $b = 1; 
#while (my $uniqueseq = $stream->next_seq()) {
#    if( ! $uniqueseq->isa('Bio::Seq') ) {
#	$b = 0;
#	last; # no point continuing if we get here
#    }
#}
#ok $b;
