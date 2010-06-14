# Let the code begin...

package Biome::Segment::Split;
use Biome;

use Biome::Role::Range;
use MooseX::Types::Moose qw(Maybe);
use List::Util qw(reduce);
use Biome::Type::Segment qw(Split_Segment_Type );
use Biome::Type::Sequence qw(Sequence_Strand);

with 'Biome::Role::Segment::SegmentContainer';

sub BUILD {
    my ($self, $params) = @_;
    if ($params->{location_string}) {
        $self->throw("Can't use 'location_string' with other parameters")
            if (scalar(keys %$params) > 1);
        $self->from_string($params->{location_string});
    }
}

has     'strand'      => (
    isa         => Maybe[Sequence_Strand],
    is          => 'rw',
    lazy        => 1,
    predicate   => 'has_strand',
    default     => sub {
        my $self = shift;
        return $self->sub_Segment_strand;
        },
);

sub start {
    my $self = shift;
    return $self->get_sub_Segment(0)->start if $self->is_remote;
    return $self->_reduce('start');
}

sub end {
    my $self = shift;
    return $self->get_sub_Segment(0)->end if $self->is_remote;
    return $self->_reduce('end');
}

sub is_remote {
    my $self = shift;
    for my $seg ($self->sub_Segments) {
        return 1 if $seg->is_remote;
    }
    0;
}

sub min_start {
    my $self = shift;
    return $self->get_sub_Segment(0)->min_start if $self->is_remote;
    return $self->_reduce('min_start');
}

sub max_start {
    my $self = shift;
    return $self->get_sub_Segment(0)->max_start if $self->is_remote;
    return $self->_reduce('max_start');
}

sub min_end {
    my $self = shift;
    return $self->get_sub_Segment(0)->min_end if $self->is_remote;
    return $self->_reduce('min_end');
}

sub max_end {
    my $self = shift;
    return $self->get_sub_Segment(0)->max_end if $self->is_remote;
    return $self->_reduce('max_end');
}

sub start_pos_type {
    my $self = shift;
    my $type = reduce {$a eq $b ? $a : undef}
        map {$_->start_pos_type} $self->sub_Segments;
    return $type;
}

sub end_pos_type {
    my $self = shift;
    my $type = reduce {$a eq $b ? $a : undef} 
        map {$_->end_pos_type} $self->sub_Segments;
    return $type;
}

sub valid_Segment {
    # TODO: add tests
    my $self = shift;
    my $type = reduce {$a eq $b ? 1 : 0} 
        map {$_->valid_Segment} $self->sub_Segments;
}

sub is_fuzzy {
    # TODO: add tests
    my $self = shift;
    my $type = reduce {$a eq $b ? 1 : 0} 
        map {$_->is_fuzzy} $self->sub_Segments;
}

# no offsets for splits?  Or maybe for only the first/last one?
sub start_offset { 0 }
sub end_offset { 0 }

# helper, just grabs the indicated value for the contained segments
sub _reduce {
    my ($self, $caller) = @_;
    my @segs = sort {
        $a->$caller <=> $b->$caller
                     }
    grep {$_->$caller} $self->sub_Segments;
    return unless @segs == $self->num_sub_Segments;
    $caller =~ /start/ ? return $segs[0]->$caller : return $segs[-1]->$caller;
}

sub flip_strand {
    my $self = shift;
    my @segs = @{$self->segments()};
    @segs = map {$_->flip_strand(); $_} reverse @segs;
    $self->segments(\@segs);
}

sub to_string {
    my $self = shift;
    # JOIN assumes specific order, ORDER does not, BOND
    my $type = $self->segment_type;
    if ($self->resolve_Segments) {
        my $substrand = $self->sub_Segment_strand;
        if ($substrand && $substrand < 0) {
            $self->flip_strand();
            $self->strand(-1);
        }
    }
    my @segs = $self->sub_Segments;
    my $str = lc($type).'('.join(',', map {$_->to_string} @segs).')';
    if ($self->strand && $self->strand < 0) {
        $str = "complement($str)";
    }
    $str;
}

# could do all string parsing here instead of FTLocationFactory...
sub from_string {
    shift->throw_not_implemented;
}

with 'Biome::Role::Segment';

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__