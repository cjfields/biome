# Let the code begin...

package Biome::Location::Simple;

use 5.010;
use Biome;
use namespace::autoclean;

# TODO - It should be possible to stack roles (have an implementation role
# consume an interface role).  The problem is tracable to an issue with Moose,
# so we simply punt for now and supply a simple Role and default methods the
# class can override

with 'Biome::Role::Location::Simple';
with 'Biome::Role::Location::Collection' => {base_name  => 'Location', top => 0};
with 'Biome::Role::Location::Locatable';

sub BUILD {
    my ($self, $params) = @_;

    # this should probably just fail validation, seems clunky to handle it here
    if ($params->{start} && $params->{end} && ($params->{end} < $params->{start})) {
        $self->warn('End is greater than start; flipping strands');
        $self->end($params->{start});
        $self->start($params->{end});
        $self->strand($self->strand * -1);
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
