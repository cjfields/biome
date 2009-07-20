package Bio::Moose::Role::SeqAnalysisParser;

use Bio::Moose::Role;

=head2 next_feature

 Title   : next_feature
 Usage   : $seqfeature = $obj->next_feature();
 Function: Returns the next feature available in the analysis result, or
           undef if there are no more features.
 Example :
 Returns : A Bio::SeqFeatureI implementing object, or undef if there are no
           more features.
 Args    : none    

=cut

requires 'next_feature';

no Bio::Moose::Role;

1;
