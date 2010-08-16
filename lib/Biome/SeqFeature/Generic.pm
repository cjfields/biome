package Biome::SeqFeature::Generic;

use Biome;
use namespace::clean -except => qw(meta);
use List::MoreUtils qw(any);
use Biome::Location::Simple;

with 'Biome::Role::Location::Split';
with 'Biome::Role::Location::Locatable';
with 'Biome::Role::SeqFeature';

sub BUILD {
    my ($self, $params) = @_;
    if (any { exists $params->{$_} } qw(start end strand seq_id)) {
        $self->add_sub_Location(Biome::Location::Simple->new(%$params));
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

