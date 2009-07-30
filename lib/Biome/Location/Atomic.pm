
# Let the code begin...


package Biome::Location::Atomic;
use Biome;
use Biome::Location::WidestCoordPolicy;
use Biome::Types qw/SequenceStrand Int Str CoordinatePolicy/;

with 'Biome::Role::LocationI';


sub new { 
    my ($class, @args) = @_;
    my $self = {};
    # This is for the case when we've done something like this
    # get a 2 features from somewhere (like Bio::Tools::GFF)
    # Do
    # my $location = $f1->location->union($f2->location);
    # We get an error without the following code which 
    # explictly loads the Bio::Location::Simple class
    eval {
	($class) = ref($class) if ref($class);
	Bio::Root::Root->_load_module($class);
      };
    if ( $@ ) {
	Bio::Root::Root->throw("$class cannot be found\nException $@");
      }
    bless $self,$class;

    my ($v,$start,$end,$strand,$seqid) = $self->_rearrange([qw(VERBOSE
							       START
							       END
							       STRAND
							       SEQ_ID)],@args);
    defined $v && $self->verbose($v);
    defined $strand && $self->strand($strand);

    defined $start  && $self->start($start);
    defined $end    && $self->end($end);
    if( defined $self->start && defined $self->end &&
	$self->start > $self->end && $self->strand != -1 ) {
	$self->warn("When building a location, start ($start) is expected to be less than end ($end), ".
		    "however it was not. Switching start and end and setting strand to -1");

	$self->strand(-1);
	my $e = $self->end;
	my $s = $self->start;
	$self->start($e);
	$self->end($s);
    }
    $seqid          && $self->seq_id($seqid);

    return $self;
}

=head2 start

  Title   : start
  Usage   : $start = $loc->start();
  Function: get/set the start of this range
  Returns : the start of this range
  Args    : optionaly allows the start to be set
          : using $loc->start($start)

=cut

has [qw/start end/] => ( 
	is => 'rw', 
	isa => 'Int', 
);

after 'start' => sub {
  my ($self,  $value ) = @_;	
  $self->min_start($value) ;
}

=head2 end

  Title   : end
  Usage   : $end = $loc->end();
  Function: get/set the end of this range
  Returns : the end of this range
  Args    : optionaly allows the end to be set
          : using $loc->end($start)

=cut

after 'end' => sub {
  my ($self,  $value ) = @_;	
  $self->min_end($value) ;
}

=head2 strand

  Title   : strand
  Usage   : $strand = $loc->strand();
  Function: get/set the strand of this range
  Returns : the strandidness (-1, 0, +1)
  Args    : optionaly allows the strand to be set
          : using $loc->strand($strand)

=cut

has 'strand' => ( 
	is => 'rw', 
	isa => SequenceStrand, 
);

=head2 seq_id

  Title   : seq_id
  Usage   : my $seqid = $location->seq_id();
  Function: Get/Set seq_id that location refers to
  Returns : seq_id (a string)
  Args    : [optional] seq_id value to set

=cut

has 'seq_id' => ( 
	is => 'rw', 
	isa => Str, 
);

=head2 length

 Title   : length
 Usage   : $len = $loc->length();
 Function: get the length in the coordinate space this location spans
 Example :
 Returns : an integer
 Args    : none


=cut

has 'length' => (
   is => 'ro', 
   default => sub {  
   		my ($self) = @_; 
   		return abs($self->end() - $self->start()) + 1;
	}, 
);

=head2 min_start

  Title   : min_start
  Usage   : my $minstart = $location->min_start();
  Function: Get minimum starting location of feature startpoint   
  Returns : integer or undef if no minimum starting point.
  Args    : none

=cut

=head2 max_start

  Title   : max_start
  Usage   : my $maxstart = $location->max_start();
  Function: Get maximum starting location of feature startpoint.

            In this implementation this is exactly the same as min_start().

  Returns : integer or undef if no maximum starting point.
  Args    : none

=cut

=head2 min_end

  Title   : min_end
  Usage   : my $minend = $location->min_end();
  Function: Get minimum ending location of feature endpoint 
  Returns : integer or undef if no minimum ending point.
  Args    : none

=cut

=head2 max_end

  Title   : max_end
  Usage   : my $maxend = $location->max_end();
  Function: Get maximum ending location of feature endpoint 

            In this implementation this is exactly the same as min_end().

  Returns : integer or undef if no maximum ending point.
  Args    : none

=cut

has [qw /min_start max_start min_end max_end/] => (
	is => 'rw', 
	isa => Int, 
);


=head2 start_pos_type

  Title   : start_pos_type
  Usage   : my $start_pos_type = $location->start_pos_type();
  Function: Get start position type (ie <,>, ^).

            In this implementation this will always be 'EXACT'.

  Returns : type of position coded as text 
            ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=cut

=head2 end_pos_type

  Title   : end_pos_type
  Usage   : my $end_pos_type = $location->end_pos_type();
  Function: Get end position type (ie <,>, ^) 

            In this implementation this will always be 'EXACT'.

  Returns : type of position coded as text 
            ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=cut

=head2 location_type

  Title   : location_type
  Usage   : my $location_type = $location->location_type();
  Function: Get location type encoded as text
  Returns : string ('EXACT', 'WITHIN', 'IN-BETWEEN')
  Args    : none

=cut

has [qw /start_pos_type end_pos_type location_type/]  => (
	is => 'ro', 
	default => 'EXACT', 
);


=head2 is_remote

 Title   : is_remote
 Usage   : $self->is_remote($newval)
 Function: Getset for is_remote value
 Returns : value of is_remote
 Args    : newvalue (optional)


=cut

sub is_remote {
   my $self = shift;
   if( @_ ) {
       my $value = shift;
       $self->{'is_remote'} = $value;
   }
   return $self->{'is_remote'};

}

=head2 each_Location

 Title   : each_Location
 Usage   : @locations = $locObject->each_Location($order);
 Function: Conserved function call across Location:: modules - will
           return an array containing the component Location(s) in
           that object, regardless if the calling object is itself a
           single location or one containing sublocations.
 Returns : an array of Bio::LocationI implementing objects - for
           Simple locations, the return value is just itself.
 Args    : 

=cut

sub each_Location {
   my ($self) = @_;
   return ($self);
}

=head2 to_FTstring

  Title   : to_FTstring
  Usage   : my $locstr = $location->to_FTstring()
  Function: returns the FeatureTable string of this location
  Returns : string
  Args    : none

=cut

has 'to_FTstring'  => (
	is => 'ro', 
	default => sub { 
    	my($self) = @_;
    	if( $self->start == $self->end ) {
			return $self->start;
    	}
    	my $str = $self->start . ".." . $self->end;
    	if( $self->strand == -1 ) {
			$str = sprintf("complement(%s)", $str);
    	}
    	return $str;
	}
);

=head2 valid_Location

 Title   : valid_Location
 Usage   : if ($location->valid_location) {...};
 Function: boolean method to determine whether location is considered valid
           (has minimum requirements for Simple implementation)
 Returns : Boolean value: true if location is valid, false otherwise
 Args    : none

=cut

has 'valid_Location' => (
	is => 'ro', 
	default => sub { 
		my ($self) = @_;
    	return 1 if $self->start && $self->end;
    	return 0;
	},
);

=head2 coordinate_policy

  Title   : coordinate_policy
  Usage   : $policy = $location->coordinate_policy();
            $location->coordinate_policy($mypolicy); # set may not be possible
  Function: Get the coordinate computing policy employed by this object.

            See L<Bio::Location::CoordinatePolicyI> for documentation
            about the policy object and its use.

            The interface *does not* require implementing classes to
            accept setting of a different policy. The implementation
            provided here does, however, allow to do so.

            Implementors of this interface are expected to initialize
            every new instance with a
            L<Bio::Location::CoordinatePolicyI> object. The
            implementation provided here will return a default policy
            object if none has been set yet. To change this default
            policy object call this method as a class method with an
            appropriate argument. Note that in this case only
            subsequently created Location objects will be affected.

  Returns : A L<Bio::Location::CoordinatePolicyI> implementing object.
  Args    : On set, a L<Bio::Location::CoordinatePolicyI> implementing object.

See L<Bio::Location::CoordinatePolicyI> for more information


=cut

# have to make a type out of it probably by coercion which checks for roles
has 'coordinate_policy' => (
	is => 'rw', 
	isa => 'CoordinatePolicy', 
	default => sub { Biome::Location::WidestCoordinatePolicy->new() }, 
);

=head2 trunc

  Title   : trunc
	Usage   : $trunc_location = $location->trunc($start, $end, $relative_ori);
	Function: To truncate a location and keep annotations and features
	          within the truncated segment intact.

						This might do things differently where the truncation
						splits the location in half.
	CAVEAT  : As yet, this is an untested and unannounced method. Use
	          with caution!
	Returns : A L<Bio::Location::Atomic> object.
	Args    : The start and end position for the trunction, and the relative
	          orientation.

=cut

sub trunc {
  my ($self,$start,$end,$relative_ori) = @_;

  my $newstart  = $self->start - $start+1;
  my $newend    = $self->end   - $start+1;
  my $newstrand = $relative_ori * $self->strand;

  my $out;
  if( $newstart < 1 || $newend > ($end-$start+1) ) {
    $out = Biome::Location::Atomic->new();
    $out->start($self->start);
    $out->end($self->end);
    $out->strand($self->strand);
    $out->seq_id($self->seqid);
    $out->is_remote(1);
  } else {
    $out = Biome::Location::Atomic->new();
    $out->start($newstart);
    $out->end($newend);
    $out->strand($newstrand);
    $out->seq_id();
  }

  return $out;
}

1;

=head1 NAME

Bio::Location::Atomic - Implementation of a Atomic Location on a Sequence

=head1 SYNOPSIS

    use Bio::Location::Atomic;

    my $location = Bio::Location::Atomic->new(-start => 1, -end => 100,
					     -strand => 1 );

    if( $location->strand == -1 ) {
	printf "complement(%d..%d)\n", $location->start, $location->end;
    } else {
	printf "%d..%d\n", $location->start, $location->end;
    }

=head1 DESCRIPTION

This is an implementation of Bio::LocationI to manage simple location
information on a Sequence.

=head1 FEEDBACK

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and 
reponsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Jason Stajich

Email jason-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut
