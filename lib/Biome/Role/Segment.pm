package Biome::Role::Segment;

use 5.010;
use Biome::Role;

with 'Biome::Role::Rangeable';
use Biome::Types qw(LocationType LocationSymbol);

has 'seq_id' => (
	is => 'rw', 
	isa => 'Str', 
);

has 'start_pos_type'    => (
    isa             => LocationType,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    trigger         => sub {
        my ($self, $v) = @_;
        return unless $self->end && $self->start;
        $self->throw("Start position can't have type $v") if $v eq 'AFTER';
        if ($v eq 'IN-BETWEEN' && $self->valid_Segment && abs($self->end - $self->start) != 1 ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1");
        }
    }
);

has 'end_pos_type'      => (
    isa             => LocationType,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    trigger         => sub {
        my ($self, $v) = @_;
        return unless $self->end && $self->start;
        $self->throw("End position can't have type $v") if $v eq 'BEFORE';
        if ($v eq 'IN-BETWEEN' && $self->valid_Segment && abs($self->end - $self->start) != 1 ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         " cannot be larger than 1");
        }
    }
);

# this is for 'fuzzy' locations like WITHIN, BEFORE, AFTER
has [qw(start_offset end_offset)]  => (
    isa             => 'Int',
    is              => 'rw',
    lazy            => 1,
    default         => 0
);

## TODO: Should this be a delegated method dependent on the presence of a
## sequence ID? Not sure it belongs in Segment, probably should be relegated to
## the purview of a Feature.

has is_remote => (
    isa     => 'Bool',
    is      => 'rw',
    default => 0
);

around length => sub {
    my ($orig, $self) = @_;
    given ($self->segment_type) {
        when ([qw(EXACT WITHIN)]) {
            return $self->$orig
        }
        default {
            return 0
        }
    }
};

has 'start' => (
    isa         => 'Int',
    is          => 'rw',
    trigger     => sub {
        my ($self, $start) = @_;
        my $end = $self->end;
        return unless $start && $end;
        if ($self->start_pos_type eq 'IN-BETWEEN' &&
            (abs($end - $start) != 1 )) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1; got ".abs($end - $start));
    }
});

has 'end' => (
    isa         => 'Int',
    is          => 'rw',
    trigger     => sub {
        my ($self, $end) = @_;
        my $start = $self->start;
        return unless $start && $end;
        if ($self->end_pos_type eq 'IN-BETWEEN' &&
            (abs($end - $start) != 1) ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1; got ".abs($end - $start));
    }
});

my %IS_FUZZY = map {$_ => 1} qw(BEFORE AFTER WITHIN UNCERTAIN);

sub is_fuzzy {
    my $self = shift;
    (exists $IS_FUZZY{$self->start_pos_type} ||
        exists $IS_FUZZY{$self->end_pos_type}) ? 1 : 0;
}

sub valid_Segment {
    defined($_[0]->start) && defined($_[0]->end) ? 1 : 0;
}

sub to_FTstring {
    my ($self) = @_;
    if( $self->start == $self->end ) {
        return $self->start;
    }
    
    my %position;
    
    for my $pos (qw(start end)) {
        my ($pm, $min, $max) = ("${pos}_pos_type", "min_$pos", "max_$pos");
        given ($self->$pm) {
            when ('EXACT') {
                $position{$pos} .= $self->$pos;
            }
            when ('WITHIN') {
                $position{$pos} .= $self->$min.'.'.$self->$max;
            }
            when ('BETWEEN') {
                $position{$pos} .= $self->$min.'^'.$self->$max;
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
        return 'EXACT';  # this doesn't make sense to me, shouldn't it be 'UNCERTAIN'?
    }
    return 'UNCERTAIN';
}

sub flip_strand {
    my $self= shift;
    $self->strand($self->strand * -1);
}

no Biome::Role;

1;

__END__

=head2 segment_type

  Title   : segment_type
  Usage   : my $segment_type = $segment->segment_type();
  Function: Get segment type encoded as text
  Returns : string ('EXACT', 'WITHIN', 'IN-BETWEEN')
  Args    : none

=head2 start

  Title   : start
  Usage   : $start = $segment->start();
  Function: Get the start coordinate of this segment. In
            simple cases, this will return the same number as
            min_start() and max_start(), in more ambiguous cases like
            fuzzy segments the number may be equal to one or neither
            of both.
  Returns : A positive integer value.
  Args    : none

=head2 end

  Title   : end
  Usage   : $end = $segment->end();
  Function: Get the end coordinate of this segment as defined by the
            currently active coordinate computation policy. In simple
            cases, this will return the same number as min_end() and
            max_end(), in more ambiguous cases like fuzzy segments
            the number may be equal to one or neither of both.

            We override this here from Bio::RangeI in order to delegate
            'get' to a L<Bio::Location::CoordinatePolicy> implementing
            object. Implementing classes may also wish to provide
            'set' functionality, in which case they *must* override
            this method. The implementation provided here will throw
            an exception if called with arguments.

  Returns : A positive integer value.
  Args    : none

See L<Bio::Location::CoordinatePolicy> and L<Bio::RangeI> for more
information

=head2 strand

  Title   : strand
  Usage   : $strand = $loc->strand();
  Function: get/set the strand of this range
  Returns : the strandidness (-1, 0, +1)
  Args    : optionaly allows the strand to be set
          : using $loc->strand($strand)

=head2 to_FTstring

  Title   : to_FTstring
  Usage   : my $locstr = $segment->to_FTstring()
  Function: returns the FeatureTable string of this segment
  Returns : string
  Args    : none

=head2 valid_Segment

 Title   : valid_Segment
 Usage   : if ($segment->valid_Segment) {...};
 Function: boolean method to determine whether segment is considered valid
           (has minimum requirements for a specific Segment implementation)
 Returns : Boolean value: true if segment is valid, false otherwise
 Args    : none

=head2 is_remote

 Title   : is_remote
 Usage   : $is_remote_loc = $loc->is_remote()
 Function: Whether or not a segment is a remote segment.

           A segment is said to be remote if it is on a different
           'object' than the object which 'has' this
           segment. Typically, features on a sequence will sometimes
           have a remote segment, which means that the segment of
           the feature is on a different sequence than the one that is
           attached to the feature. In such a case, $loc->seq_id will
           be different from $feat->seq_id (usually they will be the
           same).

           While this may sound weird, it reflects the segment of the
           kind of AB18375:450-900 which can be found in GenBank/EMBL
           feature tables.

 Example : 
 Returns : TRUE if the segment is a remote segment, and FALSE otherwise
 Args    : 

=head2 flip_strand

  Title   : flip_strand
  Usage   : $segment->flip_strand();
  Function: Flip-flop a strand to the opposite
  Returns : None
  Args    : None

=head2 start_pos_type

  Title   : pos_type
  Usage   : my $start_pos_type = $segment->pos_type('start');
  Function: Get indicated position type encoded as text

            Known valid values are 'BEFORE' (<5..100), 'AFTER' (>5..100), 
            'EXACT' (5..100), 'WITHIN' ((5.10)..100), 'BETWEEN', (5^6), with
            their meaning best explained by their GenBank/EMBL segment string
            encoding in brackets.

  Returns : string ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none
  

=head2 end_pos_type

  Title   : pos_type
  Usage   : my $start_pos_type = $segment->pos_type('start');
  Function: Get indicated position type encoded as text

            Known valid values are 'BEFORE' (<5..100), 'AFTER' (>5..100), 
            'EXACT' (5..100), 'WITHIN' ((5.10)..100), 'BETWEEN', (5^6), with
            their meaning best explained by their GenBank/EMBL segment string
            encoding in brackets.

  Returns : string ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=head2 seq_id

  Title   : seq_id
  Usage   : my $seqid = $segment->seq_id();
  Function: Get/Set seq_id that segment refers to
  Returns : seq_id (a string)
  Args    : [optional] seq_id value to set
  
=cut
