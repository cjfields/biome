# -*-Perl-*- Test Harness script for Bioperl
# $Id: PrimarySeq.t 15112 2008-12-08 18:12:38Z sendu $

use strict;

BEGIN { 
    use lib '.';
    use Test::More tests => 53;
    use Test::Moose;
    use Test::Exception;
	use_ok('Biome::PrimarySeq');
}

# simple get/set
my $seq = Biome::PrimarySeq->new(
                    -rawseq           => '----TTGGTGG---CGTCA--ACT---',
                    -display_id       => 'new-id',
                    -alphabet         => 'dna',
                    -accession_number => 'X677667',
                    -description      => 'Sample PrimarySeq object');
ok defined $seq;
does_ok($seq,'Biome::Role::PrimarySeq');
is $seq->seq(), '----TTGGTGG---CGTCA--ACT---';
is $seq->length(), 15;
is $seq->alphabet(), 'dna';
is $seq->is_circular(), undef;
ok $seq->is_circular(1);
is $seq->is_circular(0), 0;
is $seq->accession_number(), 'X677667';
is $seq->display_id(), 'new-id';

# check Identify, Describe roles
does_ok($seq,'Biome::Role::Describable');
does_ok($seq,'Biome::Role::Identifiable');

# make sure all methods are implemented
is $seq->authority("bioperl.org"), "bioperl.org";
is $seq->namespace("t"), "t";
is $seq->version(0), 0;

# NYI, do we want this?  How often is it used?
#is $seq->lsid_string(), "bioperl.org:t:X677667";

is $seq->namespace_string(), "t:X677667.0";
is $seq->description(), 'Sample PrimarySeq object';
is $seq->display_name(), "new-id";
is $seq->display_name('really-new-id'), "really-new-id";
ok($seq->has_gaps,'gaps present');

is($seq->subseq(-start => 2, -end => 9, -strand => 1), 'TGGTGG---CG');
is($seq->subseq(-start => 2, -end => 9, -strand => 1, -gaps => 0), 'TGGTGGCG');

# across two gaps
is($seq->subseq(-start => 7, -end => 15, -strand => 1), 'G---CGTCA--ACT');

# TODO: Locations NYI
#my $location = Bio::Location::Simple->new('-start' => 2, 
#                                                     '-end' => 5,
#                                                     '-strand' => -1);
#is ($seq->subseq($location), 'ACCA');
#
#my $splitlocation = Bio::Location::Split->new();
#$splitlocation->add_sub_Location( Bio::Location::Simple->new(
#                                '-start' => 1,
#                               '-end'   => 4,
#                               '-strand' => 1));
#
#$splitlocation->add_sub_Location( Bio::Location::Simple->new(
#                         '-start' => 7,
#                               '-end'   => 12,
#                               '-strand' => -1));
#
#is( $seq->subseq($splitlocation), 'TTGGTGACGC');
#
#my $fuzzy = Bio::Location::Fuzzy->new(-start => '<3',
#                                                -end   => '8',
#                                                -strand => 1);
#
#is( $seq->subseq($fuzzy), 'GGTGGC');

my $trunc = $seq->trunc(-start => 1, -end => 4);
does_ok $trunc, 'Biome::Role::PrimarySeq';
is $trunc->rawseq(), 'TTGG' || diag("Expecting TTGG. Got ".$trunc->seq());
is $trunc->length(), 4;

# TODO: Locations NYI
#$trunc = $seq->trunc($splitlocation);
#isa_ok($trunc, 'Bio::PrimarySeqI');
#is( $trunc->seq(), 'TTGGTGACGC');
#
#$trunc = $seq->trunc($fuzzy);
#isa_ok($trunc, 'Bio::PrimarySeqI');
#is( $trunc->seq(), 'GGTGGC');

my $rev = $seq->revcom();
does_ok($rev, 'Biome::Role::PrimarySeq');

is $rev->seq, '---AGT--TGACG---CCACCAA----';
is $rev->accession_number, 'X677667';
is $rev->is_circular, 0;
is $rev->length, 15;

#
# Translate
#

my $aa = $seq->translate(); # TTG GTG GCG TCA ACT
is $aa->seq, 'LVAST', "Translation: ". $aa->seq;

# tests for non-standard initiator codon coding for
# M by making translate() look for an initiator codon and
# terminator codon ("complete", the 5th argument below)
$seq->seq('TTGGTGGCGTCAACTTAA'); # TTG GTG GCG TCA ACT TAA

# please do NOT use this form!
$aa = $seq->translate(undef, undef, undef, undef, 1);
is $aa->seq, 'MVAST', "Translation: ". $aa->seq;

# same test as previous, but using named parameter
$aa = $seq->translate(-complete => 1);
is $aa->seq, 'MVAST', "Translation: ". $aa->seq;

# find ORF, ignore codons outside the ORF or CDS
$seq->seq('TTTTATGGTGGCGTCAACTTAATTT'); # ATG GTG GCG TCA ACT
$aa = $seq->translate(-orf => 1);
is $aa->seq, 'MVAST*', "Translation: ". $aa->seq;

# smallest possible ORF
$seq->seq("ggggggatgtagcccc"); # atg tga
$aa = $seq->translate(-orf => 1);
is $aa->seq, 'M*', "Translation: ". $aa->seq;

# same as previous but complete, so * is removed
$aa = $seq->translate(-orf => 1,
                      -complete => 1);
is $aa->seq, 'M', "Translation: ". $aa->seq;

# ORF without termination codon
# should warn, let's change it into throw for testing
$seq->strict(2);
$seq->seq("ggggggatgtggcccc"); # atg tgg ccc
eval { $seq->translate(-orf => 1); };
if ($@) {
    like( $@, qr/atgtggcccc\n/);
    $seq->strict(-1);
    $aa = $seq->translate(-orf => 1);
    is $aa->seq, 'MWP', "Translation: ". $aa->seq;
}
$seq->strict(0);

# use non-standard codon table where terminator is read as Q
$seq->seq('ATGGTGGCGTCAACTTAG'); # ATG GTG GCG TCA ACT TAG
$aa = $seq->translate(-codontable_id => 6);
is $aa->rawseq, 'MVASTQ' or diag("Translation: ". $aa->seq);

# insert an odd character instead of terminating with *
$aa = $seq->translate(-terminator => 'X');
is $aa->rawseq, 'MVASTX' or diag("Translation: ". $aa->seq);

# change frame from default
$aa = $seq->translate(-frame => 1); # TGG TGG CGT CAA CTT AG
is $aa->rawseq, 'WWRQL' or diag("Translation: ". $aa->seq);

$aa = $seq->translate(-frame => 2); # GGT GGC GTC AAC TTA G
is $aa->rawseq, 'GGVNL' or diag("Translation: ". $aa->seq);

# TTG is initiator in Standard codon table? Afraid so.
$seq->seq("ggggggttgtagcccc"); # ttg tag
$aa = $seq->translate(-orf => 1);
is $aa->rawseq, 'L*' or diag("Translation: ". $aa->seq);

# Replace L at 1st position with M by setting complete to 1 
$seq->rawseq("ggggggttgtagcccc"); # ttg tag
$aa = $seq->translate(-orf => 1,
                             -complete => 1);
is $aa->rawseq, 'M' or diag("Translation: ". $aa->seq);

# Ignore non-ATG initiators (e.g. TTG) in codon table
$seq->rawseq("ggggggttgatgtagcccc"); # atg tag
$aa = $seq->translate(-orf => 1,
                             -start => "atg",
                             -complete => 1);
is $aa->rawseq, 'M' or diag("Translation: ". $aa->seq);


# test for character '?' in the sequence string
is $seq->rawseq('TTGGTGGCG?CAACT'), 'TTGGTGGCG?CAACT';

# test for some aliases
# implementation-specific, see above for Biome::PrimarySeq

$seq = Biome::PrimarySeq->new(
		-display_id 	=> 'myID',
		-id				=> 'foo',
        -description 	=> 'Alias desc');
is($seq->description, 'Alias desc');
is($seq->display_id, 'myID'); 
$seq->display_id('foo'); 
is($seq->display_id, 'foo'); 
ok(!$seq->can('id'), 'we do not use the generic id()');

# test that x's are ignored and n's are assumed to be 'dna' no longer true!
# See Bug 2438. There are protein sequences floating about which are all 'X'
# (unknown aa)

# NYI, not sure we are going to have guessing the alphabet by default

#$seq->rawseq('atgxxxxxx');
#is($seq->alphabet,'protein');
#$seq->rawseq('atgnnnnnn');
#is($seq->alphabet,'dna');

# alphabet has a type constraint
dies_ok {Biome::PrimarySeq->new(
	-rawseq           => '----TTGGTGG---CGTCA--ACT---',
	-display_id       => 'new-id',
	-alphabet         => 'foo')} 'alphabet is a contrained type';

