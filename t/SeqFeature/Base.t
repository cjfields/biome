# -*-Perl-*- Test Harness script for Bioperl
# $Id: PrimarySeq.t 15112 2008-12-08 18:12:38Z sendu $

use strict;
my @sf_classes;


BEGIN {
    @sf_classes = qw(Biome::SeqFeature::Simple
               Biome::SeqFeature::Location
               Biome::SeqFeature::Generic);
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::PrimarySeq');
    for my $class (@sf_classes) {
        use_ok($class);
    }
}

for my $class (@sf_classes) {
    my $feat = $class->new(
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
    does_ok($feat, 'Biome::Role::SeqFeature', "$class does SeqFeature abstract role");
    is $feat->primary_tag, 'exon', 'primary tag';
    is $feat->source_tag, 'internal', 'source tag';
    
    # Locatable
    does_ok($feat, 'Biome::Role::Location::Does_Range', "$class Does_Range abstract role");
    # delegated methods (note these are not attributes)
    is $feat->start, 40, 'start of feature location';
    is $feat->end, 80, 'end of feature location';
    is $feat->strand, 1, 'strand of feature location';
    is $feat->length, 41, 'length of feature location';
    if ($feat->does('Biome::Role::Locatable')) {
        does_ok $feat->location, 'Biome::Role::Location::Does_Range';
    } else {
        does_ok($feat, 'Biome::Role::Location::Does_Range');
    }
    
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
                        -seq          => $rawseq,
                        -display_id       => 'myseq',
                        -alphabet         => 'dna',
                        -accession_number => 'X677667',
                        -description      => 'Sample PrimarySeq object');
    
    does_ok($feat, 'Biome::Role::PrimarySeqContainer');
    $feat->attach_seq($seq);
    is $feat->seq, 'gccggccgtggcgtagagcgcgaggacggcgaccggcgtgg';
    my $sub = $feat->primary_seq;
    isa_ok($sub, 'Biome::PrimarySeq');
    is $sub->seq, 'gccggccgtggcgtagagcgcgaggacggcgaccggcgtgg';
    is $feat->length, $sub->length, 'lengths match';
}

done_testing();