use strict;
use warnings;

BEGIN {
	use lib '.';
	use Test::More;
	use Test::Moose;
	use Test::Exception;
}

our $VERBOSE = $ENV{BIOME_DEBUG} || 0;

###############################

# import Moose magic through meta class (no need to import separately)
package MyClass1;

use Biome; # implied base class is Bio::Root::Root

has 'test1' => ( is => 'rw');

no Biome;

package main;

my $i = MyClass1->new(test1 => 'Foo');

for my $attribute (qw(verbose strict test1)) {
    has_attribute_ok($i, $attribute);
}

is($i->test1, 'Foo', "Named parameter [test1]");

meta_ok('Biome::Role::Root', 'Biome::Root has a meta');
meta_ok($i, 'Instances of Biome::Root have a meta class');

isa_ok($i->meta, 'Moose::Meta::Class');

# We should hook in Bio::Root::Exceptions here
throws_ok {$i->strict('Foo')} qr/Validation failed for 'Int'/,
    'verbose() requires an Int value';

throws_ok {$i->verbose('Foo')} qr/Validation failed for 'Bool'/,
    'debug() requires a Bool value (0 or 1)';

is($i->strict, 0, 'default strictness');
is($i->verbose, $VERBOSE, 'default verbosity');

# explicit warn/throw

throws_ok {$i->throw('Foo!')} qr/Foo!/, 'throw()';

isa_ok($@, 'Moose::Exception');

done_testing();
