BEGIN {
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
}

###############################

# import Moose magic through meta class (no need to import separately)
{
package MyRole1;

use Biome::Role;

requires 'foo', 'bar','_build_att1', 'att2';

no Biome::Role;

}
###############################

{
# import Moose magic through meta class (no need to import separately)
package MyRole2;

use Biome::Role;

with 'MyRole1';

requires 'bah';

has 'att1'  => (isa => 'Str', is => 'rw', builder => '_build_att1');

sub _build_att1 { '' }

sub foo { 1 }

no Biome::Role;

}

###############################

{
package RoleTest;

use Biome;

has 'att2'    => (isa => 'Int', is => 'rw');

with 'MyRole2';

sub bar { 2 }

sub baz { 42 };

sub bah {98.6 };

no Biome;
}
###############################

package main;

my $foo = RoleTest->new(att1 => 'hello', att2 => 12);

is($foo->baz, 42);
is($foo->foo, 1);
is($foo->att1, 'hello');
is($foo->att2, 12);
is($foo->bah, 98.6);
does_ok($foo, 'MyRole1', 'does MyRole1');
does_ok($foo, 'MyRole2', 'does MyRole2');
isa_ok($foo, 'RoleTest');
isa_ok($foo, 'Biome::Root');
isa_ok($foo->meta, 'Biome::Meta::Class');

done_testing();