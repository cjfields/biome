package Biome::SeqFeature::Location;

use Biome;
use namespace::clean -except => qw(meta);

# note, the only difference here is this role allows fuzzy locations
with 'Biome::Role::Location::Simple';

# note: due to a bug in Moose, abstract roles have to be consumed here instead
# of in the implementing role when attributes are required.

with 'Biome::Role::Location::Does_Range';
with 'Biome::Role::SeqFeature';

__PACKAGE__->meta->make_immutable;

1;

__END__

