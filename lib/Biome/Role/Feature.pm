package Biome::Role::Feature;

use Biome::Role;

requires qw(
    start
    end
    length
);  # possibly Biome::Role::Range, but may delineate start/end for a different
    # range (nodes in a tree or graph, columns in an alignment, indices in an
    # array, etc).
    
requires qw(
    display_name
    description
); # Biome::Role::Describe
    
requires qw(
    add_tag_values
    get_tag_values
    set_tag_values
    get_all_tags
    has_tag
    remove_tag
    get_tagset_values    
); # Biome::Role::CollectTags

requires qw(
    primary_tag
    source_tag
    score
    
    get_Features
    add_Features
    attach_instance
    entire_instance
    spliced_instance
    id
    
); # specific for this role

no Biome::Role;

__END__

=head1 NAME

Biome::Role::Feature - Role that describes the basic attributes specific
for Features.

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

=head1 DIAGNOSTICS

None; abstract class.

=head1 CONFIGURATION AND ENVIRONMENT

None

=head1 DEPENDENCIES

Biome::Role (part of Biome)

=head1 INCOMPATIBILITIES

None known

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to the bioperl mailing list.
Patches are welcome.

=head1 EXAMPLES

Many people learn better by example than by explanation, and most learn better
by a combination of the two. Providing a /demo directory stocked with
well-commented examples is an excellent idea, but your users might not have
access to the original distribution, and the demos are unlikely to have been
installed for them. Adding a few illustrative examples in the documentation
itself can greatly increase the "learnability" of your code.

=head1 FREQUENTLY ASKED QUESTIONS

Incorporating a list of correct answers to common questions may seem like extra
work (especially when it comes to maintaining that list), but in many cases it
actually saves time. Frequently asked questions are frequently emailed
questions, and you already have too much email to deal with. If you find
yourself repeatedly answering the same question by email, in a newsgroup, on a
web site, or in person, answer that question in your documentation as well. Not
only is this likely to reduce the number of queries on that topic you
subsequently receive, it also means that anyone who does ask you directly can
simply be directed to read the fine manual.

=head1 COMMON USAGE MISTAKES

=head1 SEE ALSO

=head1 (DISCLAIMER OF) WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

Acknowledging any help you received in developing and improving your software is
plain good manners. But expressing your appreciation isn't only courteous; it's
also enlightened self-interest. Inevitably people will send you bug reports for
your software. But what you'd much prefer them to send you are bug reports
accompanied by working bug fixes. Publicly thanking those who have already done
that in the past is a great way to remind people that patches are always
welcome.

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
