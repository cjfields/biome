
package BioMoose::Root::Moose;

use Moose ();

use Moose::Exporter;

use BioMoose::Root::Root;
use BioMoose::Root::Meta::Class;

Moose::Exporter->setup_import_methods(also => 'Moose');

sub init_meta {
	shift;
	return Moose->init_meta(
		@_,
		base_class 	=> 'BioMoose::Root::Root',
		metaclass 	=> 'BioMoose::Root::Meta::Class',
		error_class => 'BioMoose::Root::Error',
		);
}

1;
