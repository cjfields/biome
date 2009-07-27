package Bio::Moose::Role::AnnotateCollection;

use Bio::Moose::Role;


=head2 get_all_annotation_keys()

 Usage   : $ac->get_all_annotation_keys()
 Function: gives back a list of annotation keys, which are simple text strings
 Returns : list of strings
 Args    : none

=cut

requires 'get_all_annotation_keys';

=head2 get_Annotations()

 Usage   : my @annotations = $collection->get_Annotations('key')
 Function: Retrieves all the Bio::AnnotationI objects for a specific key
 Returns : list of Bio::AnnotationI - empty if no objects stored for a key
 Args    : string which is key for annotations

=cut

requires 'get_Annotations';


=head2 add_Annotation()

 Usage   : $self->add_Annotation('reference',$object);
           $self->add_Annotation($object,'Bio::MyInterface::DiseaseI');
           $self->add_Annotation($object);
           $self->add_Annotation('disease',$object,'Bio::MyInterface::DiseaseI');
 Function: Adds an annotation for a specific key.

           If the key is omitted, the object to be added must provide a value
           via its tagname().

           If the archetype is provided, this and future objects added under
           that tag have to comply with the archetype and will be rejected
           otherwise.

 Returns : none
 Args    : annotation key ('disease', 'dblink', ...)
           object to store (must be Bio::AnnotationI compliant)
           [optional] object archetype to map future storage of object
           of these types to

=cut

requires 'add_Annotation';


=head2 remove_Annotations()

 Usage   :
 Function: Remove the annotations for the specified key from this collection.
 Returns : an list of Bio::AnnotationI compliant objects which were stored
           under the given key(s)
 Args    : the key(s) (tag name(s), one or more strings) for which to
           remove annotations (optional; if none given, flushes all
           annotations)

=cut

requires 'remove_Annotations';


=head2 get_num_of_annotations()

 Usage   : my $count = $collection->get_num_of_annotations()
 Function: Returns the count of all annotations stored in this collection
 Returns : integer
 Args    : none

=cut

requires 'get_num_of_annotations';


no Bio::Moose::Role;

1;
