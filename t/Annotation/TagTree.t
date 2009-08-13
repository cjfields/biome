use strict;
use warnings;

BEGIN {
    use Test::More tests => 35;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Annotation::TagTree');
}

#tagtree
my $struct = [ 'genenames' => [
			       ['genename' => [
					       [ 'Name' => 'CALM1' ],
					       ['Synonyms'=> 'CAM1'],
					       ['Synonyms'=> 'CALM'],
					       ['Synonyms'=> 'CAM' ] ] ],
			       ['genename'=> [
					      [ 'Name'=> 'CALM2' ],
					      [ 'Synonyms'=> 'CAM2'],
					      [ 'Synonyms'=> 'CAMB'] ] ],
			       [ 'genename'=> [
					       [ 'Name'=> 'CALM3' ],
					       [ 'Synonyms'=> 'CAM3' ],
					       [ 'Synonyms'=> 'CAMC' ] ] ]
			      ] ];

my $ann_struct = Biome::Annotation::TagTree->new(-tagname => 'gn',
					       -value => $struct);

does_ok($ann_struct, 'Biome::Role::Annotate');
my $val = $ann_struct->value;
like($val, qr/Name: CALM1/,'default itext');

# roundtrip
my $ann_struct2 = Biome::Annotation::TagTree->new(-tagname => 'gn',
						-value => $ann_struct->node);
is($ann_struct2->value, $val,'roundtrip');

# formats 
like($ann_struct2->value, qr/Name: CALM1/,'itext');
$ann_struct2->tagformat('sxpr');
like($ann_struct2->value, qr/\(Name "CALM1"\)/,'spxr');
$ann_struct2->tagformat('indent');
like($ann_struct2->value, qr/Name "CALM1"/,'indent');

SKIP: {
    eval {require XML::Parser::PerlSAX};
    skip ("XML::Parser::PerlSAX rquired for XML",1) if $@;
    $ann_struct2->tagformat('xml');
    like($ann_struct2->value, qr/<Name>CALM1<\/Name>/,'xml');
}

# grab Data::Stag nodes, use Data::Stag methods
my @nodes = $ann_struct2->children;
for my $node (@nodes) {
    isa_ok($node, 'Data::Stag::StagI');
    is($node->element, 'genename');
    # add tag-value data to node
    $node->set('foo', 'bar');
    # check output
    like($node->itext, qr/foo:\s+bar/,'child changes');
}

$ann_struct2->tagformat('itext');
like($ann_struct2->value, qr/foo:\s+bar/,'child changes in parent node');

# pass in a Data::Stag node to value()
$ann_struct = Biome::Annotation::TagTree->new(-tagname => 'mytags');
like($ann_struct->value, qr/^\s+:\s+$/xms, 'no tags');
like($ann_struct->value, qr/^\s+:\s+$/xms,'before Stag node');
$ann_struct->value($nodes[0]);
like($ann_struct->value, qr/Name: CALM1/,'after Stag node');
is(ref $ann_struct->node, ref $nodes[0], 'both stag nodes');
isnt($ann_struct->node, $nodes[0], 'different instances');

# pass in another TagTree to value()
$ann_struct = Biome::Annotation::TagTree->new(-tagname => 'mytags');
like($ann_struct->value, qr/^\s+:\s+$/xms,'before TagTree');
$ann_struct->value($ann_struct2);
like($ann_struct->value, qr/Name: CALM2/,'after TagTree');
is(ref $ann_struct->node, ref $ann_struct2->node, 'both stag nodes');
isnt($ann_struct->node, $ann_struct2->node, 'different instances');

# replace the Data::Stag node in the annotation (no copy)
$ann_struct = Biome::Annotation::TagTree->new(-tagname => 'mytags');
like($ann_struct->value, qr/^\s+:\s+$/xms,'before TagTree');
$ann_struct->node($nodes[1]);
like($ann_struct->value, qr/Name: CALM2/,'after TagTree');
is(ref $ann_struct->node, ref $ann_struct2->node, 'stag nodes');
is($ann_struct->node, $nodes[1], 'same instance');

# replace the Data::Stag node in the annotation (use duplicate)
$ann_struct = Biome::Annotation::TagTree->new(-tagname => 'mytags');
like($ann_struct->value, qr/^\s+:\s+$/xms,'before TagTree');
$ann_struct->node($nodes[1],'copy');
like($ann_struct->value, qr/Name: CALM2/,'after TagTree');
is(ref $ann_struct->node, ref $ann_struct2->node, 'stag nodes');
isnt($ann_struct->node, $nodes[1], 'different instance');

