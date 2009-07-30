=head1 NAME

Bio::Location::FuzzyLocationI - Abstract interface of a Location on a Sequence
which has unclear start/end location

=head1 SYNOPSIS

    # Get a FuzzyLocationI object somehow
    print "Fuzzy FT location string is ", $location->to_FTstring();
    print "location is of the type ", $location->loc_type, "\n";

=head1 DESCRIPTION

This interface encapsulates the necessary methods for representing a
Fuzzy Location, one that does not have clear start and/or end points.
This will initially serve to handle features from Genbank/EMBL feature
tables that are written as 1^100 meaning between bases 1 and 100 or
E<lt>100..300 meaning it starts somewhere before 100.  Advanced
implementations of this interface may be able to handle the necessary
logic of overlaps/intersection/contains/union.  It was constructed to
handle fuzzy locations that can be represented in Genbank/EMBL.

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
the bugs and their resolution.  Bug reports can be submitted via the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Jason Stajich

Email jason-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...


package Bio::Moose::Role::Location::FuzzyLocation;

use Bio::Moose::Role;

with 'Bio::Moose::Role::LocationI';

no Bio::Moose::Role;

1;
