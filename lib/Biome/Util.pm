package Biome::Util;

use Moose::Util;
use strict;
use warnings;

#use Module::Runtime 'use_package_optimistically', 'use_module', 'module_notional_filename';
#use Data::OptList;
#use Params::Util qw( _STRING );
#use Sub::Exporter;
#use Scalar::Util 'blessed';
#use List::Util qw(first);
#use List::MoreUtils qw(any all);
use overload ();
#use Try::Tiny;

my @exports = qw[
    throw_exception
];

Sub::Exporter::setup_exporter({
    exports => \@exports,
    groups  => { all => \@exports }
});

sub throw_exception {
    my ($class_name, @args_to_exception) = @_;
    my $class = $class_name ? "Biome::Exception::$class_name" : "Biome::Exception";
    Moose::Util::_load_user_class( $class );
    die $class->new( @args_to_exception );
}

1;
