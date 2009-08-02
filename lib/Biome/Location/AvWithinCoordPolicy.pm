
# Let the code begin...


package BioMe::Location::AvWithinCoordPolicy;
use BioMe;
extends 'BioMe::Location::WidestCoordPolicy';


=head2 start

  Title   : start
  Usage   : $start = $policy->start($location);
  Function: Get the integer-valued start coordinate of the given location as
            computed by this computation policy.
  Returns : A positive integer number.
  Args    : A Bio::LocationI implementing object.

=cut

sub start {
    my ($self,$loc) = @_;

    if(($loc->start_pos_type() eq 'WITHIN') ||
       ($loc->start_pos_type() eq 'BETWEEN')) {
	my ($min, $max) = ($loc->min_start(), $loc->max_start());
	return int(($min+$max)/2) if($min && $max);
    }
    return $self->SUPER::start($loc);
}

=head2 end

  Title   : end
  Usage   : $end = $policy->end($location);
  Function: Get the integer-valued end coordinate of the given location as
            computed by this computation policy.
  Returns : A positive integer number.
  Args    : A Bio::LocationI implementing object.

=cut

sub end {
    my ($self,$loc) = @_;

    if(($loc->end_pos_type() eq 'WITHIN') ||
       ($loc->end_pos_type() eq 'BETWEEN')) {
	my ($min, $max) = ($loc->min_end(), $loc->max_end());
	return int(($min+$max)/2) if($min && $max);
    }
    return $self->SUPER::end($loc);
}

no BioMe;

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Bio::Location::AvWithinCoordPolicy - class implementing 
Bio::Location::CoordinatePolicy as the average for WITHIN and the widest possible and reasonable range otherwise

=head1 SYNOPSIS

See Bio::Location::CoordinatePolicyI

=head1 DESCRIPTION

CoordinatePolicyI implementing objects are used by Bio::LocationI
implementing objects to determine integer-valued coordinates when
asked for it.

This class will compute the coordinates such that for fuzzy locations
of type WITHIN and BETWEEN the average of the two limits will be
returned, and for all other locations it will return the widest
possible range, but by using some common sense. This means that
e.g. locations like "E<lt>5..100" (start before position 5) will return 5
as start (returned values have to be positive integers).

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

=head1 AUTHOR - Hilmar Lapp, Jason Stajich

Email E<lt>hlapp-at-gmx-dot-netE<gt>, E<lt>jason-at-bioperl-dot-orgE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut
