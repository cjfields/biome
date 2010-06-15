# Let the code begin...

package Biome::Segment::Simple;

use 5.010;
use Biome;

# implementation that covers abstract role
with 'Biome::Role::Segment';

sub BUILD {
    my ($self, $params) = @_;
    
    if ($params->{location_string}) {
        $self->throw("Can't use 'location_string' with other parameters")
            if (scalar(keys %$params) > 1);
        $self->from_string($params->{location_string});
    }
    
    if ($params->{start} && $params->{end} && ($params->{end} < $params->{start})) {
        $self->warn('End is greater than start; flipping strands');
        $self->end($params->{start});
        $self->start($params->{end});
        $self->strand($self->strand * -1);
    }
    
    $params->{segment_type} && $self->segment_type($params->{segment_type});
}

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__
