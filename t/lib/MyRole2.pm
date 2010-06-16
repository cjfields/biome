#!/usr/bin/perl -w
use strict;

package MyRole2;

use Biome::Role;

with 'MyRole1';

requires 'bah';

sub foo { 1 }

no Biome::Role;

1;

__END__

