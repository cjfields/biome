package Biome::SeqFeature::Generic;

use 5.010;
use Biome;
use List::MoreUtils qw(any);
use namespace::clean -except => qw(meta);
use Biome::Location::Simple;

# note: due to a bug in Moose, abstract roles have to be consumed here instead
# of in the implementing role when attributes are required.

with 'Biome::Role::Location::Split';
with 'Biome::Role::Location::Locatable';
with 'Biome::Role::SeqFeature';

# Moose bug with delegation and 'handles'; attributes aren't caught within roles
# and aren't delegated to properly, so we catch that and DTRT here.  

sub BUILD {
    my ($self, $params) = @_;
    if (any { exists $params->{$_} } qw(start end strand seq_id)) {
        $self->add_sub_Location(Biome::Location::Simple->new(%$params));
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

