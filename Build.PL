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
                            
                            # needed for Native Types (replacement for MXAH)
                            'Moose'                         => '1.00',
                            # tentative list of MooseX modules, for comments
                            # see CONVENTIONS
                            'MooseX::Singleton'             => 0,
                            
                            # use sparingly (instances where this is used may be
                            # switched over to something simpler)
                            'MooseX::ClassAttribute'        => 0,
                            
                            # compat with Moose 0.90
                            'MooseX::Types'                 => 0.20,
                            #'MooseX::Types::Structured'     => 0,  # extended types
                            
                            # Flexibility for attribute definitions
                            'MooseX::Role::Parameterized'   => 0,
                            
                            # init, attribute, method aliases
                            'MooseX::Aliases'               => 0.03,
                            
                            # not used ATM, but worth considering
                            #'MooseX::Params::Validate'      => 0,  # replace rearrange?

                            # general use
                            'Modern::Perl'                  => 0,
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

