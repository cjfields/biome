package Biome::Role::Annotatable;

use Biome::Role;


=head2 annotation

 Title   : annotation
 Usage   : $obj->annotation($newval)
 Function: Get the annotation collection for this annotatable object.
 Example : 
 Returns : a Bio::AnnotationCollectionI implementing object, or undef
 Args    : on set, new value (a Bio::AnnotationCollectionI
           implementing object, optional) (an implementation may not
           support changing the annotation collection)

See L<Bio::AnnotationCollectionI>

=cut

requires 'annotation';

no Biome::Role;

1;
