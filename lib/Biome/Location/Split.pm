# Let the code begin...

package Biome::Location::Split;
use Biome;
use namespace::clean -except => 'meta';

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