# Let the code begin...

package Biome::Location::Simple;
use Biome;
use Biome::Location::WidestCoordPolicy;
use Biome::Types qw/SequenceStrand CoordinatePolicy SimpleLocationType/;

=head2 start

  Title   : start
  Usage   : $start = $loc->start();
  Function: get/set the start of this range
  Returns : the start of this range
  Args    : optionaly allows the start to be set
          : using $loc->start($start)

=cut

sub BUILD {
    my $self = shift;
    if ( $self->has_start && $self->has_end && $self->has_location_type ) {
        $self->throw( "Only adjacent residues when location type "
              . "is IN-BETWEEN. Not ["
              . $self->start
              . "] and ["
              . $self->end
              . "]" )
          if $self->location_type eq 'IN-BETWEEN'
          && ( $self->end() - 1 != $self->start );
    }

}

has 'start' => (
    is        => 'rw',
    isa       => 'Int',
    predicate => 'has_start',
);

after 'start' => sub {
    my ( $self, $value ) = @_;
    return if !$value;
    $self->max_start($value);
    $self->min_start($value);
};

before 'start' => sub {
    my ( $self, $value ) = @_;
    return if !$value;
    $self->throw( "Only adjacent residues when location type "
          . "is IN-BETWEEN. Not ["
          . $value
          . "] and ["
          . $self->end
          . "]" )
      if $self->has_location_type
      && $self->location_type eq 'IN-BETWEEN'
      && $self->has_end()
      && ( $self->end() - 1 != $value );
};

#around 'start' => sub {
#    my ( $orig, $self, $value ) = @_;
#    return $self->$orig if !$value;
#    $self->throw( "Only adjacent residues when location type "
#          . "is IN-BETWEEN. Not ["
#          . $value
#          . "] and ["
#          . $self->start
#          . "]" )
#      if $self->has_location_type
#      && $self->location_type eq 'IN-BETWEEN'
#      && $self->has_end()
#      && ( $self->end() - 1 != $value );
#
#    return $self->$orig($value);
#};

=head2 end

  Title   : end
  Usage   : $end = $loc->end();
  Function: get/set the end of this range
  Returns : the end of this range
  Args    : optionaly allows the end to be set
          : using $loc->end($start)
  Note    : If start is set but end is undefined, this now assumes that start
		    is the same as end but throws a warning (i.e. it assumes this is
			a possible error). If start is undefined, this now throws an
			exception.

=cut

has 'end' => (
    is        => 'rw',
    isa       => 'Int',
    builder   => '_build_end',
    predicate => 'has_end',
    lazy      => 1,
);

sub _build_end {
    my ($self) = @_;

    #assume end is the same as start if not defined
    if ( !$self->has_end ) {
        if ( !$self->has_start ) {
            $self->warn('Calling end without a defined start position');
            return;
        }
        $self->warn('Setting start equal to end');
        return $self->start;
    }

}

after 'end' => sub {
    my ( $self, $value ) = @_;
    return if !$value;
    $self->max_end($value);
    $self->min_end($value);
};

before 'end' => sub {
    my ( $self, $value ) = @_;
    return if !$value;
    $self->throw( "Only adjacent residues when location type "
          . "is IN-BETWEEN. Not ["
          . $self->start()
          . "] and ["
          . $value
          . "]" )
      if $self->has_location_type
      && $self->location_type eq 'IN-BETWEEN'
      && $self->has_start()
      && ( ( $value - 1 ) != $self->start() );
};

#around 'end' => sub {
#    my ( $orig, $self, $value ) = @_;
#    return $self->$orig if !$value;
#    $self->throw( "Only adjacent residues when location type "
#          . "is IN-BETWEEN. Not ["
#          . $self->start()
#          . "] and ["
#          . $value
#          . "]" )
#      if $self->has_location_type
#      && $self->location_type eq 'IN-BETWEEN'
#      && $self->has_start()
#      && ( ( $value - 1 ) != $self->start() );
#
#    return $self->$orig($value);
#};

=head2 strand

  Title   : strand
  Usage   : $strand = $loc->strand();
  Function: get/set the strand of this range
  Returns : the strandedness (-1, 0, +1)
  Args    : optionaly allows the strand to be set
          : using $loc->strand($strand)

=cut

has 'strand' => (
    is        => 'rw',
    predicate => 'has_strand',
    isa       => SequenceStrand,
);

around 'strand' => sub {
    my ( $orig, $self ) = @_;
    if ( !$self->has_start() || !$self->has_end() ) {
        return;
    }
    my $start = $self->start();
    my $end   = $self->end();
    if ( $start > $end ) {
        $self->warn(
"When building a location, start ($start) is expected to be less than end ($end), "
              . "however it was not. Switching start and end and setting strand to -1"
        );
        $self->$orig(-1);
    }
};

=head2 flip_strand

  Title   : flip_strand
  Usage   : $location->flip_strand();
  Function: Flip-flop a strand to the opposite
  Returns : None
  Args    : None

=cut

sub flip_strand {
    my ($self) = @_;
    if ( $self->has_strand() ) {
        $self->strand( $self->strand * -1 );
    }
}

=head2 length

 Title   : length
 Usage   : $len = $loc->length();
 Function: get the length in the coordinate space this location spans
 Example :
 Returns : an integer
 Args    : none

=cut

sub length {
    my ($self) = @_;
    if ( $self->location_type() eq 'IN-BETWEEN' ) {
        return 0;
    }
    else {
        return abs( $self->end() - $self->start() ) + 1;
    }

}

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
    is  => 'rw',
    isa => 'Int',
);

=head2 start_pos_type

  Title   : start_pos_type
  Usage   : my $start_pos_type = $location->start_pos_type();
  Function: Get start position type (ie <,>, ^).

  Returns : type of position coded as text
            ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=cut

=head2 end_pos_type

  Title   : end_pos_type
  Usage   : my $end_pos_type = $location->end_pos_type();
  Function: Get end position type (ie <,>, ^)

  Returns : type of position coded as text
            ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=cut

has [qw /start_pos_type end_pos_type/] => (
    is      => 'ro',
    isa     => 'Str',
    default => 'EXACT',
);

=head2 location_type

  Title   : location_type
  Usage   : my $location_type = $location->location_type();
  Function: Get location type encoded as text
  Returns : string ('EXACT' or 'IN-BETWEEN')
  Args    : 'EXACT' or '..' or 'IN-BETWEEN' or '^'

=cut

has 'location_type' => (
    is        => 'rw',
    isa       => SimpleLocationType,
    predicate => 'has_location_type',
    default   => 'EXACT',
    lazy      => 1,
);

before 'location_type' => sub {
    my ( $self, $value ) = @_;
    return if !$value;

    $self->throw( "Only adjacent residues when location type "
          . "is IN-BETWEEN. Not ["
          . $self->start()
          . "] and ["
          . $self->end()
          . "]" )
      if $value eq 'IN-BETWEEN'
      && $self->has_start()
      && $self->has_end()
      && ( $self->end() - 1 != $self->start() );

    return if !$self->has_encoding();
    my %range_encode = (
        '..'         => 'EXACT',
        '^'          => 'IN-BETWEEN',
        'EXACT'      => '..',
        'IN-BETWEEN' => '^'
    );
    $self->encode(%range_encode);
};

around 'location_type' => sub {
    my ( $orig, $self, $value ) = @_;
    if ( !$value ) {
        return $self->$orig();
    }

    #if ( $self->has_end ) {
    #    print 'end: ', $self->end, "\n";
    #}
    #$self->throw( "Only adjacent residues when location type "
    #      . "is IN-BETWEEN. Not ["
    #      . $self->start()
    #      . "] and ["
    #      . $self->end()
    #      . "]" )
    #  if $value eq 'IN-BETWEEN'
    #  && $self->has_start()
    #  && $self->has_end()
    #  && ( $self->end() - 1 != $self->start() );
    if ( $value eq '^' || $value eq '..' ) {
        $value = $self->decode($value);
    }
    return $self->$orig($value);
};

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

sub _build_each_Location {
    my ($self) = @_;
    return ($self);
}

=head2 is_remote

 Title   : is_remote
 Usage   : $self->is_remote($newval)
 Function: Getset for is_remote value
 Returns : value of is_remote
 Args    : newvalue (optional)


=cut

=head2 to_FTstring

  Title   : to_FTstring
  Usage   : my $locstr = $location->to_FTstring()
  Function: returns the FeatureTable string of this location
  Returns : string
  Args    : none

=cut

sub _build_FTstring {
    my ($self) = @_;

    my $str;
    if ( $self->start == $self->end ) {
        $str = $self->start;
    }
    else {
        $str = $self->start . $self->location_type . $self->end;
    }
    if ( $self->is_remote() && $self->seq_id() ) {
        $str = $self->seq_id() . ":" . $str;
    }
    if ( defined $self->strand
        && $self->strand == -1 )
    {
        $str = "complement(" . $str . ")";
    }
    return $str;
}

=head2 valid_Location

 Title   : valid_Location
 Usage   : if ($location->valid_location) {...};
 Function: boolean method to determine whether location is considered valid
           (has minimum requirements for Simple implementation)
 Returns : Boolean value: true if location is valid, false otherwise
 Args    : none

=cut

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

has 'coordinate_policy' => (
    is      => 'rw',
    isa     => CoordinatePolicy,
    default => sub { Biome::Location::WidestCoordPolicy->new() },
);

has 'rangeencode' => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef[Str]',
    default => sub { {} },
    handles => {
        decode         => 'get',
        encode         => 'set',
        get_encoding   => 'exists',
        has_encoding   => 'count',
        encoding_types => 'keys',

    },
);

# comments, not function added by jason
#
# trunc is untested, and as of now unannounced method for truncating a
# location.  This is to eventually be part of the procedure to
# truncate a sequence with annotatioin and properly remap the location
# of all the features contained within the truncated segment.

# presumably this might do things a little differently for the case
# where the truncation splits the location in half
#
# in short- you probably don't want to use  this method.

sub trunc {
    my ( $self, $start, $end, $relative_ori ) = @_;
    my $newstart  = $self->start - $start + 1;
    my $newend    = $self->end - $start + 1;
    my $newstrand = $relative_ori * $self->strand;

    my $out;
    if ( $newstart < 1 || $newend > ( $end - $start + 1 ) ) {
        $out = Bio::Location::Simple->new();
        $out->start( $self->start );
        $out->end( $self->end );
        $out->strand( $self->strand );
        $out->seq_id( $self->seqid );
        $out->is_remote(1);
    }
    else {
        $out = Bio::Location::Simple->new();
        $out->start($newstart);
        $out->end($newend);
        $out->strand($newstrand);
        $out->seq_id();
    }

    return $out;
}

with 'Biome::Role::Location';

no Biome;

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Bio::Location::Simple - Implementation of a Simple Location on a Sequence

=head1 SYNOPSIS

    use Bio::Location::Simple;

    my $location = Bio::Location::Simple->new(-start => 1, -end => 100,
                         -strand => 1 );

    if( $location->strand == -1 ) {
    printf "complement(%d..%d)\n", $location->start, $location->end;
    } else {
    printf "%d..%d\n", $location->start, $location->end;
    }

=head1 DESCRIPTION

This is an implementation of Bio::LocationI to manage exact location
information on a Sequence: '22' or '12..15' or '16^17'.

You can test the type of the location using length() function () or
directly location_type() which can one of two values: 'EXACT' or
'IN-BETWEEN'.


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

=head1 AUTHOR - Heikki Lehvaslaiho

Email heikki-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut
