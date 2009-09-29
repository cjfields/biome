use strict;
use warnings;

BEGIN {
    use Test::More tests => 9;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Annotation::DBLink');
}

my $link1 = Biome::Annotation::DBLink->new(-database => 'TSC',
					 -primary_id => 'TSC0000030',
					);
does_ok($link1,'Biome::Role::Annotate');
does_ok($link1,'Biome::Role::Identifiable');
is $link1->database(), 'TSC';
is $link1->primary_id(), 'TSC0000030';
is $link1->as_text, 'Direct database link to TSC0000030 in database TSC';

my $t = $link1->hash_tree;

is $t->{database}, 'TSC';
is $t->{primary_id}, 'TSC0000030';

is $link1->type, 'dblink';
