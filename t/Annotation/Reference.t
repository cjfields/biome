use strict;
use warnings;

BEGIN {
    use Test::More tests => 12;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Annotation::Reference');
}

my $ref = Biome::Annotation::Reference->new( -authors  => 'author line',
					   -title    => 'title line',
					   -location => 'location line',
					   -start    => 12);
does_ok($ref,'Biome::Role::Annotatable');
is $ref->authors, 'author line';
is $ref->title,  'title line';
is $ref->location, 'location line';
is $ref->start, 12;
is $ref->database, 'MEDLINE';
is $ref->as_text, 'Reference: title line';

my $t = $ref->hash_tree;

is($t->{authors}, 'author line');
is($t->{title}, 'title line');
is($t->{database}, 'MEDLINE');

is $ref->type, 'reference';