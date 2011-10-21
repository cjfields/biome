package Biome::Role::CollectAnnotation;

use Biome::Role;

requires qw(
    get_Annotations
    get_all_Annotations
    get_num_Annotations

    get_Annotation_keys
    get_all_Annotation_keys

    add_Annotations
    remove_Annotations
    flatten_Annotations

    next_Annotation
);

no Biome::Role;

1;

__END__

=head1 NAME

Biome::Role::CollectAnnotation - Role for collecting Annotation (or any
Biome::Role::Annotate consumers)

=head1 VERSION

This documentation refers to Biome::Role::CollectAnnotation version 0.01.

=head1 SYNOPSIS

    package MyAnnotationCollection;

    use Biome;

    with qw(Biome::Role::CollectAnnotation
            Biome::Role::ManageTypes);  # class consumes both roles

    # .....

    package main;

    use MyAnnotation;
    use MyAnnotationCollection;

    # Biome::Role::Annotate consumer
    my $ann = MyAnnotation->new(-tagname => 'foo', -bar => 'baz');

=head1 DESCRIPTION

Describes the basic abstract interface role for collecting any
Biome::Annotation::* or other Biome::Role::Annotate consumers. Consumers of this
role.

=head1 SUBROUTINES/METHODS

=head2 Greedy methods

=head2 get_Annotation_keys()

 Title    : get_Annotation_keys
 Usage    : $ac->get_all_annotation_keys()
 Function : Gives back a list of Annotation keys, which are simple text strings.
            This returns only the keys at the first level in the hierarchy (ones
            immediately available)
 Returns  : Array of strings
 Args     : none
 Status   : Virtual

=head2 get_all_Annotation_keys()

 Title    : get_all_Annotation_keys
 Usage    : $ac->get_all_Annotation_keys()
 Function : gives back a list of Annotation keys, which are simple text strings.
            This returns all keys in this Collection
 Returns  : Array of strings
 Args     : [optional] 'breadth'/'depth' - indicates the order for returning
            keys
 Status   : Virtual

=head2 get_Annotations()

 Title    : get_Annotations
 Usage    : my @annotations = $collection->get_Annotations('key')
 Function : Retrieves all the Biome::Role::Annotate objects for a specific key
 Returns  : list of instances that Annotate - empty if no objects stored for a key
 Args     : string which is key for annotations
 Status   : Virtual

=head2 get_nested_Annotations

 Title    : get_nested_Annotations
 Usage    : my @annotations = $collection->get_nested_Annotations(
                                '-key' => \@keys,
                                '-recursive => 1);
 Function : Retrieves all the Biome::Role::Annotate objects for one or more
            specific key(s). If -recursive is set to true, traverses the nested
            annotation collections recursively and returns all annotations
            matching the key(s).

            If no key is given, returns all annotation objects.

            The returned objects will have their tagname() attribute set to
            the key under which they were attached, unless the tagname was
            already set.
 Returns  : list of Biome::Role::Annotate - empty if no objects stored for a key
 Args     : -keys      => arrayref of keys to search for (optional)
            -recursive => boolean, whether or not to recursively traverse the
             nested annotations and return annotations with matching keys.
 Status   : Virtual

=head2 get_all_Annotations

 Title    : get_all_Annotations
 Usage    :
 Function : Similar to get_Annotations, but traverses and flattens nested
            annotation collections. This means that collections in the
            tree will be replaced by their components.

            Keys will not be passed on to nested collections. I.e., if the
            tag name of a nested collection matches the key, it will be
            flattened in its entirety.

            Hence, for un-nested annotation collections this will be identical
            to get_Annotations.
 Example  :
 Returns  : an array of L<Biome::Role::Annotate> compliant objects
 Args     : keys (list of strings) for annotations (optional)
 Status   : Virtual

=head2 get_num_of_Annotations

 Title    : get_num_of_Annotations
 Usage    : my $count = $collection->get_num_of_Annotations()
 Function : Returns the count of all annotations stored in this collection
 Returns  : integer
 Args     : none
 Status   : Virtual

=head2 Iterator-based methods

=head2 next_Annotation

 Title   :  next_Annotation
 Usage   :  my @annotations = $collection->next_Annotation(-keys => ['foo', 'ba
             -recursive => 1);
 Function:  Iterates through the contained Annotations
 Returns :  list of Biome::Role::Annotate - empty if no objects stored for a key
 Args    :  -keys      => arrayref of keys to search for (optional)
            -type      => arrayref of types to search for (optional)
            -recursive => boolean, whether or not to recursively traverse the
             nested annotations and return annotations with matching keys.
 Status   : Virtual

=head2 next_Collection

 Title    : next_Collection
 Usage    : my @annotations = $collection->next_Collection(-keys => ['foo', 'ba
             -recursive => 1);
 Function : Iterates through the contained Annotations
 Returns  : list of Biome::Role::Annotate - empty if no objects stored for a key
 Args     : -keys      => arrayref of keys to search for (optional)
            -recursive => boolean, whether or not to recursively traverse the
             nested annotations and return annotations with matching keys.
 Status   : Virtual

=head2 Adding/removing annotation

=head2 add_Annotations

 Usage    : $self->add_Annotations(-tagname => 'reference',
                                   -$object);
            $self->add_Annotations($object,'Bio::MyInterface::DiseaseI');
            $self->add_Annotations($object);
            $self->add_Annotations('disease',$object,'Bio::MyInterface::DiseaseI');
 Function : Adds an annotation for a specific key.

            If the key is omitted, the object to be added must provide a value
            via its tagname().

            If the archetype is provided, this and future objects added under
            that tag have to comply with the archetype and will be rejected
            otherwise.

 Returns :  none
 Args    :  annotation key ('disease', 'dblink', ...)
            object to store (must implement Biome::Role::Annotate Role)
            [optional] object archetype to map future storage of object
            of these types to
 Status   : Virtual

=head2 remove_Annotations()

 Usage    :
 Function : Remove the annotations for the specified key from this collection.
 Returns  : an list of Biome::Role::Annotate compliant objects which were stored
            under the given key(s)
 Args     : the key(s) (tag name(s), one or more strings) for which to
            remove annotations (optional; if none given, flushes all
            annotations)
 Status   : Virtual, but unstable (needs to be defined more specifically)

=head2 flatten_Annotations

 Title   : flatten_Annotations
 Usage   :
 Function: Flattens part or all of the annotations in this collection.

           This is a convenience method for getting the flattened
           annotation for the given keys, removing the annotation for
           those keys, and adding back the flattened array.

           This should not change anything for un-nested collections.
 Example :
 Returns : an array Biome::Role::Annotate compliant objects which were stored
           under the given key(s)
 Args    : list of keys (strings) the annotation for which to flatten,
           defaults to all keys if not given
 Status   : Virtual

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to Chris Fields (cjfields at bioperl dot org)
Patches are welcome.

=head1 EXAMPLES

Abstract interface role; in general, any consumers should follow the L<SYNOPSIS>
for general ideas

=head1 FREQUENTLY ASKED QUESTIONS

...

=head1 COMMON USAGE MISTAKES

...

=head1 SEE ALSO

Biome::Role::Annotate
Biome::Role::ManageTypes

The original BioPerl interface/implementation (L<Bio::AnnotationCollectionI> and
L<Bio::Annotation::Collection>)

=head1 ACKNOWLEDGEMENTS

Ewan Birney (original BioPerl implementation)

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
