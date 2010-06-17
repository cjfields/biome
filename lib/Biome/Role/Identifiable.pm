package Biome::Role::Identifiable;

use MooseX::Role::Parameterized;#  -metaclass => 'Biome::Meta::Role::Parameterizable';

parameter id_slots => (
    isa         => 'ArrayRef[Str]',
    is          => 'ro',
    default     => sub {[qw(object_id display_id primary_id)]} 
);

parameter alternate_slots => (
    isa         => 'ArrayRef[Str]',
    is          => 'ro',
    default     => sub {[qw(version authority namespace accession_number)]} 
);

our %ALLOWED_ALTERNATES = map {$_ => 1} qw(version authority namespace accession_number);

role {
    my $p = shift;
    my ($id_slots, $alt_slots) = ($p->id_slots, $p->alternate_slots);
    
    if (grep {!exists $ALLOWED_ALTERNATES{$_}} @$alt_slots) {
        # TODO: once custom parameterizable trait works, add proper exception
        __PACKAGE__->meta->throw_error("Only ".join(',', keys %ALLOWED_ALTERNATES). " are allowed");
    }

    if (grep { $_ !~ /_id$/ } @$id_slots) {
        # TODO: once custom parameterizable trait works, add proper exception
        __PACKAGE__->meta->throw_error("ID slots must have '_id' tag");
    }
    
    has $id_slots => (
        is      => 'rw',
        isa     => 'Str',
    );
    
    has $alt_slots => (
            is      => 'rw',
            isa     => 'Str'
    );

    method 'namespace_string' => sub {
        my ($self) = @_;
        return $self->namespace.":". $self->object_id .
             (defined($self->version()) ? ".".$self->version : '');   
    }
};

no MooseX::Role::Parameterized;

1;

__END__

=head2 object_id

 Title   : object_id
 Usage   : $string    = $obj->object_id()
 Function: a string which represents the stable primary identifier
              in this namespace of this object. For DNA sequences this
              is its accession_number, similarly for protein sequences
 Returns : A scalar
 Status  : Stable

=cut

=head2 version

 Title   : version
 Usage   : $version    = $obj->version()
 Function: a number which differentiates between versions of
              the same object. Higher numbers are considered to be
              later and more relevant, but a single object described
              the same identifier should represent the same concept
 Returns : A number
 Status  : Stable

=cut

=head2 authority

 Title   : authority
 Usage   : $authority    = $obj->authority()
 Function: a string which represents the organisation which
              granted the namespace, written as the DNS name for
              organisation (eg, wormbase.org)
 Returns : A scalar
 Status  : Stable

=cut

=head2 namespace

 Title   : namespace
 Usage   : $string    = $obj->namespace()
 Function: A string representing the name space this identifier
              is valid in, often the database name or the name
              describing the collection
 Returns : A scalar
 Status  : Stable

=cut

=head2 accession_number

 Title   : accession_number
 Usage   : $unique_biological_key = $obj->accession_number;
 Function: Returns the unique biological id for a sequence, commonly
              called the accession_number. For sequences from established
              databases, the implementors should try to use the correct
              accession number. Notice that primary_id() provides the
              unique id for the implemetation, allowing multiple objects
              to have the same accession number in a particular implementation.

              For sequences with no accession number, this method should return
              "unknown".
 Returns : A string
 Args    : None
 Status  : Stable

=cut

=head2 display_id

 Title   : display_id
 Usage   : $id_string = $obj->display_id();
 Function: Returns the display id, also known as the common name of the Sequence
              object.

              The semantics of this is that it is the most likely string
              to be used as an identifier of the sequence, and likely to
              have "human" readability.  The id is equivalent to the ID
              field of the GenBank/EMBL databanks and the id field of the
              Swissprot/sptrembl database. In fasta format, the >(\S+) is
              presumed to be the id, though some people overload the id
              to embed other information. Bioperl does not use any
              embedded information in the ID field, and people are
              encouraged to use other mechanisms (accession field for
              example, or extending the sequence object) to solve this.

              Notice that $seq->id() maps to this function, mainly for
              legacy/convenience reasons.
 Returns : A string
 Args    : None
 Status  : Virtual

=cut

=head2 primary_id

 Title   : primary_id
 Usage   : $unique_implementation_key = $obj->primary_id;
 Function: Returns the unique id for this object in this
              implementation. This allows implementations to manage their
              own object ids in a way the implementaiton can control
              clients can expect one id to map to one object.

              For sequences with no accession number, this method should
              return a stringified memory location.

 Returns : A string
 Args    : None
 Status  : Virtual

=cut

=head2 id

 Note    : The generic attribute id() is not implemented in Biome
 
=cut

=head2 namespace_string

 Title   : namespace_string
 Usage   : $string   = $obj->namespace_string()
 Function: a string which gives the common notation of
              namespace:object_id.version
 Returns : A scalar
 Status  : TODO

=cut
