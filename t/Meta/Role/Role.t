BEGIN {
    use lib '.';
    use Test::More tests => 10;
    use Test::Moose;
    use Test::Exception;
}

###############################

# import Moose magic through meta class (no need to import separately)
{
package MyRole1;

use Biome::Role;

requires 'baz';

has 'test_att' => (
    isa => 'Str',
    is  => 'rw'
);

sub foo {
    return 1;
}

sub bar {
    return 2;
}

no Biome::Role;

}
###############################

{
# import Moose magic through meta class (no need to import separately)
package MyRole2;

use Biome::Role;

requires 'bah';

no Biome::Role;

}
###############################
{
package RoleTest;

use Biome;

with qw(MyRole1 MyRole2);

sub baz { return 42 };

sub bah { return 98.6 };

no Biome;
}
###############################

package main;

my $foo = RoleTest->new(test_att => 'hello');

is($foo->baz, 42);
is($foo->bar, 2);
is($foo->foo, 1);
is($foo->test_att, 'hello');
is($foo->bah, 98.6);
does_ok($foo, 'MyRole1', 'does MyRole1');
does_ok($foo, 'MyRole2', 'does MyRole2');
isa_ok($foo, 'RoleTest');
does_ok($foo, 'Biome::Role::Root');
isa_ok($foo->meta, 'Moose::Meta::Class');

