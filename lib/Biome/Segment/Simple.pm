# Let the code begin...

package Biome::Segment::Simple;

use Biome;
use 5.010;

# import this in to use to_LocationType and to_LocationSymbol coersion if needed
use Biome::Types qw(LocationType);

with 'Biome::Role::Segment';

sub BUILD {
    my ($self, $params) = @_;
    
    # correct for reversed location coordinates
    # (this should prob. be an exception upon instance creation, but we try to
    # DTRT for now)
    if ($params->{start} && $params->{end} && ($params->{end} < $params->{start})) {
        $self->warn('End is greater than start; flipping strands');
        $self->end($params->{start});
        $self->start($params->{end});
        $self->strand($self->strand * -1);
    }
    
    $params->{segment_type} && $self->segment_type($params->{segment_type});
}

# indicates how segment range should be generally interpreted for

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__
