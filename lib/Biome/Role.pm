package Biome::Role;

use Moose::Role ();

use Moose::Exporter;

use Biome::Meta::Role;

Moose::Exporter->setup_import_methods(also => 'Moose::Role');

sub init_meta {
	shift;
	return Moose::Role->init_meta(
		@_,
		metaclass => 'Biome::Meta::Role');
}

1;

__END__

