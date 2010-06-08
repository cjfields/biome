package Biome;

our $VERSION = '0.001';

use Modern::Perl;
use Class::MOP;
use Moose ();
use Moose::Exporter;

use Biome::Meta::Class;
use Biome::Meta::Error;

Moose::Exporter->setup_import_methods(also => 'Moose');

sub init_meta {
    shift;
    my $moose = Moose->init_meta(
        @_,
        base_class  => 'Biome::Root',
        metaclass   => 'Biome::Meta::Class',
        );
    $moose->error_class('Biome::Meta::Error');
    $moose;
}

# additional sugar here, make sure to add to set_import_methods as needed

1;
