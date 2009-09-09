use strict;
use warnings;

BEGIN {
    use Test::More tests => 17;
    use Test::Moose;
    use Test::Exception;
}

use Biome::Annotation::Comment;
use Biome::Annotation::Reference;
use Biome::Annotation::SimpleValue;
use Biome::Annotation::DBLink;
use Biome::Annotation::Target;

{
    package MyTypeManager;
    
    use Biome;
    
    with 'Biome::Role::ManageTypes';
    
    has '+type_map' => (
        default     => sub {
            {
            'reference'     => "Biome::Annotation::Reference",
            'comment'       => "Biome::Annotation::Comment",
            'dblink'        => "Biome::Annotation::DBLink",
            'simplevalue'   => "Biome::Annotation::SimpleValue",
            'annotate'      => "Biome::Role::Annotatable",
            'identify'      => "Biome::Role::Identifiable",
            'describe'      => "Biome::Role::Describable",
            'range'         => "Biome::Role::Rangeable",
            }
            }
        );
    
    no Biome;
    
    __PACKAGE__->meta->make_immutable();
}

my $tm = MyTypeManager->new();

is($tm->type_for_key('reference'),'Biome::Annotation::Reference');
is($tm->type_for_key('dblink'),'Biome::Annotation::DBLink');
is($tm->type_for_key('foo'),undef);

my $comment = Biome::Annotation::Comment->new(-tag_name => 'mycomment',
                                            -text => 'sometext');

ok($tm->is_valid('comment',$comment));
ok($tm->does_valid('annotate',$comment));
ok(!$tm->does_valid('identify',$comment));
ok(!$tm->has_valid('Str',$comment));

my $target = Biome::Annotation::Target->new(
    -database   => 'UniProt',
    -primary_id => 'MySeq',
    -target_id  => 'F321966.1',
    -start      => 1,
    -end        => 200,
    -strand     => 1);

ok($tm->is_valid('dblink',$target));
ok($tm->does_valid('annotate',$target));
ok($tm->does_valid('range',$target));
ok($tm->does_valid('identify',$target));
ok(!$tm->does_valid('describe',$target));
ok(!$tm->does_valid('foo',$target));
ok(!$tm->does_valid('identify',undef));

my $simple = Biome::Annotation::SimpleValue->new(
                    -tag_name => 'colour',
					-value   => '1');

ok($tm->is_valid('simplevalue',$simple));

my $ref = Biome::Annotation::Reference->new( -authors  => 'author line',
					   -title    => 'title line',
					   -location => 'location line',
					   -start    => 12);

ok($tm->is_valid('dblink',$ref));

my $link = Biome::Annotation::DBLink->new(-database => 'TSC',
					 -primary_id => 'TSC0000030',
					);

ok($tm->is_valid('dblink',$link));

