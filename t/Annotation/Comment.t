use strict;
use warnings;

BEGIN {
    use Test::More tests => 8;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Annotation::Comment');
}

my $comment = Biome::Annotation::Comment->new(-tagname => 'mycomment',
                                            -text => 'sometext');

does_ok($comment,'Biome::Role::Annotate');

is $comment->text, 'sometext';
is $comment->value, 'sometext';
is $comment->display_text, 'sometext';
is $comment->tagname, 'mycomment';
is $comment->as_text, 'Comment: sometext';

is $comment->type, 'comment';
