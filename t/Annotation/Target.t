use strict;
use warnings;

BEGIN {
    use Test::More tests => 11;
    use Test::Moose;
    use Test::Exception;
    use_ok('Bio::Moose::Annotation::Target');
}

my $target = Bio::Moose::Annotation::Target->new(
    -database   => 'UniProt',
    -primary_id => 'MySeq',
    -target_id  => 'F321966.1',
    -start      => 1,
    -end        => 200,
    -strand     => 1);

does_ok($target,'Bio::Moose::Role::Annotate');
does_ok($target,'Bio::Moose::Role::Identify');

is $target->database(), 'UniProt';
is $target->start(), 1;
is $target->end(), 200;
is $target->strand(), 1;
is $target->length(), 200;
is $target->as_text, 'Target=F321966.1 1 200 1';

my $t = $target->hash_tree;

is $t->{database}, 'UniProt';
is $t->{primary_id}, 'MySeq';
