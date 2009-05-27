package BioMoose::Root::Error;
use BioMoose::Root::Moose;

has message    => ( isa => "Str",                    is => "ro" );
has attr       => ( isa => "Moose::Meta::Attribute", is => "ro" );
has method     => ( isa => "Moose::Meta::Method",    is => "ro" );
has metaclass  => ( isa => "Bio::Root::Meta::Class", is => "ro" );
has data       => ( is  => "ro" );
has line       => ( isa => "Int",                    is => "ro" );
has file       => ( isa => "Str",                    is => "ro" );
has last_error => ( isa => "Any",                    is => "ro" );

no BioMoose::Root::Moose;

1;

__END__

ALL POD HERE
