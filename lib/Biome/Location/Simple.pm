# Let the code begin...

package Biome::Location::Simple;

use 5.010;
use Biome;
use namespace::autoclean;

with 'Biome::Role::Location::Simple';
with 'Biome::Role::Location::Collection';
with 'Biome::Role::Location::Locatable';

__PACKAGE__->meta->make_immutable;

1;

__END__
