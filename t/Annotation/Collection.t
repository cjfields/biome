use strict;
use warnings;

BEGIN {
    use Test::More tests => 29;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Annotation::Collection');
}

use Biome::Annotation::SimpleValue;
use Biome::Annotation::Comment;
use Biome::Annotation::Reference;
use Biome::Annotation::DBLink;
use Biome::Annotation::Target;

my $ac = Biome::Annotation::Collection->new();
does_ok($ac,'Biome::Role::CollectAnnotation');
isa_ok($ac,'Biome::Root');

#simple value

my $simple = Biome::Annotation::SimpleValue->new(-tagname => 'colour',
					       -value   => '1');

$ac->add_Annotation('simplevalue',$simple);

is(join(',',$ac->get_Annotation_keys), 'simplevalue');

# link

my $link1 = Biome::Annotation::DBLink->new(-database => 'TSC',
					 -primary_id => 'TSC0000030');

$ac->add_Annotation('dblink',$link1);
$ac->add_Annotation('dblink',
		    Biome::Annotation::DBLink->new(-database => 'TSC',
						 -primary_id => 'HUM_FABV'));

is(join(',',sort $ac->get_Annotation_keys), 'dblink,simplevalue');

my $comment = Biome::Annotation::Comment->new(-tagname => 'mycomment',
                                            -text => 'sometext');

$ac->add_Annotation('comment',$comment);

is(join(',',sort $ac->get_Annotation_keys), 'comment,dblink,simplevalue');

my $target = Biome::Annotation::Target->new(-target_id  => 'F321966.1',
					  -start      => 1,
					  -end        => 200,
					  -strand     => 1,
					 );

ok $ac->add_Annotation('target', $target);

is(join(',',sort $ac->get_Annotation_keys), 'comment,dblink,simplevalue,target');

my $ref = Biome::Annotation::Reference->new( -authors  => 'author line',
					   -title    => 'title line',
					   -location => 'location line',
					   -start    => 12);

$ac->add_Annotation('reference', $ref);

my $n = 0;
foreach my $link ( $ac->get_Annotations('dblink') ) {
    is $link->database, 'TSC';
    is $link->tagname(), 'dblink';
    $n++;
}
is ($n, 2);

$n = 0;

# TODO: original tests checked the tagname of each annotation to make sure it
# matches. This doesn't work if the tagname of the Annotation is one value, but
# is stored as another in the Collection. For instance, the SimpleValue above is
# stored in the Collection under 'simplevalue', but it's actual tagname is
# 'colour'. Not sure but I don't think the intent was to allow this behavior,
# even though some modules in BioPerl rely on it.

my @keys = $ac->get_Annotation_keys();
is (scalar(@keys), 5);
is ($ac->get_Annotations(), 6);

$ac->add_Annotation($link1);

$n = 0;
foreach my $link ( $ac->get_Annotations('dblink') ) {
    is $link->tagname(), 'dblink';
    $n++;
}
is ($n, 3);

# annotation of structured simple values (like swissprot''is GN line)

# nested collections
my $nested_ac = Biome::Annotation::Collection->new();
$nested_ac->add_Annotation('nested', $ac);

is (scalar($nested_ac->get_Annotations()), 1);
($ac) = $nested_ac->get_Annotations();
does_ok($ac, "Biome::Role::CollectAnnotation");
is (scalar($nested_ac->get_all_Annotations()), 7);

my $simple2 = Biome::Annotation::SimpleValue->new(-tagname => 'foo',
					       -value   => 'bar');

is (scalar($nested_ac->get_Annotations()), 1);
is (scalar($nested_ac->get_all_Annotations()), 7);
is (scalar($nested_ac->get_Annotations('dblink')), 0);
$nested_ac->add_Annotation('top_level_stuff', $simple2);
is (scalar($nested_ac->get_Annotations()), 2);
is (scalar($nested_ac->get_all_Annotations()), 8);
my @anns = $nested_ac->get_Annotations('top_level_stuff');
is(scalar(@anns), 1);
isa_ok($anns[0], "Biome::Annotation::SimpleValue");

#@anns = map { $_->get_Annotations('dblink');
#	  } $nested_ac->get_Annotations('nested');
#is (scalar(@anns), 3);
#is (scalar($nested_ac->flatten_Annotations()), 2);
#is (scalar($nested_ac->get_Annotations()), 7);
#is (scalar($nested_ac->get_all_Annotations()), 7);

##SKIP: {
##  test_skip(-tests => 7, -requires_modules => [qw(Graph::Directed Bio::Annotation::OntologyTerm)]);
##  use_ok('Bio::Annotation::OntologyTerm');
##  # OntologyTerm annotation
##  my $termann = Bio::Annotation::OntologyTerm->new(-label => 'test case',
##						   -identifier => 'Ann:00001',
##						   -ontology => 'dumpster');
##  isa_ok($termann->term,'Bio::Ontology::Term');
##  is ($termann->term->name, 'test case');
##  is ($termann->term->identifier, 'Ann:00001');
##  is ($termann->tagname, 'dumpster');
##  is ($termann->ontology->name, 'dumpster');
##  is ($termann->as_text, "dumpster|test case|");
##}
##
### AnnotatableI
##my $seq = Bio::Seq->new();
##isa_ok($seq,"Bio::AnnotatableI");
##SKIP: {
##	test_skip(-requires_modules => [qw(Bio::SeqFeature::Annotated URI::Escape)],
##			  -tests => 4);
##	my $fea = Bio::SeqFeature::Annotated->new();
##	isa_ok($fea, "Bio::SeqFeatureI",'isa SeqFeatureI');
##	isa_ok($fea, "Bio::AnnotatableI",'isa AnnotatableI');
##	$fea = Bio::SeqFeature::Generic->new();
##	isa_ok($fea, "Bio::SeqFeatureI",'isa SeqFeatureI');
##	isa_ok($fea, "Bio::AnnotatableI",'isa AnnotatableI');
##}
##my $clu = Bio::Cluster::UniGene->new();
##isa_ok($clu, "Bio::AnnotatableI");
##my $aln = Bio::SimpleAlign->new();
##isa_ok($clu,"Bio::AnnotatableI");
##
### tests for Bio::Annotation::AnnotationFactory
##
##my $factory = Bio::Annotation::AnnotationFactory->new;
##isa_ok($factory, 'Bio::Factory::ObjectFactoryI');
##
### defaults to SimpleValue
##$ann = $factory->create_object(-value => 'peroxisome',
##			       -tagname => 'cellular component');
##isa_ok($ann, 'Bio::Annotation::SimpleValue');
##
##$factory->type('Bio::Annotation::OntologyTerm');
##
##$ann = $factory->create_object(-name => 'peroxisome',
##			       -tagname => 'cellular component');
##ok(defined $ann);
##isa_ok($ann, 'Bio::Annotation::OntologyTerm');
##
### unset type()
##$factory->type(undef);
##$ann = $factory->create_object(-text => 'this is a comment');
##ok(defined $ann,'Bio::Annotation::Comment');
##
##isa_ok($ann,'Bio::Annotation::Comment');
##
##ok $factory->type('Bio::Annotation::Comment');
##$ann = $factory->create_object(-text => 'this is a comment');
##ok(defined $ann,'Bio::Annotation::Comment');
##isa_ok($ann,'Bio::Annotation::Comment');
##
### factory guessing the type: Comment
##$factory = Bio::Annotation::AnnotationFactory->new();
##$ann = $factory->create_object(-text => 'this is a comment');
##ok(defined $ann,'Bio::Annotation::Comment');
##isa_ok($ann,'Bio::Annotation::Comment');
##
### factory guessing the type: Target
##$factory = Bio::Annotation::AnnotationFactory->new();
##$ann = $factory->create_object(-target_id => 'F1234',
##			       -start     => 1,
##			       -end       => 10 );
##ok defined $ann;
##isa_ok($ann,'Bio::Annotation::Target');
##
### factory guessing the type: OntologyTerm
##$factory = Bio::Annotation::AnnotationFactory->new();
##ok(defined ($ann = $factory->create_object(-name => 'peroxisome',
##					   -tagname => 'cellular component')));
##like(ref $ann, qr(Bio::Annotation::OntologyTerm));
##
### tree
##my $tree_filename = test_input_file('longnames.dnd');
##my $tree = Bio::TreeIO->new(-file=>$tree_filename)->next_tree();
##my $ann_tree = Bio::Annotation::Tree->new(
##					  -tagname  => 'tree',
##					  -tree_obj => $tree,
##					 );
##
##isa_ok($ann_tree, 'Bio::AnnotationI');
##$ann_tree->tree_id('test');
##is $ann_tree->tree_id(), 'test', "tree_id()";
##$ann_tree->tagname('tree'); 
##is $ann_tree->tagname(), 'tree', "tagname()";
##my $aln_filename = test_input_file('longnames.aln');
##use Bio::AlignIO;
##$aln = Bio::AlignIO->new(-file  => $aln_filename,
##			 -format=>'clustalw')->next_aln();
##isa_ok($aln, 'Bio::AnnotatableI');
##$ac = Bio::Annotation::Collection->new();
##$ac->add_Annotation('tree',$ann_tree);
##$aln->annotation($ac);
##for my $treeblock ( $aln->annotation->get_Annotations('tree') ) {
##  my $treeref = $treeblock->tree();
##  my @nodes = sort { defined $a->id &&
##		       defined $b->id &&
##			 $a->id cmp $b->id } $treeref->get_nodes();
##  is $nodes[12]->id, '183.m01790', "add tree to AlignI";
##  my $str;
##  for my $seq ($aln->each_seq_with_id($nodes[12]->id)) {
##    $str = $seq->subseq(1,20);
##  }
##  is( $str, "MDDKELEIPVEHSTAFGQLV", "get seq from node id");
##}
##
### factory guessing the type: Tree
##$factory = Bio::Annotation::AnnotationFactory->new();
##$ann = $factory->create_object(-tree_obj => $tree);
##ok defined $ann;
##isa_ok($ann,'Bio::Annotation::Tree');
##
###tagtree
##my $struct = [ 'genenames' => [
##			       ['genename' => [
##					       [ 'Name' => 'CALM1' ],
##					       ['Synonyms'=> 'CAM1'],
##					       ['Synonyms'=> 'CALM'],
##					       ['Synonyms'=> 'CAM' ] ] ],
##			       ['genename'=> [
##					      [ 'Name'=> 'CALM2' ],
##					      [ 'Synonyms'=> 'CAM2'],
##					      [ 'Synonyms'=> 'CAMB'] ] ],
##			       [ 'genename'=> [
##					       [ 'Name'=> 'CALM3' ],
##					       [ 'Synonyms'=> 'CAM3' ],
##					       [ 'Synonyms'=> 'CAMC' ] ] ]
##			      ] ];
##
##my $ann_struct = Bio::Annotation::TagTree->new(-tagname => 'gn',
##					       -value => $struct);
##
##isa_ok($ann_struct, 'Bio::AnnotationI');
##my $val = $ann_struct->value;
##like($val, qr/Name: CALM1/,'default itext');
##
### roundtrip
##my $ann_struct2 = Bio::Annotation::TagTree->new(-tagname => 'gn',
##						-value => $val);
##is($ann_struct2->value, $val,'roundtrip');
##
### formats 
##like($ann_struct2->value, qr/Name: CALM1/,'itext');
##$ann_struct2->tagformat('sxpr');
##like($ann_struct2->value, qr/\(Name "CALM1"\)/,'spxr');
##$ann_struct2->tagformat('indent');
##like($ann_struct2->value, qr/Name "CALM1"/,'indent');
##
##SKIP: {
##    eval {require XML::Parser::PerlSAX};
##    skip ("XML::Parser::PerlSAX rquired for XML",1) if $@;
##    $ann_struct2->tagformat('xml');
##    like($ann_struct2->value, qr/<Name>CALM1<\/Name>/,'xml');
##}
##
### grab Data::Stag nodes, use Data::Stag methods
##my @nodes = $ann_struct2->children;
##for my $node (@nodes) {
##    isa_ok($node, 'Data::Stag::StagI');
##    is($node->element, 'genename');
##    # add tag-value data to node
##    $node->set('foo', 'bar');
##    # check output
##    like($node->itext, qr/foo:\s+bar/,'child changes');
##}
##
##$ann_struct2->tagformat('itext');
##like($ann_struct2->value, qr/foo:\s+bar/,'child changes in parent node');
##
### pass in a Data::Stag node to value()
##$ann_struct = Bio::Annotation::TagTree->new(-tagname => 'mytags');
##like($ann_struct->value, qr/^\s+:\s+$/xms, 'no tags');
##like($ann_struct->value, qr/^\s+:\s+$/xms,'before Stag node');
##$ann_struct->value($nodes[0]);
##like($ann_struct->value, qr/Name: CALM1/,'after Stag node');
##is(ref $ann_struct->node, ref $nodes[0], 'both stag nodes');
##isnt($ann_struct->node, $nodes[0], 'different instances');
##
### pass in another TagTree to value()
##$ann_struct = Bio::Annotation::TagTree->new(-tagname => 'mytags');
##like($ann_struct->value, qr/^\s+:\s+$/xms,'before TagTree');
##$ann_struct->value($ann_struct2);
##like($ann_struct->value, qr/Name: CALM2/,'after TagTree');
##is(ref $ann_struct->node, ref $ann_struct2->node, 'both stag nodes');
##isnt($ann_struct->node, $ann_struct2->node, 'different instances');
##
### replace the Data::Stag node in the annotation (no copy)
##$ann_struct = Bio::Annotation::TagTree->new(-tagname => 'mytags');
##like($ann_struct->value, qr/^\s+:\s+$/xms,'before TagTree');
##$ann_struct->node($nodes[1]);
##like($ann_struct->value, qr/Name: CALM2/,'after TagTree');
##is(ref $ann_struct->node, ref $ann_struct2->node, 'stag nodes');
##is($ann_struct->node, $nodes[1], 'same instance');
### replace the Data::Stag node in the annotation (use duplicate)
##$ann_struct = Bio::Annotation::TagTree->new(-tagname => 'mytags');
##like($ann_struct->value, qr/^\s+:\s+$/xms,'before TagTree');
##$ann_struct->node($nodes[1],'copy');
##like($ann_struct->value, qr/Name: CALM2/,'after TagTree');
##is(ref $ann_struct->node, ref $ann_struct2->node, 'stag nodes');
##isnt($ann_struct->node, $nodes[1], 'different instance');
##
###check insertion in to collection
##$ann_struct = Bio::Annotation::TagTree->new(-value => $struct);
##$ac = Bio::Annotation::Collection->new();
##
##$ac->add_Annotation('genenames',$ann_struct);
##my $ct = 0;
##for my $tagtree ( $ac->get_Annotations('genenames') ) {
##  isa_ok($tagtree, 'Bio::AnnotationI');
##  for my $node ($tagtree->children) {
##    isa_ok($node, 'Data::Stag::StagI');
##    like($node->itext, qr/Name:\s+CALM/,'child changes');
##    $ct++;
##  }
##}
##is($ct,3);
##
### factory guessing the type: TagTree
##$factory = Bio::Annotation::AnnotationFactory->new();
##$ann = $factory->create_object(-value => $struct);
##ok defined $ann;
##isa_ok($ann,'Bio::Annotation::TagTree');
