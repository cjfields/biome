# Let the code begin...

package Biome::Location::Split;
use Biome;
use namespace::clean -except => 'meta';

# TODO - It should be possible to stack roles (have an implementation role
# consume an interface role), but for some reason this isn't working here.
# Problem isn't traceable to Biome-specific classes, so will need to simplify
# this down to trace the problem. For time being, interface is resolved in the
# class, not the role implementation

with 'Biome::Role::Location::Split'; # implementation
with 'Biome::Role::Location::Does_SplitLocation'; #interface

sub BUILD {
    my ($self, $params) = @_;
    if ($params->{location_string}) {
        $self->throw("Can't use 'location_string' with other parameters")
            if (scalar(keys %$params) > 1);
        $self->from_string($params->{location_string});
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__