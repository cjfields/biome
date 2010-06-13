package Biome::Role::Segment;

use 5.010;
use Biome::Role;

with 'Biome::Role::Range';

requires qw(
    start_pos_type
    end_pos_type
    start_offset
    end_offset
    min_start
    min_end
    max_start
    max_end
    flip_strand
    
    segment_type
    valid_Segment
    
    is_fuzzy
    to_string
    from_string
    is_remote
    
    sub_Segments
);

has 'seq_id' => (
    is              => 'rw', 
    isa             => 'Str',
);

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
