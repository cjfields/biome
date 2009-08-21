
use strict;
use warnings;

BEGIN {
    use Test::More tests => 12;
    use Test::Moose;
    use Test::Exception;
}

{
    package MyTagCollection;
    
    use Biome;
    
    with 'Biome::Role::CollectTags';
    
    no Biome;
    
    __PACKAGE__->meta->make_immutable();
}

my $tc = MyTagCollection->new();

$tc->add_tag_values('foo', 'bar', 'baz');
ok($tc->has_tag('foo'));

is(join(',',$tc->get_all_tags), 'foo');
is(join(',',sort $tc->get_tag_values('foo')),'bar,baz');

is($tc->get_tag_values('bar'), undef);

$tc->add_tag_values('values', 2, 3, 4);
is(join(',',sort $tc->get_all_tags), 'foo,values');
is(join(',',$tc->get_tag_values('values')), '2,3,4');

# remove_tags
my @vals = $tc->remove_tag('values');
is(join(',',@vals), '2,3,4');
ok(!$tc->has_tag('values'));

$tc->set_tag_values('foo', qw(1 2));
is(join(',',sort $tc->get_tag_values('foo')),'1,2');

$tc->add_tag_values('foo', qw(3 4));
is(join(',',sort $tc->get_tag_values('foo')),'1,2,3,4');

$tc->add_tag_values('bar', qw(boo hoo));

# get_tagset_values
is(join(',',sort $tc->get_tagset_values(qw(foo bar))),'1,2,3,4,boo,hoo');
$tc->remove_tag('foo');
is(join(',',sort $tc->get_tagset_values(qw(foo bar))),'boo,hoo');
