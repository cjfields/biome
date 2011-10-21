package Biome::Annotation::Collection;

use Biome;

# though this is an Annotate consumer, we do not allow extra data or object
# slots (it implements Annotate so we can nest Collections)
with 'Biome::Role::CollectAnnotation',
     'Biome::Role::Annotate' => {
    'data_slots'        => []
    },
     'Biome::Role::ManageTypes';

has '+type_map' => (
    default => sub { {} },
);

has 'annotation_map' => (
    is        => 'rw',
    isa       => 'HashRef[ArrayRef[Biome::Role::Annotate]]',
    default   => sub { {} },
);

sub get_Annotation_keys {
    keys %{shift->annotation_map};
}

# may combine with get_Annotation_keys, passing as an option
sub get_all_Annotation_keys {
    my ($self, $method) = @_;
    $method //= 'depth';
    my @keys;
    for my $key ($self->get_Annotation_keys) {
        push @keys, $key;
    }
}

sub get_Annotations {
    my ($self,@keys) = @_;

    my @anns = ();
    @keys = $self->get_Annotation_keys() unless @keys;
    my $map = $self->annotation_map;
    foreach my $key (@keys) {
        if(exists($map->{$key})) {
            push(@anns,
                map {
                    $_->tagname($key) if ! $_->tagname(); $_;
                } @{$map->{$key}});
        }
    }
    return @anns;
}

sub get_nested_Annotations {
    shift->throw_not_implemented;
}

# does this and get_nested_Annotations do the same thing? Seems like some
# redundancy...
sub get_all_Annotations {
    my ($self,@keys) = @_;
    my @ann = map {
        $_->does("Biome::Role::CollectAnnotation") ?
            $_->get_all_Annotations(@keys) : $_;
    } $self->get_Annotations(@keys);
    return @ann;
}

# does not return nested values, only annotation # contained in this instance
sub get_num_Annotations {
    my ($self) = @_;
    my $count = 0;
    map { $count += scalar @$_ } values %{$self->annotation_map};
    return $count;
}

*add_Annotation = \&add_Annotations;

# As implemented in BioPerl; this doesn't enforce that an incoming instance that
# Annotates have a matching tagname (key).
sub add_Annotations {
    my ($self, $key, $object, $archetype) = @_;
    my $map = $self->annotation_map;
    # if there's no key we use the tagname() as key
    if(ref($key) && $key->does("Biome::Role::Annotate") && (!ref($object))) {
        $archetype = $object if defined($object);
        $object = $key;
        $key = $object->tagname;
        #$key = $key->name() if ref($key); # OntologyTerm Role
        $self->throw("Annotation object must have a tagname if key omitted")
            unless $key;
    }

    if( !defined $object ) {
        $self->throw("Must have at least key and object in add_Annotation");
    }

    if( !ref $object ) {
        $self->throw("Must add an object. Use Biome::Annotation::{Comment,SimpleValue} for simple text additions");
    }

    if( !$object->does("Biome::Role::Annotate") ) {
        $self->throw("object must use Annotatable Role, otherwise we won't add it!");
    }

    # ok, now we are ready! If we don't have an archetype, set it
    # from the type of the object

    if( !defined $archetype ) {
        $archetype = ref $object;
    }

    # check typemap, storing if needed.
    my $stored_map = $self->type_for_key($key);

    if( defined $stored_map ) {
        # check validity, irregardless of archetype. A little cheeky
        # this means isa stuff is executed correctly

        if( !$self->is_valid($key,$object) ) {
            $self->throw("Object $object was not valid with key $key. ".
              "If you were adding new keys in, perhaps you want to make use\n".
              "of the archetype method to allow registration to a more basic type");
        }
    } else {
        $self->_add_type_map($key,$archetype);
    }

    $object->tagname($key) if (!$object->tagname);

    # we are ok to store
    push(@{$map->{$key}},$object);

    return 1;
}

# can we remove Annotation by an identifier?
sub remove_Annotations {
    my ($self, @keys) = @_;

    @keys = $self->get_Annotation_keys() unless @keys;
    my @anns = $self->get_Annotations(@keys);
    my ($annmap, $typemap) = ($self->annotation_map, $self->type_map);
    # flush
    foreach my $key (@keys) {
        delete $annmap->{$key};
        delete $typemap->{$key};
    }
    return @anns;
}

sub flatten_Annotations {
    shift->throw_not_implemented
}

# create an iterator and return one at a time...
sub next_Annotation {
    shift->throw_not_implemented
}

# create an iterator and return one at a time...
sub next_Collection {
    shift->throw_not_implemented
}

# Annotate Role

has '+DEFAULT_CB' => (
    default     => sub {
        shift->throw_not_implemented
    },
    lazy        => 1
    );

sub as_text {
    shift->throw_not_implemented
}

no Biome;

__PACKAGE__->meta->make_immutable();

1;

__END__

# Thinking that Annotation and Annotation::Collection could be drastically
# simplified to use a simpler tree/node-like structure, maybe even lazy

                    |----- Ann1 (simple data/stringified objects)
                    |
Root collection ----|----- Ann2 (simple data/stringified objects)
                    |
                    |----- Nested coll --- Ann1 (simple data/stringified objects)
                                       |
                                       |-- Ann1 (simple data/stringified objects)



=head1 Greedy methods

=head2 get_Annotations()

 Usage   : my @annotations = $collection->get_Annotations('key')
 Function: Retrieves all the Biome::Role::Annotate objects for a specific key
 Returns : list of instances that Annotate - empty if no objects stored for a key
 Args    : string which is key for annotations

=head2 get_nested_Annotations

 Title   : get_nested_Annotations
 Usage   : my @annotations = $collection->get_nested_Annotations(
                                '-key' => \@keys,
                                '-recursive => 1);
 Function: Retrieves all the Biome::Role::Annotate objects for one or more
           specific key(s). If -recursive is set to true, traverses the nested
           annotation collections recursively and returns all annotations
           matching the key(s).

           If no key is given, returns all annotation objects.

           The returned objects will have their tagname() attribute set to
           the key under which they were attached, unless the tagname was
           already set.

 Returns : list of Biome::Role::Annotate - empty if no objects stored for a key
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
 Returns : an array of L<Biome::Role::Annotate> compliant objects
 Args    : keys (list of strings) for annotations (optional)

=head2 get_num_Annotations

 Title   : get_num_Annotations
 Usage   : my $count = $collection->get_num_Annotations()
 Function: Returns the count of instances implementing Annotate role stored
           in this collection.
 Returns : integer
 Args    : none

=head2 get_Annotation_keys()

 Usage   : $ac->get_Annotation_keys()
 Function: gives back a list of annotation keys, which are simple text strings
 Returns : Array of strings
 Args    : none
 Status  : Unstable; as implemented in BioPerl (as get_all_annotation_keys),
           this only gives back the keys for this level (no nested names).

=head1 Iterator-based methods

=head2 next_Annotation

 Title   : next_Annotations
 Usage   : my @annotations = $collection->next_Annotation(-keys => ['foo', 'ba
            -recursive => 1);
 Function: Iterates through the contained Annotations
 Returns : list of Biome::Role::Annotate - empty if no objects stored for a key
 Args    : -keys      => arrayref of keys to search for (optional)
           -recursive => boolean, whether or not to recursively traverse the
            nested annotations and return annotations with matching keys.
 Status  : Unstable

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
           object to store (must implement Biome::Role::Annotate Role)
           [optional] object archetype to map future storage of object
           of these types to
 Status  : Unstable (could allow removing specific annotations by an identifier)

=head2 remove_Annotations()

 Usage   :
 Function: Remove the annotations for the specified key from this collection.
 Returns : an list of Biome::Role::Annotate compliant objects which were stored
           under the given key(s)
 Args    : the key(s) (tag name(s), one or more strings) for which to
           remove annotations (optional; if none given, flushes all
           annotations)
 Status  : Unstable (could allow removing specific annotations by an identifier)

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
 Status  : Unknown

=cut

