package Biome::Role::Location;

use Biome::Role;

with 'Biome::Root::Range';


=head2 location_type

  Title   : location_type
  Usage   : my $location_type = $location->location_type();
  Function: Get location type encoded as text
  Returns : string ('EXACT', 'WITHIN', 'IN-BETWEEN')
  Args    : none

=cut

requires 'location_type';

=head2 start

  Title   : start
  Usage   : $start = $location->start();
  Function: Get the start coordinate of this location as defined by
            the currently active coordinate computation policy. In
            simple cases, this will return the same number as
            min_start() and max_start(), in more ambiguous cases like
            fuzzy locations the number may be equal to one or neither
            of both.

            We override this here from RangeI in order to delegate
            'get' to a L<Bio::Location::CoordinatePolicy> implementing
            object.  Implementing classes may also wish to provide
            'set' functionality, in which case they *must* override
            this method. The implementation provided here will throw
            an exception if called with arguments.

  Returns : A positive integer value.
  Args    : none

See L<Bio::Location::CoordinatePolicy> for more information

=cut

has 'start' => ( 
	is => 'ro', 
	default => sub { 
	    my ($self) = @_;	
		return $self->coordinate_policy->start($self);
	}
);

=head2 end

  Title   : end
  Usage   : $end = $location->end();
  Function: Get the end coordinate of this location as defined by the
            currently active coordinate computation policy. In simple
            cases, this will return the same number as min_end() and
            max_end(), in more ambiguous cases like fuzzy locations
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

=cut

has 'end' => ( 
	is => 'ro', 
	default => sub { 
	    my ($self) = @_;	
		return $self->coordinate_policy->end($self);
	}
);


=head2 min_start

  Title   : min_start
  Usage   : my $minstart = $location->min_start();
  Function: Get minimum starting point of feature.

            Note that an implementation must not call start() in this method.

  Returns : integer or undef if no minimum starting point.
  Args    : none

=cut

requires 'min_start';


=head2 max_start

  Title   : max_start
  Usage   : my $maxstart = $location->max_start();
  Function: Get maximum starting point of feature.

            Note that an implementation must not call start() in this method
            unless start() is overridden such as not to delegate to the
            coordinate computation policy object.

  Returns : integer or undef if no maximum starting point.
  Args    : none

=cut


requires 'max_start';


=head2 start_pos_type

  Title   : start_pos_type
  Usage   : my $start_pos_type = $location->start_pos_type();
  Function: Get start position type encoded as text

            Known valid values are 'BEFORE' (<5..100), 'AFTER' (>5..100), 
            'EXACT' (5..100), 'WITHIN' ((5.10)..100), 'BETWEEN', (5^6), with
            their meaning best explained by their GenBank/EMBL location string
            encoding in brackets.

  Returns : string ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=cut

requires 'start_pos_type';


=head2 flip_strand

  Title   : flip_strand
  Usage   : $location->flip_strand();
  Function: Flip-flop a strand to the opposite
  Returns : None
  Args    : None

=cut

has 'flip_strand' => ( 
	is => 'ro', 
	default => sub { 
		my ($self) = @_;
		$self->strand($self->strand * -1);
	},
);


=head2 min_end

  Title   : min_end
  Usage   : my $minend = $location->min_end();
  Function: Get minimum ending point of feature. 

            Note that an implementation must not call end() in this method
            unless end() is overridden such as not to delegate to the
            coordinate computation policy object.

  Returns : integer or undef if no minimum ending point.
  Args    : none

=cut

requires 'min_end';


=head2 max_end

  Title   : max_end
  Usage   : my $maxend = $location->max_end();
  Function: Get maximum ending point of feature.

            Note that an implementation must not call end() in this method
            unless end() is overridden such as not to delegate to the
            coordinate computation policy object.

  Returns : integer or undef if no maximum ending point.
  Args    : none

=cut

requires 'max_end';


=head2 end_pos_type

  Title   : end_pos_type
  Usage   : my $end_pos_type = $location->end_pos_type();
  Function: Get end position encoded as text.

            Known valid values are 'BEFORE' (5..<100), 'AFTER' (5..>100), 
            'EXACT' (5..100), 'WITHIN' (5..(90.100)), 'BETWEEN', (5^6), with
            their meaning best explained by their GenBank/EMBL location string
            encoding in brackets.

  Returns : string ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=cut

requires 'end_pos_type';


=head2 seq_id

  Title   : seq_id
  Usage   : my $seqid = $location->seq_id();
  Function: Get/Set seq_id that location refers to
  Returns : seq_id (a string)
  Args    : [optional] seq_id value to set

=cut

requires 'seq_id';


=head2 is_remote

 Title   : is_remote
 Usage   : $is_remote_loc = $loc->is_remote()
 Function: Whether or not a location is a remote location.

           A location is said to be remote if it is on a different
           'object' than the object which 'has' this
           location. Typically, features on a sequence will sometimes
           have a remote location, which means that the location of
           the feature is on a different sequence than the one that is
           attached to the feature. In such a case, $loc->seq_id will
           be different from $feat->seq_id (usually they will be the
           same).

           While this may sound weird, it reflects the location of the
           kind of AB18375:450-900 which can be found in GenBank/EMBL
           feature tables.

 Example : 
 Returns : TRUE if the location is a remote location, and FALSE otherwise
 Args    : 


=cut

requires 'is_remote';

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

requires 'coordinate_policy';

=head2 to_FTstring

  Title   : to_FTstring
  Usage   : my $locstr = $location->to_FTstring()
  Function: returns the FeatureTable string of this location
  Returns : string
  Args    : none

=cut

requires  'to_FTstring'; 

=head2 each_Location

 Title   : each_Location
 Usage   : @locations = $locObject->each_Location($order);
 Function: Conserved function call across Location:: modules - will
           return an array containing the component Location(s) in
           that object, regardless if the calling object is itself a
           single location or one containing sublocations.
 Returns : an array of Bio::LocationI implementing objects
 Args    : Optional sort order to be passed to sub_Location() for Splits

=cut

requires 'each_Location';


=head2 valid_Location

 Title   : valid_Location
 Usage   : if ($location->valid_location) {...};
 Function: boolean method to determine whether location is considered valid
           (has minimum requirements for a specific LocationI implementation)
 Returns : Boolean value: true if location is valid, false otherwise
 Args    : none

=cut

requires 'valid_Location';



no Biome::Role;

1;
