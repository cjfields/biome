package Biome::SeqFeature::Location;

use Biome;
use namespace::clean -except => qw(meta);

with 'Biome::Role::Location::Simple';
with 'Biome::Role::Location::Locatable';

# note: due to a bug in Moose, abstract roles have to be consumed here instead
# of in the implementing role when attributes are required.

with 'Biome::Role::SeqFeature';

__PACKAGE__->meta->make_immutable;

1;

__END__

