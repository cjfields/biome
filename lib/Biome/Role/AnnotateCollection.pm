package Bio::Moose::Role::AnnotateCollection;

use Bio::Moose::Role;

requires qw(
    get_all_Annotation_keys
    get_Annotations
    get_nested_Annotations
    get_all_Annotations
    get_num_Annotations
    add_Annotation
    remove_Annotations
    flatten_Annotations
);

no Bio::Moose::Role;

1;

__END__

=head1 Greedy methods

=head2 get_all_annotation_keys()

 Usage   : $ac->get_all_annotation_keys()
 Function: gives back a list of annotation keys, which are simple text strings
 Returns : Array of strings
 Args    : none

=head2 get_Annotations()

 Usage   : my @annotations = $collection->get_Annotations('key')
 Function: Retrieves all the Bio::Moose::Role::Annotate objects for a specific key
 Returns : list of instances that Annotate - empty if no objects stored for a key
 Args    : string which is key for annotations

=head2 get_nested_Annotations

 Title   : get_nested_Annotations
 Usage   : my @annotations = $collection->get_nested_Annotations(
                                '-key' => \@keys,
                                '-recursive => 1);
 Function: Retrieves all the Bio::Moose::Role::Annotate objects for one or more
           specific key(s). If -recursive is set to true, traverses the nested 
           annotation collections recursively and returns all annotations 
           matching the key(s).

           If no key is given, returns all annotation objects.

           The returned objects will have their tagname() attribute set to
           the key under which they were attached, unless the tagname was
           already set.

 Returns : list of Bio::Moose::Role::Annotate - empty if no objects stored for a key
 Args    : -keys      => arrayref of keys to search for (optional)
           -recursive => boolean, whether or not to recursively traverse the 
            nested annotations and return annotations with matching keys.

=head2 get_all_Annotations

 Title   : get_all_Annotations
 Usage   :
 Function: Similar to get_Annotations, but traverses and flattens nested
           annotation collections. This means that collections in the
           tree will be replaced by their components.

           Keys will not be passed on to nested collections. I.e., if the
           tag name of a nested collection matches the key, it will be
           flattened in its entirety.

           Hence, for un-nested annotation collections this will be identical
           to get_Annotations.
 Example :
 Returns : an array of L<Bio::Moose::Role::Annotate> compliant objects
 Args    : keys (list of strings) for annotations (optional)

=head2 get_num_of_Annotations

 Title   : get_num_of_annotations
 Usage   : my $count = $collection->get_num_of_annotations()
 Function: Returns the count of all annotations stored in this collection 
 Returns : integer
 Args    : none

=head1 Iterator-based methods

=head2 next_Annotation

 Title   : next_Annotations
 Usage   : my @annotations = $collection->next_Annotation(-keys => ['foo', 'ba
            -recursive => 1);
 Function: Iterates through the contained Annotations
 Returns : list of Bio::Moose::Role::Annotate - empty if no objects stored for a key
 Args    : -keys      => arrayref of keys to search for (optional)
           -recursive => boolean, whether or not to recursively traverse the 
            nested annotations and return annotations with matching keys.
 Note    : Optionally implemented for laziness, implementations not using this
           should use a noop instead

=head1 Adding/removing annotation

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
           object to store (must implement Bio::Moose::Role::Annotate Role)
           [optional] object archetype to map future storage of object
           of these types to

=head2 remove_Annotations()

 Usage   :
 Function: Remove the annotations for the specified key from this collection.
 Returns : an list of Bio::Moose::Role::Annotate compliant objects which were stored
           under the given key(s)
 Args    : the key(s) (tag name(s), one or more strings) for which to
           remove annotations (optional; if none given, flushes all
           annotations)

=head2 flatten_Annotations

 Title   : flatten_Annotations
 Usage   :
 Function: Flattens part or all of the annotations in this collection.

           This is a convenience method for getting the flattened
           annotation for the given keys, removing the annotation for
           those keys, and adding back the flattened array.

           This should not change anything for un-nested collections.
 Example :
 Returns : an array Bio::Moose::Role::Annotate compliant objects which were stored
           under the given key(s)
 Args    : list of keys (strings) the annotation for which to flatten,
           defaults to all keys if not given

=cut

