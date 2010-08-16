package Biome::Role::Location::Split;

use 5.010;
use Biome::Role;
use Biome::Type::Location qw(Split_Location_Type ArrayRef_of_Locatable);
use Biome::Type::Sequence qw(Maybe_Sequence_Strand);
use List::Util qw(reduce);
use namespace::clean -except => 'meta';

has     'locations'  => (
    is          => 'ro',
    isa         => ArrayRef_of_Locatable,
    traits      => ['Array'],
    init_arg    => undef,
    writer      => '_set_locations',
    handles     => {
        add_sub_Location      => 'push',
        sub_Locations         => 'elements',
        remove_sub_Locations  => 'clear',
        get_sub_Location      => 'get',
        num_sub_Locations     => 'count',
    },
    lazy        => 1,
    default     => sub { [] }
);

has     'location_type'    => (
    isa         => Split_Location_Type,
    is          => 'rw',
    lazy        => 1,
    default     => 'JOIN'
);

has     'resolve_Locations'      => (
    isa         => 'Bool',
    is          => 'rw',
    lazy        => 1,
    default     => 1,
);

sub length {
    my ($self) = @_;
    given ($self->location_type) {
        when ([qw(EXACT WITHIN)]) {
            return $self->end - $self->start + 1;
        }
        default {
            return 0
        }
    }
}

sub sub_Location_strand {
    my ($self) = @_;
    my ($strand, $lstrand);
    
    # this could use reduce()
    foreach my $loc ($self->sub_Locations()) {
        $lstrand = $loc->strand();
        if((! $lstrand) ||
           ($strand && ($strand != $lstrand)) ||
           $loc->is_remote()) {
            $strand = undef;
            last;
        } elsif(! $strand) {
            $strand = $lstrand;
        }
    }
    return $strand;
}

# overrides 

has     'strand'      => (
    isa         => Maybe_Sequence_Strand,
    is          => 'rw',
    lazy        => 1,
    predicate   => 'has_strand',
    default     => sub {
        my $self = shift;
        return $self->sub_Location_strand;
        },
);

sub start {
    my $self = shift;
    return $self->get_sub_Location(0)->start if $self->is_remote;
    return $self->_reduce('start');
}

sub end {
    my $self = shift;
    return $self->get_sub_Location(0)->end if $self->is_remote;
    return $self->_reduce('end');
}

sub is_remote {
    my $self = shift;
    for my $seg ($self->sub_Locations) {
        return 1 if $seg->is_remote;
    }
    0;
}

sub min_start {
    my $self = shift;
    return $self->get_sub_Location(0)->min_start if $self->is_remote;
    return $self->_reduce('min_start');
}

sub max_start {
    my $self = shift;
    return $self->get_sub_Location(0)->max_start if $self->is_remote;
    return $self->_reduce('max_start');
}

sub min_end {
    my $self = shift;
    return $self->get_sub_Location(0)->min_end if $self->is_remote;
    return $self->_reduce('min_end');
}

sub max_end {
    my $self = shift;
    return $self->get_sub_Location(0)->max_end if $self->is_remote;
    return $self->_reduce('max_end');
}

sub start_pos_type {
    my $self = shift;
    my $type = reduce {$a eq $b ? $a : undef}
        map {$_->start_pos_type} $self->sub_Locations;
    return $type;
}

sub end_pos_type {
    my $self = shift;
    my $type = reduce {$a eq $b ? $a : undef} 
        map {$_->end_pos_type} $self->sub_Locations;
    return $type;
}

sub valid_Location {
    # TODO: add tests
    my $self = shift;
    my $type = reduce {$a eq $b ? 1 : 0} 
        map {$_->valid_Location} $self->sub_Locations;
}

sub is_fuzzy {
    # TODO: add tests
    my $self = shift;
    my $type = reduce {$a eq $b ? 1 : 0} 
        map {$_->is_fuzzy} $self->sub_Locations;
}

# no offsets for splits?  Or maybe for only the first/last one?
sub start_offset { 0 }
sub end_offset { 0 }

# helper, just grabs the indicated value for the contained locations
sub _reduce {
    my ($self, $caller) = @_;
    my @segs = sort {
        $a->$caller <=> $b->$caller
                     }
    grep {$_->$caller} $self->sub_Locations;
    return unless @segs == $self->num_sub_Locations;
    $caller =~ /start/ ? return $segs[0]->$caller : return $segs[-1]->$caller;
}

sub flip_strand {
    my $self = shift;
    my @segs = @{$self->locations()};
    @segs = map {$_->flip_strand(); $_} reverse @segs;
    $self->_set_locations(\@segs);
}

sub to_string {
    my $self = shift;
    # JOIN assumes specific order, ORDER does not, BOND ?
    my $type = $self->location_type;
    if ($self->resolve_Locations) {
        my $substrand = $self->sub_Location_strand;
        if ($substrand && $substrand < 0) {
            $self->flip_strand();
            $self->strand(-1);
        }
    }
    my @segs = $self->sub_Locations;
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

1;

