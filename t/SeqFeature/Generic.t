# -*-Perl-*- Test Harness script for Bioperl
# $Id: PrimarySeq.t 15112 2008-12-08 18:12:38Z sendu $

use strict;

BEGIN { 
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
	use_ok('Biome::SeqFeature::Generic');
    use_ok('Biome::PrimarySeq');
}

my $feat = Biome::SeqFeature::Generic->new(
                        -start          => 40,
                        -end            => 80,
                        -strand         => 1,
                        -primary_tag    => 'exon',
                        -source_tag     => 'internal',
                        -seq_id         => 'ABCD1234',
                        -tag_map        => {
                            silly => 20,
                            new => 1
                        }
				       );

# Generic Feature
does_ok($feat, 'Biome::Role::SeqFeature');
is $feat->primary_tag, 'exon', 'primary tag';
is $feat->source_tag, 'internal', 'source tag';

# Locatable
does_ok($feat, 'Biome::Role::Locatable');
# delegated methods (note these are not attributes)
is $feat->start, 40, 'start of feature location';
is $feat->end, 80, 'end of feature location';
is $feat->strand, 1, 'strand of feature location';
is $feat->length, 41, 'length of feature location';
does_ok $feat->location, 'Biome::Role::Range';

# Taggable
does_ok($feat, 'Biome::Role::Taggable');
is join(',',sort $feat->get_all_tags), 'new,silly', 'tag names';
is join(',',$feat->get_tag_values('new')), '1', 'tag 1';
is join(',',$feat->get_tag_values('silly')), '20', 'tag 2';

# SeqFeature
does_ok($feat, 'Biome::Role::SeqFeature');
does_ok($feat, 'Biome::Role::SeqFeature::Collection');
is $feat->seq_id, 'ABCD1234', 'attached_id';

# PrimarySeqContainer
my $rawseq = 'gatcagtagacccagcgacagcagggcggggcccagcaggccggccgtggcgtagagcgc'.
'gaggacggcgaccggcgtggccaccgacaggatggctgcggcgacgcggacgacaccgga';
my $seq = Biome::PrimarySeq->new(
                    -raw_seq          => $rawseq,
                    -display_id       => 'myseq',
                    -alphabet         => 'dna',
                    -accession_number => 'X677667',
                    -description      => 'Sample PrimarySeq object');

does_ok($feat, 'Biome::Role::PrimarySeqContainer');
$feat->attach_seq($seq);
is $feat->raw_seq, 'gccggccgtggcgtagagcgcgaggacggcgaccggcgtgg';
my $sub = $feat->primary_seq;
isa_ok($sub, 'Biome::PrimarySeq');
is $sub->raw_seq, 'gccggccgtggcgtagagcgcgaggacggcgaccggcgtgg';
is $feat->length, $sub->length, 'lengths match';

done_testing();