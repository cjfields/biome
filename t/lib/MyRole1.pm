#!/usr/bin/perl -w
use strict;

package MyRole1;

use Biome::Role;

requires 'foo', 'bar','att1', 'att2';

no Biome::Role;

1;

__END__

