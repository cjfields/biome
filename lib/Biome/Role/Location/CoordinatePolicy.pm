# Let the code begin...


package Bio::Moose::Role::Location::CoordinatePolicy;
use strict;

use Bio::Moose::Role;

=head2 start

  Title   : start
  Usage   : $start = $policy->start($location);
  Function: Get the integer-valued start coordinate of the given location as
            computed by this computation policy.
  Returns : A positive integer number.
  Args    : A Bio::LocationI implementing object.

=cut

requires  'start'; 

=head2 end

  Title   : end
  Usage   : $end = $policy->end($location);
  Function: Get the integer-valued end coordinate of the given location as
            computed by this computation policy.
  Returns : A positive integer number.
  Args    : A Bio::LocationI implementing object.

=cut

requires 'end'; 

no Bio::Moose::Role;

1;
