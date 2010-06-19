package Biome::PrimarySeq;

use Biome;

with 'Biome::Role::PrimarySeq',
     'Biome::Role::Describable', 
     'Biome::Role::Identifiable';

# validate sequences by default (we might make this optional to speed things up)

has '+object_id'    => (
    default     => sub {shift->accession_number(@_)},
    lazy        => 1
    );

has '+primary_id'    => (
    default     => sub {shift->display_id(@_)},
    lazy        => 1
    );

has '+display_name'    => (
    default     => sub {shift->display_id(@_)},
    lazy        => 1
    );

no Biome;

__PACKAGE__->meta->make_immutable;
