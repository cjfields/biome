# Let the code begin...

package Biome::Segment::Split;
use Biome;
use namespace::clean -except => 'meta';

use Biome::Role::Range;
use MooseX::Types::Moose qw(Maybe);
use List::Util qw(reduce);
use Biome::Type::Segment qw(Split_Segment_Type );
use Biome::Type::Sequence qw(Sequence_Strand);

with 'Biome::Role::Segment::SegmentContainer';

sub BUILD {
    my ($self, $params) = @_;
    if ($params->{location_string}) {
        $self->throw("Can't use 'location_string' with other parameters")
            if (scalar(keys %$params) > 1);
        $self->from_string($params->{location_string});
    }
}

with 'Biome::Role::Segment';

__PACKAGE__->meta->make_immutable;

1;

__END__