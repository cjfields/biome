package BioMoose::Root::Root;
use Moose 0.79;

extends 'Moose::Object';

# separate verbosity and strictness/exceptions. Global settings override local
# ones, but this can be overridden in child classes
has 'verbose' => (
    is   => 'rw',
    isa  => 'Bool',
    default => $ENV{BIOPERL_DEBUG} || 0
    );

# strictness level; setting to True converts warnings to exceptions
has 'strict' => (
    is      => 'rw',
    isa     => 'Int',
    where   => sub {$_ >= -1 && $_ <= 2},
    default => $ENV{BIOPERL_STRICT} || 0
    );

no Moose;

1;

__END__

ALL POD HERE
