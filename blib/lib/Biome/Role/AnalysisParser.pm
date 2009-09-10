package Biome::Role::AnalysisParser;

use Biome::Role;


=head2 next_result

 Title   : next_result
 Usage   : $result = $obj->next_result();
 Function: Returns the next result available from the input, or
           undef if there are no more results.
 Example :
 Returns : A Bio::Search::Result::ResultI implementing object, 
           or undef if there are no more results.
 Args    : none

=cut

requires 'next_result';

no Biome::Role;

1;
