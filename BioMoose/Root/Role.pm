package BioMoose::Root::Role;

use Moose::Role ();

use Moose::Exporter;

use BioMoose::Root::Meta::Role;

Moose::Exporter->setup_import_methods(also => 'Moose::Role');

sub init_meta {
	shift;
	return Moose::Role->init_meta(
		@_,
		metaclass => 'BioMoose::Root::Meta::Role'); # can this be a general meta class?
}

1;

__END__

ALL POD HERE