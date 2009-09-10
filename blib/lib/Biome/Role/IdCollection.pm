package Biome::Role::IdCollection;

use Biome::Role;

=head2 id_authorities

 Title   : id_authorities
 Usage   : @array    = $obj->id_authorities()
 Function: Return the authorities which have names for this object.
           The authorities can then be used to select ids.

 Returns : An array
 Status  : Virtual

=cut

requires 'id_authorities';

=head2 ids

 Title   : ids
 Usage   : @ids    = $obj->ids([$authority1,$authority2...])
 Function: return a list of Bio::IdentifiableI objects, optionally
           filtered by the list of authorities.

 Returns : A list of Bio::IdentifiableI objects.
 Status  : Virtual

=cut

requires 'ids';

no Biome::Role;

1;
