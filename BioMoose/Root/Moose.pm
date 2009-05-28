
package BioMoose::Root::Moose;

use Moose ();

use Moose::Exporter;

use BioMoose::Root::Root;
use BioMoose::Root::Meta::Class;
use BioMoose::Root::Error;

Moose::Exporter->setup_import_methods(also => 'Moose');

sub init_meta {
	shift;
	my $moose = Moose->init_meta(
		@_,
		base_class 	=> 'BioMoose::Root::Root',
		role_class  => 'BioMoose::Root::Meta::Role',
		metaclass 	=> 'BioMoose::Root::Meta::Class',
		);
	$moose->error_class('BioMoose::Root::Error');
	$moose;
}

1;
