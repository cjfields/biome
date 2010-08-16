# Let the code begin...

package Biome::Location::Split;
use Biome;
use namespace::clean -except => 'meta';

# TODO - It should be possible to stack roles (have an implementation role
# consume an interface role).  The problem is tracable to an issue with Moose,
# so we simply punt for now and supply a simple Role and default methods the
# class can override

with 'Biome::Role::Location::Split';
with 'Biome::Role::Location::Locatable';

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