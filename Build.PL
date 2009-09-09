#!/usr/bin/perl -w

# This is a Module::Build script for Bioperl installation.
# See http://search.cpan.org/~kwilliams/Module-Build/lib/Module/Build.pm

use strict;
use lib '.';
use Module::Build;

# Set up the Bio::Root::Build object
my $build = Module::Build->new(
    module_name         => 'Biome',
    description         => 'Moose-based implementation of core BioPerl modules',
    dist_name           => 'Biome',
    version             => '0.001',
    dist_author         => 'BioPerl Team <bioperl-l@bioperl.org>',
    dist_abstract       => 'Moose-based implementation of core BioPerl modules',
    license             => 'perl',
    requires            => {'perl'                      => 5.010,
                            'Moose'                     => '0.89_01',
                            # tentative list of MooseX modules

                            # I don't think we should include MooseX::Declares,
                            # MooseX::Method::Signatures. As nice as they are,
                            # as both have a ton of additional dependencies
                            # beyond Moose and are still alpha software

                            'MooseX::AttributeHelpers'      => 0,  # extended attributes
                            'Exception::Class'              => 0,  # may be removed as a 'requires' when made optional
                            'MooseX::Singleton'             => 0,  
                            'MooseX::ClassAttribute'        => 0,
                            'MooseX::Types'                 => 0,  # may be removed based on benchmarks
                            'MooseX::Role::Parameterized'   => 0,
                            'MooseX::Aliases'               => 0.03,
                            #'MooseX::Params::Validate'      => 0,  # replace rearrange?
                            #'MooseX::Types::Structured'     => 0,  # extended types
                            #'MooseX::Clone'                 => 0   # we have a root clone method, this could replace it
                            'List::MoreUtils'               => 0, 
                            'Data::Stag'                    => 0
                           },
    build_requires      => {
                            'Module::Build'             => 0.2805,
                           },
    recursive_test_files => 1,
);

# Create the build script and exit
$build->create_build_script;

