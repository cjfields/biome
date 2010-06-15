package Biome::Role::Segment;

use 5.010;
use Biome::Role;
use namespace::clean -except => 'meta';

use Biome::Type::Sequence qw(Sequence_Strand);

use Biome::Type::Segment qw(Segment_Type Segment_Symbol
    Segment_Pos_Type Segment_Pos_Symbol);

has 'strand'  => (
    isa     => Sequence_Strand,
    is      => 'rw',
    default => 0,
    coerce  => 1
);

has 'start' => (
    isa         => 'Int',
    is          => 'rw',
    default     => 0,
    trigger     => sub {
        my ($self, $start) = @_;
        my $end = $self->end;
        return unless $start && $end;
        # could put start<->end reversal here...
        if ($self->segment_type eq 'IN-BETWEEN' &&
            (abs($end - $start) != 1 )) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1; got ".abs($end - $start));
    }
});

has 'end' => (
    isa         => 'Int',
    is          => 'rw',
    default     => 0,
    trigger     => sub {
        my ($self, $end) = @_;
        my $start = $self->start;
        return unless $start && $end;
        # could put start<->end reversal here...
        if ($self->segment_type eq 'IN-BETWEEN' &&
            (abs($end - $start) != 1) ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1; got ".abs($end - $start));
    }
});

sub length {
    my ($self) = @_;
    given ($self->segment_type) {
        when ([qw(EXACT WITHIN)]) {
            return $self->end - $self->start + 1;
        }
        default {
            return 0
        }
    }
}

sub sub_Segments { }

has 'seq_id' => (
    is              => 'rw', 
    isa             => 'Str',
);

has 'start_pos_type'    => (
    isa             => Segment_Pos_Type,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    predicate       => 'has_start_pos_type',
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
    isa             => Segment_Pos_Type,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    predicate       => 'has_end_pos_type',
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

has 'segment_type'  => (
    isa         => Segment_Type,
    is          => 'rw',
    lazy        => 1,
    default     => 'EXACT',
    coerce      => 1
);

has 'is_remote' => (
    is              => 'rw', 
    isa             => 'Bool',
    default         => 0
);

my %IS_FUZZY = map {$_ => 1} qw(BEFORE AFTER WITHIN UNCERTAIN);

# these just delegate to start, end, using the indicated offsets

sub max_start {
    my ($self) = @_;
    my $start = $self->start;
    return unless $start;
    ($start + $self->start_offset);
}

sub min_start {
    my ($self) = @_;
    my $start = $self->start;
    return if !$start || ($self->start_pos_type eq 'BEFORE');
    $start;
}

sub max_end {
    my ($self) = @_;
    my $end = $self->end;
    return if !$end || ($self->end_pos_type eq 'AFTER');
    return ($end + $self->end_offset);
}

sub min_end {
    my ($self) = @_;
    my $end = $self->end;
    return unless $end;
}

sub is_fuzzy {
    my $self = shift;
    (exists $IS_FUZZY{$self->start_pos_type} ||
        exists $IS_FUZZY{$self->end_pos_type}) ? 1 : 0;
}

sub valid_Segment {
    defined($_[0]->start) && defined($_[0]->end) ? 1 : 0;
}

sub to_string {
    my ($self) = @_;
    
    my %data;
    for (qw(
        start end
        min_start max_start
        min_end max_end
        start_offset end_offset
        start_pos_type end_pos_type
        is_remote
        seq_id
        segment_type)) {
        $data{$_} = $self->$_;
    }
    
    for my $pos (qw(start end)) {
        my $pos_str = $data{$pos} || '';
        if ($pos eq 'end' && $data{start} == $data{end}) {
            $pos_str = '';
        }
        given ($data{"${pos}_pos_type"}) {
            when ('WITHIN') {
                $pos_str = '('.$data{"min_$pos"}.'.'.$data{"max_$pos"}.')';
            }
            when ('BEFORE') {
                $pos_str = '<'.$pos_str;
            }
            when ('AFTER') {
                $pos_str = '>'.$pos_str;
            }
            when ('UNCERTAIN') {
                $pos_str = '?'.$pos_str;
            }
        }
        $data{"${pos}_string"} = $pos_str;
    }
    
    my $str = $data{start_string}. ($data{end_string} ? 
            to_Segment_Symbol($data{segment_type}).
            $data{end_string} : '');
    $str = "$data{seq_id}:$str" if $data{seq_id} && $data{is_remote};
    $str = "($str)" if $data{segment_type} eq 'WITHIN';
    if ($self->strand == -1) {
        $str = sprintf("complement(%s)",$str)
    }
    $str;
}

{
my @STRING_ORDER = qw(start loc_type end);

sub from_string {
    my ($self, $string) = @_;
    return unless $string;
    if ($string =~ /(?:join|order|bond)/) {
        $self->throw("Passing a split segment type: $string");
    }
    my %atts;
    if ($string =~ /^complement\(([^\)]+)\)$/) {
        $atts{strand} = -1;
        $string = $1;
    } else {
        $atts{strand} = 1; # though, this assumes nucleotide sequence...
    }
    my @loc_data = split(/(\.{2}|\^|\:)/, $string);
    
    # SeqID
    if (@loc_data == 5) {
        $atts{seq_id} = shift @loc_data;
        $atts{is_remote} = 1;
        shift @loc_data; # get rid of ':'
    }
    for my $i (0..$#loc_data) {
        my $order = $STRING_ORDER[$i];
        my $str = $loc_data[$i];
        if ($order eq 'start' || $order eq 'end') {
            $str =~ s{[\[\]\(\)]+}{}g;
            if ($str =~ /^([<>\?])?(\d+)?$/) {
                $atts{"${order}_pos_type"} = $1 if $1;
                $atts{$order} = $2;
            } elsif ($str =~ /^(\d+)\.(\d+)$/) {
                $atts{"${order}_pos_type"} = '.';
                $atts{$order} = $1;
                $atts{"${order}_offset"} = $2 - $1;
            } else {
                $self->throw("Can't parse location string: $str");
            }
        } else {
            $atts{segment_type} = $str;
        }
    }
    if ($atts{start_pos_type} && $atts{start_pos_type} eq '.' &&
        (!$atts{end} && !$atts{end_pos_type})
        ) {
        $atts{end} = $atts{start} + $atts{start_offset};
        delete @atts{qw(start_offset start_pos_type end_pos_type)};
        $atts{segment_type} = '.';
    }
    $atts{end} ||= $atts{start} unless $atts{end_pos_type};
    for my $m (sort keys %atts) {
        if (defined $atts{$m}){
            $self->$m($atts{$m}) 
        }
    }
}

}

sub flip_strand {
    my $self= shift;
    $self->strand($self->strand * -1);
}

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
