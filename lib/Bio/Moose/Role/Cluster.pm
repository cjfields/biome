package Bio::Moose::Role::Cluster;

use Bio::Moose::Role; 



=head2 display_id

 Title   : display_id
 Usage   : 
 Function: Get the display name or identifier for the cluster
 Returns : a string
 Args    : 

=cut

requires 'display_id';

=head2 description

 Title   : description
 Usage   : Bio::ClusterI->description("POLYUBIQUITIN")
 Function: get/set for the consensus description of the cluster
 Returns : the description string 
 Args    : Optional the description string 

=cut

requires 'description';

=head2 size

 Title   : size
 Usage   : Bio::ClusterI->size();
 Function: get/set for the size of the family, 
           calculated from the number of members
 Returns : the size of the family 
 Args    : 

=cut

requires 'size';


=head2 cluster_score

 Title   : cluster_score
 Usage   : $cluster ->cluster_score(100);
 Function: get/set for cluster_score which
           represent the score in which the clustering
           algorithm assigns to this cluster.
 Returns : a number

=cut

requires 'cluster_score';

=head2 get_members

 Title   : get_members
 Usage   : Bio::ClusterI->get_members(($seq1, $seq2));
 Function: retrieve the members of the family by some criteria, for
           example :
           $cluster->get_members(-species => 'homo sapiens'); 

           Will return all members if no criteria are provided.

 Returns : the array of members
 Args    : 

=cut

requires 'get_members';

no Bio::Moose::Role;
1;
