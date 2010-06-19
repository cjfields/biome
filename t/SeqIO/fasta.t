# -*-Perl-*- Test Harness script for Bioperl
# $Id$

use strict;

BEGIN {
	use lib '.';
	use Test::More;
	use Test::Moose;
	use Test::Exception;
    use_ok('Biome::SeqIO::fasta');
    use File::Spec;
}

use Biome::SeqIO;

my $format = 'fasta';
my $seqio_obj = Biome::SeqIO->new(-file   => File::Spec->catfile(qw(t data test.fasta)),
                                -format => $format);

isa_ok($seqio_obj, 'Biome::SeqIO');
does_ok($seqio_obj,'Biome::Role::Stream::Seq');

# checking the first sequence object
my $seq_obj = $seqio_obj->next_Seq();

isa_ok($seq_obj, 'Biome::PrimarySeq');
my %expected = ('seq'         => 'MVNSNQNQNGNSNGHDDDFPQDSITEPEHMRKLFIGGL' .
                                 'DYRTTDENLKAHEKWGNIVDVVVMKDPRTKRSRGFGFI' .
                                 'TYSHSSMIDEAQKSRPHKIDGRVEPKRAVPRQDIDSPN' .
                                 'AGATVKKLFVGALKDDHDEQSIRDYFQHFGNIVDNIVI' .
                                 'DKETGKKRGFAFVEFDDYDPVDKVVLQKQHQLNGKMVD' .
                                 'VKKALPKNDQQGGGGGRGGPGGRAGGNRGNMGGGNYGN' .
                                 'QNGGGNWNNGGNNWGNNRGNDNWGNNSFGGGGGGGGGY' .
                                 'GGGNNSWGNNNPWDNGNGGGNFGGGGNNWNGGNDFGGY' .
                                 'QQNYGGGPQRGGGNFNNNRMQPYQGGGGFKAGGGNQGN' .
                                 'YGNNQGFNNGGNNRRY',
                'length'      => '358',
                'primary_id'  => 'roa1_drome',
                'description' => qr(Rea guano receptor type III),
               );
is   ($seq_obj->seq(),         $expected{'seq'},         'sequence');
is   ($seq_obj->length(),      $expected{'length'},      'length');
is   ($seq_obj->primary_id(),  $expected{'primary_id'},  'primary_id');
like ($seq_obj->description(), $expected{'description'}, 'description');

# test output
my $outseq;
open (my $outfh, '>', \$outseq) || die "Can't attach output to scalar: $!";
my $out_stream = Biome::SeqIO->new(-fh => $outfh, -format => $format);
is($out_stream->mode, 'w', 'mode is correct');
$out_stream->write_Seq($seq_obj);
$out_stream->close;

is ($outseq, <<SEQ, 'Sequence matches');
>roa1_drome Rea guano receptor type III >> 0.1
MVNSNQNQNGNSNGHDDDFPQDSITEPEHMRKLFIGGLDYRTTDENLKAHEKWGNIVDVV
VMKDPRTKRSRGFGFITYSHSSMIDEAQKSRPHKIDGRVEPKRAVPRQDIDSPNAGATVK
KLFVGALKDDHDEQSIRDYFQHFGNIVDNIVIDKETGKKRGFAFVEFDDYDPVDKVVLQK
QHQLNGKMVDVKKALPKNDQQGGGGGRGGPGGRAGGNRGNMGGGNYGNQNGGGNWNNGGN
NWGNNRGNDNWGNNSFGGGGGGGGGYGGGNNSWGNNNPWDNGNGGGNFGGGGNNWNGGND
FGGYQQNYGGGPQRGGGNFNNNRMQPYQGGGGFKAGGGNQGNYGNNQGFNNGGNNRRY
SEQ

## checking the second sequence object
my $seq_obj2  = $seqio_obj->next_Seq();
isa_ok($seq_obj2, 'Biome::PrimarySeq');
my %expected2 = ('seq'         => 'MVNSNQNQNGNSNGHDDDFPQDSITEPEHMRKLFIGGL' .
                                  'DYRTTDENLKAHEKWGNIVDVVVMKDPTSTSTSTSTST' .
                                  'STSTSTMIDEAQKSRPHKIDGRVEPKRAVPRQDIDSPN' .
                                  'AGATVKKLFVGALKDDHDEQSIRDYFQHLLLLLLLDLL' .
                                  'LLDLLLLDLLLFVEFDDYDPVDKVVLQKQHQLNGKMVD' .
                                  'VKKALPKNDQQGGGGGRGGPGGRAGGNRGNMGGGNYGN' .
                                  'QNGGGNWNNGGNNWGNNRGNDNWGNNSFGGGGGGGGGY' .
                                  'GGGNNSWGNNNPWDNGNGGGNFGGGGNNWNGGNDFGGY' .
                                  'QQNYGGGPQRGGGNFNNNRMQPYQGGGGFKAGGGNQGN' .
                                  'YGNNQGFNNGGNNRRY',
                 'length'      => '358',
                 'primary_id'  => 'roa2_drome',
                 'description' => qr(Rea guano ligand),
                );
is   ($seq_obj2->seq(),         $expected2{'seq'},         'sequence');
is   ($seq_obj2->length(),      $expected2{'length'},      'length');
is   ($seq_obj2->primary_id(),  $expected2{'primary_id'},  'primary_id');
like ($seq_obj2->description(), $expected2{'description'}, 'description');

# test output
open ($outfh, '>', \$outseq) || die "Can't attach output to scalar: $!";
$out_stream = Biome::SeqIO->new(-fh => $outfh, -format => $format);
is($out_stream->mode, 'w', 'mode is correct');
$out_stream->write_Seq($seq_obj2);
$out_stream->close;

is ($outseq, <<SEQ, 'Sequence matches');
>roa2_drome Rea guano ligand
MVNSNQNQNGNSNGHDDDFPQDSITEPEHMRKLFIGGLDYRTTDENLKAHEKWGNIVDVV
VMKDPTSTSTSTSTSTSTSTSTMIDEAQKSRPHKIDGRVEPKRAVPRQDIDSPNAGATVK
KLFVGALKDDHDEQSIRDYFQHLLLLLLLDLLLLDLLLLDLLLFVEFDDYDPVDKVVLQK
QHQLNGKMVDVKKALPKNDQQGGGGGRGGPGGRAGGNRGNMGGGNYGNQNGGGNWNNGGN
NWGNNRGNDNWGNNSFGGGGGGGGGYGGGNNSWGNNNPWDNGNGGGNFGGGGNNWNGGND
FGGYQQNYGGGPQRGGGNFNNNRMQPYQGGGGFKAGGGNQGNYGNNQGFNNGGNNRRY
SEQ

# from testformats.pl
#SKIP: {
#    test_skip(-tests => 4, -requires_modules => [qw(Algorithm::Diff
#                                                    IO::ScalarArray
#                                                    IO::String)]);
#    use_ok('Algorithm::Diff');
#    eval "use Algorithm::Diff qw(diff LCS);";
#    use_ok('IO::ScalarArray');
#    use_ok('IO::String');
#    
#    my ($file, $type) = ("test.$format", $format);
#    my $filename = test_input_file($file);
#    print "processing file $filename\n" if $verbose;
#    open(FILE, "< $filename") or die("cannot open $filename");
#    my @datain = <FILE>;
#    my $in = new IO::String(join('', @datain));
#    my $seqin = new Bio::SeqIO( -fh => $in,
#                -format => $type);
#    my $out = new IO::String;
#    my $seqout = new Bio::SeqIO( -fh => $out,
#                 -format => $type);
#    my $seq;
#    while( defined($seq = $seqin->next_seq) ) { 
#    $seqout->write_seq($seq);
#    }
#    $seqout->close();
#    $seqin->close();
#    my $strref = $out->string_ref;
#    my @dataout = map { $_."\n"} split(/\n/, $$strref );
#    my @diffs = &diff( \@datain, \@dataout);
#    is(@diffs, 0, "$format format can round-trip");
#    
#    if(@diffs && $verbose) {
#        foreach my $d ( @diffs ) {
#            foreach my $diff ( @$d ) {
#                chomp($diff->[2]);
#                print $diff->[0], $diff->[1], "\n>", $diff->[2], "\n";
#            }
#        }
#        print "in is \n", join('', @datain), "\n";
#        print "out is \n", join('',@dataout), "\n"; 
#    }
#
#}
#
# bug 1508
# test genbank, gcg, ace against fasta (should throw an exception on each)

for my $file (qw(roa1.genbank test.gcg test.ace test.raw)) {
    my $in = Biome::SeqIO->new(-file   => File::Spec->catfile('t', 'data', $file),
                             -format => 'fasta');
    throws_ok {$in->next_Seq}
        qr/The sequence does not appear to be FASTA format/, "dies with $file";
}

done_testing();
