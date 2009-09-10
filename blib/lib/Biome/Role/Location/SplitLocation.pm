# Let the code begin...


package Biome::Role::Location::SplitLocation;

use Biome::Role;

with 'Biome::Role::Location';


=head2 sub_Location

 Title   : sub_Location
 Usage   : @locations = $feat->sub_Location();
 Function: Returns an array of LocationI objects
 Returns : An array
 Args    : none

=cut

requires 'sub_Location' ;

=head2 splittype

  Title   : splittype
  Usage   : $splittype = $fuzzy->splittype();
  Function: get/set the split splittype
  Returns : the splittype of split feature (join, order)
  Args    : splittype to set

=cut

requires 'splittype'; 


=head2 is_single_sequence

  Title   : is_single_sequence
  Usage   : if($splitloc->is_single_sequence()) {
                print "Location object $splitloc is split ".
                      "but only across a single sequence\n";
	    }
  Function: Determine whether this location is split across a single or
            multiple sequences.
  Returns : TRUE if all sublocations lie on the same sequence as the root
            location (feature), and FALSE otherwise.
  Args    : none

=cut

requires 'is_single_sequence';

no Biome::Role;

1;

