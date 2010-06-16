BEGIN {
    use lib qw(. t/lib);
    use Test::More;
    use Test::Moose;
    use Test::Exception;
}

{
package RoleTest;

use Biome;

has 'att1'  => (isa => 'Str', is => 'rw');

has 'att2'    => (isa => 'Int', is => 'rw');

with 'MyRole2';

sub bar { 2 }

sub baz { 42 };

sub bah {98.6 };

no Biome;
}
###############################

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