package Biome;

our $VERSION = '0.001';

use Moose::Exporter;
use Moose 2.120 ();

Moose::Exporter->setup_import_methods(
    also    => 'Moose',
    base_class_roles => ['Biome::Role::Root']
);

1;
