use strict;
use warnings;

BEGIN {
    use Test::More tests => 8;
    use Test::Moose;
    use Test::Exception;
    use_ok('Bio::Moose::Annotation::Reference');
}

my $ref = Bio::Moose::Annotation::Reference->new( -authors  => 'author line',
					   -title    => 'title line',
					   -location => 'location line',
					   -start    => 12);
does_ok($ref,'Bio::Moose::Role::Annotate');
is $ref->authors, 'author line';
is $ref->title,  'title line';
is $ref->location, 'location line';
is $ref->start, 12;
is $ref->database, 'MEDLINE';
is $ref->as_text, 'Reference: title line';

my $t = $ref->hash_tree;

