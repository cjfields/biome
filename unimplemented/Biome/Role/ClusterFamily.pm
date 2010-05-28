package Biome::Role::ClusterFamily;

use Biome::Role; 

requires 'family_id';       # Identifiable
requires 'description';     # Describable
requires 'get_Clusters';    # greedy, non-specific interface, returns object
requires 'get_Cluster_ids'; # possibly greedy, non-specific interface, returns cluster IDs
requires 'next_Cluster';    # lazy, iteratively returns object

no Biome::Role;

1;

__END__

=head2 display_id

 Title   : display_id
 Usage   : 
 Function: Get the display name or identifier for the cluster
 Returns : a string
 Args    : 

=cut

=head2 description

 Title   : description
 Usage   : Bio::ClusterI->description("POLYUBIQUITIN")
 Function: get/set for the consensus description of the cluster
 Returns : the description string 
 Args    : Optional the description string 

=cut

=head2 size

 Title   : size
 Usage   : Bio::ClusterI->size();
 Function: get/set for the size of the family, 
           calculated from the number of members
 Returns : the size of the family 
 Args    : 

=cut

=head2 cluster_score

 Title   : cluster_score
 Usage   : $cluster ->cluster_score(100);
 Function: get/set for cluster_score which
           represent the score in which the clustering
           algorithm assigns to this cluster.
 Returns : a number

=cut

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
