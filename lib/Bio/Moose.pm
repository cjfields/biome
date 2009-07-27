package Bio::Moose;

use Moose ();

use Moose::Exporter;

#use Bio::Moose::Root;
use Bio::Moose::Meta::Class;

our $EXCEPTION_CLASS = '';

# to switch off Exception::Class usage if Exception::Class is installed,
# set env. var. BP_EXCEPTION_CLASS = ''
if (exists $ENV{BP_EXCEPTION_CLASS}) {
	$EXCEPTION_CLASS = $ENV{BP_EXCEPTION_CLASS};
} else {
	eval {use Exception::Class; 1;};
	if (!$@) {
		$EXCEPTION_CLASS = 'Bio::Moose::Root::Error';
	}
}

Moose::Exporter->setup_import_methods(also => 'Moose');

sub init_meta {
	shift;
	my $moose = Moose->init_meta(
		@_,
		base_class 	=> 'Bio::Moose::Root',
		metaclass 	=> 'Bio::Moose::Meta::Class',
		);
	
	# In original Bio::Root::Root, we explicitly use Error.pm (if present)
	# unless specified via a script-defined global variable. Here, as Moose
	# allows user-defined error classes as well built-in default ones, we can
	# allow more flexibility by allowing users some freedom, but what should we
	# fall back to?
	
	# for now, using Bio::Moose::Root::Error (subclass of
	# Exception::Class::Base) which has methods lifted from the Moose tests.
	# This'll need to be made more user-friendly at some point (maybe allow the
	# Moose default?)
	$moose->error_class($EXCEPTION_CLASS) if $EXCEPTION_CLASS;
	$moose;
}

1;
