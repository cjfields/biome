# Let the code begin...

package Biome::Segment::Simple;

use Biome;
use 5.010;

# import this in to use to_LocationType and to_LocationSymbol coersion if needed
use Biome::Types qw(LocationType LocationSymbol);

with 'Biome::Role::Segment';

sub BUILD {
    my ($self, $params) = @_;
    
    # correct for reversed location coordinates
    # (this should prob. be an exception upon instance creation, but we try to
    # DTRT for now)
    if ($params->{start} && $params->{end} && ($params->{end} < $params->{start})) {
        $self->warn('End is greater than start; flipping strands');
        $self->end($params->{start});
        $self->start($params->{end});
        $self->strand($self->strand * -1);
    }
    
    $params->{segment_type} && $self->segment_type($params->{segment_type});
}

# override Rangeable::length
sub length {
    my $self = shift;
    given ($self->segment_type) {
        when ([qw(EXACT WITHIN)]) {
            my ($st, $end) = ($self->start, $self->end);
            return ($st == 0 && $end == 0) ? 0 : abs($end - $st + 1);
        }
        default {
            return 0
        }
    }
}

sub flip_strand {
    my $self= shift;
    # TODO: this should either handle symbols, or symbols should be coerced
    $self->strand($self->strand * -1);
}

# indicates how segment range should be generally interpreted for
sub segment_type {
    my ($self, $val) = @_;
    if ($val) {
        $self->start_pos_type($val);
        $self->end_pos_type($val);
        return $val;
    }
    my ($ps, $pe) = ($self->start_pos_type, $self->end_pos_type);
    
    # this is currently derived off the start/end_pos_type and is not a separate
    # attribute (e.g. not settable), though it will likely change to delegate
    # to the proper methods
    return $ps if ($ps eq $pe);  # WITHIN BETWEEN
    if ($ps eq 'BEFORE' || $pe eq 'AFTER') {
        return 'EXACT';
    }
    return 'UNCERTAIN';
}

sub to_FTstring {
    my ($self) = @_;
    if( $self->start == $self->end ) {
        return $self->start;
    }
    
    my %position;
    
    for my $pos (qw(start end)) {
        # TODO: min/max will probably be replaced by calls to start/end with a
        # proper coordinate policy
        my ($pm, $min, $max) = ("${pos}_pos_type", "min_$pos", "max_$pos");
        given ($self->$pm) {
            when ('EXACT') {
                $position{$pos} .= $self->$pos;
            }
            when ('WITHIN') {
                $position{$pos} .= $self->$min.'.'.$self->$max;
            }
            when ('BEFORE') {
                $position{$pos} .= '<'.$self->$pos;
            }
            when ('AFTER') {
                $position{$pos} .= $self->$pos.'>';
            }
            when ('UNCERTAIN') {
                $position{$pos} .= '?'.$self->$pos;
            }
            default {
                $position{$pos} .= $self->$pos;
            }
        }
    }
    
    my $str = $position{start}.
            to_LocationSymbol($self->segment_type).
            $position{end};
     
    if ($self->strand == -1) {
        $str = sprintf("complement(%s)",$str)
    }
    $str;
}

sub pos_string {
    my ($self, $pos) = @_;
    $pos ||= '';
    if (!defined $pos || ($pos ne 'start' && $pos ne 'end')) {
        $self->throw("Must specify a position type: got [$pos]");
    }
    
    # TODO: min/max will probably be replaced by calls to start/end with a
    # proper coordinate policy
    my ($pm, $min, $max) = ("${pos}_pos_type", "min_$pos", "max_$pos");
    given ($self->$pm) {
        when ('EXACT') {
            return $self->$pos;
        }
        when ('WITHIN') {
            return $self->$min.'.'.$self->$max;
        }
        when ('BEFORE') {
            return '<'.$self->$pos;
        }
        when ('AFTER') {
            return $self->$pos.'>';
        }
        when ('UNCERTAIN') {
            return '?'.$self->$pos;
        }
        default {
            return $self->$pos;
        }
    }
}

sub valid_Segment {
    defined($_[0]->start) && defined($_[0]->end) ? 1 : 0;
}

sub all_Segments { return $_[0]; }

sub is_fuzzy {
    my $self = shift;
    if ($self->start_pos_type ne 'EXACT' && $self->end_pos_type ne 'EXACT') {
        return 0;
    }
    return 1;
}

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__
