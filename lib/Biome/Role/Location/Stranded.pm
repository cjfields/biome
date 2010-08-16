package Biome::Role::Location::Stranded;

use Biome::Role;
use namespace::clean -except => 'meta';

use Biome::Type::Sequence qw(Sequence_Strand);

has strand  => (
    isa     => Sequence_Strand,
    is      => 'rw',
    default => 0,
    coerce  => 1
);

1;

__END__