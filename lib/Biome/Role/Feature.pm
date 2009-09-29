package Biome::Role::Feature;

use Biome::Role;
use Moose::Util::TypeConstraints;
use MooseX::Aliases;

requires qw(
    start
    end
    length
);  # possibly Biome::Role::Locatable, but may delineate boundaries for a different
    # instance (nodes in a tree or graph, columns in an alignment, indices in an
    # array, etc). May need to be aliased as needed.
    
requires qw(
    display_name
    description
); # Biome::Role::Describable
    
requires qw(
    add_tag_values
    get_tag_values
    set_tag_values
    get_all_tags
    has_tag
    remove_tag
    get_tagset_values
); # Biome::Role::Taggable

has 'primary_tag'   => (
    isa         => 'Str',
    is          => 'rw',
);

has 'source_tag'    => (
    isa         => 'Str',
    is          => 'rw',
);

has 'score'         => (
    isa         => 'Str',
    is          => 'rw',    
    );

has 'primary_id'    => (
    isa         => 'Str',
    is          => 'rw',
);

has 'attached_id'   => (
    isa         => 'Str',
    is          => 'rw',
);

no Biome::Role;

1;

__END__

=head1 NAME

Biome::Role::Feature - Role that describes the basic attributes and methods
needed for describing any feature.

=head1 VERSION

This documentation refers to Biome::Role::Feature version 0.01.

=head1 SYNOPSIS

    package Biome::Foo;
    use Biome;
    
    with 'Biome::Role::Feature';
    
    # other comsumer-specific information

=head1 DESCRIPTION

This describes the basic abstract interface for a Feature. Methods expected in
this interface may be defined in other roles (for instance, Range, CollectTags,
CollectAnnotation, etc.).

=head1 SUBROUTINES/METHODS

TODO

=head1 DIAGNOSTICS

TODO

=head1 CONFIGURATION AND ENVIRONMENT

TODO

=head1 DEPENDENCIES

TODO

=head1 INCOMPATIBILITIES

TODO

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to the bioperl mailing list.
Patches are welcome.

=head1 EXAMPLES

TODO

=head1 FREQUENTLY ASKED QUESTIONS

TODO

=head1 COMMON USAGE MISTAKES

TODO

=head1 SEE ALSO

TODO

=head1 (DISCLAIMER OF) WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

TODO

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
