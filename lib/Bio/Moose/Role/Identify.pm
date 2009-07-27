package Bio::Moose::Role::Identify;

use Bio::Moose::Role;

#maybe move the default to builder method
has object_id => (
   is    => 'rw',
   isa   => 'Str',
   default => sub {
      shift->accession_number(@_);
   },
   lazy   => 1
   );

has version => (
   is    => 'rw',
   isa   => 'Int'
   );

has authority => (
   is    => 'rw',
   isa   => 'Str'
   );

has namespace => (
   is    => 'rw',
   isa   => 'Str'
   );

# Move the following ID-like methods to a separate role?

has display_id => (
   is    => 'rw',
   isa   => 'Str'
);

has accession_number => (
   is    => 'rw',
   isa   => 'Str'
);

has primary_id => (
   is    => 'rw',
   isa   => 'Str'
);

has id => (
   is    => 'rw',
   default => sub { shift->primary_id(@_) },
   lazy => 1
);

sub namespace_string {
   my ($self) = @_;
   return $self->namespace.":". $self->object_id .
       (defined($self->version()) ? ".".$self->version : '');   
}

no Bio::Moose::Role;

1;

__END__

