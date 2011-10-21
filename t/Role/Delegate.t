#!/usr/bin/perl -w
use strict;
use warnings;

BEGIN {
    use Test::More tests => 7;
    use Test::Moose;
    use Test::Exception;
}

{
    package Foo;
    use Moose;

    with 'Biome::Role::Delegate'   => {
            delegates => {
                'file_temp'    => {
                    isa         => 'File::Temp',
                    handles     => {
                        unlink_tempfile    => 'unlink_on_destroy',
                    }
                }
            }
        };


    no Moose;
}

my $foo = Foo->new;
does_ok($foo, 'Biome::Role::Delegate');
can_ok('Foo', 'file_temp');
can_ok($foo, 'file_temp');
isa_ok($foo->file_temp, 'File::Temp');

can_ok($foo, 'unlink_tempfile');

is($foo->unlink_tempfile, 1, 'returns default in delegate');

# test basic exceptions

throws_ok
{
    package Foo;
    use Moose;
    with 'Biome::Role::Delegate';
    no Moose;
} qr/Attribute \(delegates\) is required/, 'Requires classes attribute';

done_testing();
