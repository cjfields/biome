package Biome::Root::IO;

use Biome;

with 'Biome::Role::IO::Handle';
with 'Biome::Role::IO::File';
with 'Biome::Role::IO::Tempfile';
with 'Biome::Role::IO::Scalar';
with 'Biome::Role::IO::Buffer_Unread';

no Biome;

1;

__END__

