# Let the code begin...

package Biome::Segment::Split;
use Biome;

with 'Biome::Role::Segment', 'Biome::Role::Segment::SplitSegment';

# I'm not completely sold on the idea of using split locations, primarily
# b/c these can be implemented via unflattened features.  But, just in case,
# here it is

sub flip_strand {
    shift->throw_not_implemented;
}

sub length {
    shift->throw_not_implemented;
}

sub min_start {
    shift->throw_not_implemented;
}

sub max_start {
    shift->throw_not_implemented;
}

sub min_end {
    shift->throw_not_implemented;
}

sub max_end {
    shift->throw_not_implemented;
}

sub pos_type {
    shift->throw_not_implemented;
}

sub segment_type {
    shift->throw_not_implemented;
}

sub is_remote {
    shift->throw_not_implemented;
}

sub to_FTstring {
    shift->throw_not_implemented;
}

sub valid_Segment {
    shift->throw_not_implemented;
}

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__