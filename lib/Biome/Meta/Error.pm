package Biome::Meta::Error;

use Moose;

# stringification overload
use overload ('""' => \&to_string);

extends qw(Moose::Object Moose::Error::Default);

has message    => ( isa => "Str",                           is => "ro" );
has attr       => ( isa => "Moose::Meta::Attribute",        is => "ro" );
has method     => ( isa => "Moose::Meta::Method",           is => "ro" );
has metaclass  => ( isa => "Biome::Meta::Class",            is => "ro" );
has data       => ( is  => "ro" );
has line       => ( isa => "Int",                           is => "ro" );
has file       => ( isa => "Str",                           is => "ro" );
has last_error => ( isa => "Any",                           is => "ro" );

sub to_string {
    my ($self) = @_;
    my $class = ref($self) || $self;
    $self->message();
}

no Moose;

__PACKAGE__->meta->make_immutable();

1;

__END__

ALL POD HERE
