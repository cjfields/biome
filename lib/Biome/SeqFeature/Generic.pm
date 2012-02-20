package Biome::SeqFeature::Generic;

use Biome;
use namespace::clean -except => qw(meta);
use List::MoreUtils qw(any);
use Biome::Location::Simple;

with 'Biome::Role::Location::Simple';
with 'Biome::Role::Location::Split';
with 'Biome::Role::Location::Locatable';
with 'Biome::Role::SeqFeature';

__PACKAGE__->meta->make_immutable;

1;

__END__
