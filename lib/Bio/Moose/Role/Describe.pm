package Bio::Moose::Role::Describe;

use Bio::Moose::Role;

#maybe move the default to builder method
has display_name => (
    is    => 'rw',
    isa   => 'Str',
    default => sub {
        my $self = shift;
        if ($self->does('Bio::Moose::Role::Identify')) {
            $self->display_id(@_);
        } else {
            $_[0] || ''
        }
    },
    lazy   => 1
   );

has description => (
    is    => 'rw',
    isa   => 'Str'
   );

no Bio::Moose::Role;

1;

__END__

