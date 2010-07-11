package Biome::SeqFeature::Generic;

use Biome;
use namespace::clean -except => qw(meta);
use Biome::Location::Simple;

# note: due to a bug in Moose, abstract roles have to be consumed here instead
# of in the implementing role when attributes are required.

with 'Biome::Role::Locatable';
with 'Biome::Role::Location::Does_Range';
with 'Biome::Role::SeqFeature';

# Moose bug with delegation and 'handles'; attributes aren't caught within roles
# and aren't delegated to properly, so we catch that and DTRT here.  

sub BUILD {
    my ($self, $params) = @_;
    for my $delegate (qw(start end strand)) {
        $self->$delegate($params->{$delegate}) if exists $params->{$delegate};
    }
}

# lazy builder method, required by Biome::Role::Locatable 'location' attribute
sub _build_location {
    return Biome::Location::Simple->new();
}

__PACKAGE__->meta->make_immutable;

1;

__END__

