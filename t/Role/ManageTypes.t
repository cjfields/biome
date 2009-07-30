use strict;
use warnings;

BEGIN {
    use Test::More tests => 17;
    use Test::Moose;
    use Test::Exception;
}

use Bio::Moose::Annotation::Comment;
use Bio::Moose::Annotation::Reference;
use Bio::Moose::Annotation::SimpleValue;
use Bio::Moose::Annotation::DBLink;
use Bio::Moose::Annotation::Target;

{
    package MyTypeManager;
    
    use Bio::Moose;
    
    with 'Bio::Moose::Role::ManageTypes';
    
    has '+typemap' => (
        default     => sub {
            {
            'reference'     => "Bio::Moose::Annotation::Reference",
            'comment'       => "Bio::Moose::Annotation::Comment",
            'dblink'        => "Bio::Moose::Annotation::DBLink",
            'simplevalue'   => "Bio::Moose::Annotation::SimpleValue",
            'annotate'      => "Bio::Moose::Role::Annotate",
            'identify'      => "Bio::Moose::Role::Identify",
            'describe'      => "Bio::Moose::Role::Describe",
            'range'         => "Bio::Moose::Role::Range",
            }
            }
        );
    
    no Bio::Moose;
    
    __PACKAGE__->meta->make_immutable();
}

my $tm = MyTypeManager->new();

is($tm->type_for_key('reference'),'Bio::Moose::Annotation::Reference');
is($tm->type_for_key('dblink'),'Bio::Moose::Annotation::DBLink');
is($tm->type_for_key('foo'),undef);

my $comment = Bio::Moose::Annotation::Comment->new(-tag_name => 'mycomment',
                                            -text => 'sometext');

ok($tm->is_valid('comment',$comment));
ok($tm->does_valid('annotate',$comment));
ok(!$tm->does_valid('identify',$comment));
ok(!$tm->has_valid('Str',$comment));

my $target = Bio::Moose::Annotation::Target->new(
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

my $simple = Bio::Moose::Annotation::SimpleValue->new(
                    -tag_name => 'colour',
					-value   => '1');

ok($tm->is_valid('simplevalue',$simple));

my $ref = Bio::Moose::Annotation::Reference->new( -authors  => 'author line',
					   -title    => 'title line',
					   -location => 'location line',
					   -start    => 12);

ok($tm->is_valid('dblink',$ref));

my $link = Bio::Moose::Annotation::DBLink->new(-database => 'TSC',
					 -primary_id => 'TSC0000030',
					);

ok($tm->is_valid('dblink',$link));

