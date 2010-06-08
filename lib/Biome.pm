package Biome;

our $VERSION = '0.001';

use Modern::Perl;
use Class::MOP;
use Moose ();
use Moose::Exporter;

use Biome::Meta::Class;
use Biome::Root::Error;

Moose::Exporter->setup_import_methods(also => 'Moose');

sub init_meta {
    shift;
    my $moose = Moose->init_meta(
        @_,
        base_class  => 'Biome::Root',
        metaclass   => 'Biome::Meta::Class',
        );
    $moose->error_class('Biome::Root::Error');
    $moose;
}

1;
