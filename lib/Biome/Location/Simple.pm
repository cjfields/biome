# Let the code begin...

package Biome::Location::Simple;

use 5.010;
use Biome;
use namespace::clean -except => 'meta';

# TODO - It should be possible to stack roles (have an implementation role
# consume an interface role).  The problem is tracable to an issue with Moose,
# so we simply punt for now and supply a simple Role and default methods the
# class can override

with 'Biome::Role::Location::Simple';

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
    
    $params->{location_type} && $self->location_type($params->{location_type});
}

__PACKAGE__->meta->make_immutable;

1;

__END__
