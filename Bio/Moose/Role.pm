package Bio::Moose::Root::Role;

use Moose::Role ();

use Moose::Exporter;

use Bio::Moose::Meta::Role;

Moose::Exporter->setup_import_methods(also => 'Moose::Role');

sub init_meta {
	shift;
	return Moose::Role->init_meta(
		@_,
		metaclass => 'Bio::Moose::Meta::Role'); 
}

1;

__END__

ALL POD HERE