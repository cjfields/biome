use strict;
use warnings;

BEGIN {
use Test::More tests => 9;
    use Test::Moose;
    use Test::Exception;
	use_ok('Biome::Annotation::SimpleValue');
}

#simple value

my $simple = Biome::Annotation::SimpleValue->new(
                    -tagname => 'colour',
					-value   => '1');

does_ok($simple, 'Biome::Role::Annotatable');
is $simple->display_text, 1;
is $simple->value, 1;
is $simple->tagname, 'colour';

is $simple->value(0), 0;
is $simple->value, 0;
is $simple->display_text, 0;

is $simple->type, 'simplevalue';

