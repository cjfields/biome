package BioMoose::Root::Error;

use Moose;

has message    => ( isa => "Str",                    is => "ro" );
has attr       => ( isa => "Moose::Meta::Attribute", is => "ro" );
has method     => ( isa => "Moose::Meta::Method",    is => "ro" );
has metaclass  => ( isa => "Moose::Meta::Class",     is => "ro" );
has data       => ( is  => "ro" );
has line       => ( isa => "Int",                    is => "ro" );
has file       => ( isa => "Str",                    is => "ro" );
has last_error => ( isa => "Any",                    is => "ro" );

1;

__END__

ALL POD HERE
