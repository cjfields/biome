#!/usr/bin/perl -w

# This is a Module::Build script for Bioperl installation.
# See http://search.cpan.org/~kwilliams/Module-Build/lib/Module/Build.pm

use strict;
use lib '.';
use Module::Build;

# Set up the Bio::Root::Build object
my $build = Module::Build->new(
    module_name         => 'Bio::Moose',
    description         => 'Moose-based implementation of core BioPerl modules',
    dist_name           => 'Bio::Moose',
    version             => '0.001',
    dist_author         => 'BioPerl Team <bioperl-l@bioperl.org>',
    dist_abstract       => 'Moose-based implementation of core BioPerl modules',
    license             => 'perl',
    requires            => {'perl'                      => 5.010,
                            'Moose'                     => '0.87',
                            # tentative list of MooseX modules

                            # I don't think we should include MooseX::Declares,
                            # MooseX::Method. As nice as they are, as both have
                            # a ton of additional dependencies beyond Moose and
                            # are still alpha software

                            'MooseX::AttributeHelpers'  => 0,  # extended attributes
                            'MooseX::Singleton'         => 0,  
                            'MooseX::Params::Validate'  => 0,  # replace rearrange?
                            'MooseX::ClassAttribute'    => 0,
                            'MooseX::Types::Structured' => 0,  # extended types
                            'MooseX::Clone'             => 0   # we have a root clone method, this could replace it
                           },
    build_requires      => {
                            'Module::Build'             => 0.2805,
                           },
    recursive_test_files => 1,
);

# Create the build script and exit
$build->create_build_script;

