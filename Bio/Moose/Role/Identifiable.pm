package Bio::Moose::Root::Identifiable;

use Bio::Moose::Role;


=head2 object_id

 Title   : object_id
 Usage   : $string    = $obj->object_id()
 Function: a string which represents the stable primary identifier
           in this namespace of this object. For DNA sequences this
           is its accession_number, similarly for protein sequences
 Returns : A scalar
 Status  : Virtual

=cut

requires 'object_id';


=head2 version

 Title   : version
 Usage   : $version    = $obj->version()
 Function: a number which differentiates between versions of
           the same object. Higher numbers are considered to be
           later and more relevant, but a single object described
           the same identifier should represent the same concept
 Returns : A number
 Status  : Virtual

=cut

requires 'version';

=head2 authority

 Title   : authority
 Usage   : $authority    = $obj->authority()
 Function: a string which represents the organisation which
           granted the namespace, written as the DNS name for
           organisation (eg, wormbase.org)
 Returns : A scalar
 Status  : Virtual

=cut

requires 'authority';


=head2 namespace

 Title   : namespace
 Usage   : $string    = $obj->namespace()
 Function: A string representing the name space this identifier
           is valid in, often the database name or the name
           describing the collection
 Returns : A scalar
 Status  : Virtual

=cut

requires namespace;

=head2 lsid_string

 Title   : lsid_string
 Usage   : $string   = $obj->lsid_string()
 Function: a string which gives the LSID standard
           notation for the identifier of interest


 Returns : A scalar

=cut

has 'lsid_string' => ( 
	is => 'ro', 
	default => sub {
		return $self->authority.':'.$self->namespace.':'.$self->object_id;
	}, 
);


=head2 namespace_string

 Title   : namespace_string
 Usage   : $string   = $obj->namespace_string()
 Function: a string which gives the common notation of
           namespace:object_id.version
 Returns : A scalar

=cut

has 'namespace_string' => (
	is => 'ro', 
	default => sub { 
		return $self->namespace.':'.$self->object_id.(defined $self->version ?
		'.'.$self->version: '');
	}, 
);


no Bio::Moose::Role;

1;
