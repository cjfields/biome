use strict;
use warnings;

BEGIN {
    use Test::More tests => 12;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Annotation::Target');
}

my $target = Biome::Annotation::Target->new(
    -database   => 'UniProt',
    -primary_id => 'MySeq',
    -target_id  => 'F321966.1',
    -start      => 1,
    -end        => 200,
    -strand     => 1);

does_ok($target,'Biome::Role::Annotate');
does_ok($target,'Biome::Role::Identify');

is $target->database(), 'UniProt';
is $target->start(), 1;
is $target->end(), 200;
is $target->strand(), 1;
is $target->length(), 200;
is $target->as_text, 'Target=F321966.1 1 200 1';
is $target->type, 'target';

my $t = $target->hash_tree;

is $t->{database}, 'UniProt';
is $t->{primary_id}, 'MySeq';
