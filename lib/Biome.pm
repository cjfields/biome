package Biome;

our $VERSION = '0.001';

use 5.014;
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

# place Lincoln's rearrange() and other utility methods here
sub rearrange {
    my $dummy = shift;
    my $order = shift;
    return @_ unless (index($_[0]||'', '-') == 0);
    push @_,undef unless $#_ %2;
    my %param;
    while( @_ ) {
	(my $key = shift) =~ tr/a-z\055/A-Z/d; #deletes all dashes!
	$param{$key} = shift;
    }
    map { $_ = uc($_) } @$order; # for bug #1343, but is there perf hit here?
    return @param{@$order};
}

1;
