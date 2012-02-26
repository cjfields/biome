package Biome::SeqFeature::Generic;

use Biome;
use namespace::autoclean;
use List::MoreUtils qw(any);
use Biome::Location::Simple;

with 'Biome::Role::Location::Simple';
with 'Biome::Role::Location::Collection' => {base_name  => 'SeqFeature'};
with 'Biome::Role::Location::Locatable';
with 'Biome::Role::SeqFeature';

sub BUILD {
    my ($self, $params) = @_;

    if ($params->{start} && $params->{end} && ($params->{end} < $params->{start})) {
        $self->warn('End is greater than start; flipping strands');
        $self->end($params->{start});
        $self->start($params->{end});
        $self->strand($self->strand * -1);
    }

    $params->{location_type} && $self->location_type($params->{location_type});
}

__PACKAGE__->meta->make_immutable;

1;

__END__
