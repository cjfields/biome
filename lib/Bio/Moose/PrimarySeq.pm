package Bio::Moose::PrimarySeq;

use Bio::Moose;

with qw(Bio::Moose::Role::PrimarySeq
        Bio::Moose::Role::Describe
        Bio::Moose::Role::Identify);

sub _build_display_id { $_[0] }

no Bio::Moose;
__PACKAGE__->meta->make_immutable;