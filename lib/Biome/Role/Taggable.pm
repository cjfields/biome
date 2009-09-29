package Biome::Role::Taggable;

use Biome::Role;

use Moose::Util::TypeConstraints;

subtype 'TagMap' => as 'HashRef[ArrayRef[Str]]';

coerce 'TagMap'
    => from 'HashRef[Str]'
      => via {
        my $hash = shift;
        return { map {$_ => [$hash->{$_}] } sort keys %{$hash} }
        };

has tag_map => (
    is          => 'rw',
    traits      => ['Hash'],
    isa         => 'TagMap',
    default     => sub { { } },
    handles     => {
        'get_all_tags'      => 'keys',
        'has_tag'           => 'exists',
        'remove_all_tags'   => 'clear',
        '_get_tag_values'   => 'get',
        '_set_tag_values'   => 'set',
        '_remove_tag'       => 'delete'
    },
    coerce      => 1,
);

sub get_tag_values {
    my ($self, @args) = @_;
    my $vals = $self->_get_tag_values(@args);
    ref $vals ? @{$vals} : $vals;
}

sub set_tag_values {
    my ($self, $tag, @vals) = @_;
    $self->_set_tag_values($tag, \@vals);    
}

sub remove_tag {
    my ($self, $tag) = @_;
    my $vals = $self->_remove_tag($tag);
    ref $vals ? @{$vals} : $vals;
}

sub add_tag_values {
    my ($self, $tag, @values) = @_;
    return unless defined $tag && @values;
    my $map = $self->tag_map;
    @values = @{$values[0]} if ref($values[0]) eq 'ARRAY';
    push @{$map->{$tag}}, @values;
}

sub get_tagset_values {
    my ($self, @args) = @_;
    my @vals = ();
    foreach my $arg (@args) {
        if ($self->has_tag($arg)) {
            push(@vals, $self->get_tag_values($arg));
        }
    }
    return @vals;    
}

no Biome::Role;

1;

__END__

=head1 NAME

Biome::Role::Taggable - Role for collecting simple tag-value pairs

=head1 VERSION

This documentation refers to Biome::Role::Taggable version 0.01.

=head1 SYNOPSIS

    package MyCollection;
    use Biome;
    with 'Biome::Role::Taggable';
    
    # and later in main...
    
    my $tc = MyCollection->new();
    
    # add 'bar', 'baz' values to 'foo' tag
    $tc->add_tag_values('foo', 'bar', 'baz');
    
    # retrieves tag names
    say $tc->get_all_tags;                         # 'foo'
    
    # retrieve values for a specific tag
    say join(',',sort $tc->get_tag_values('foo')); # 'bar,baz';
    
    
    # deletes all values for a tag(key)
    $tc->remove_tag('values');
    # check tags (predicate)
    $tc->has_tag('values');     # undef
    
    # replace tag values
    $tc->set_tag_values('foo', (1,2));
    say join(',',sort $tc->get_tag_values('foo')); # '1,2'

    $tc->add_tag_values('foo', qw(3 4));
    say join(',',sort $tc->get_tag_values('foo')); # '1,2,3,4'


=head1 DESCRIPTION

A Role that acts as a simple tag collection.  

=head1 SUBROUTINES/METHODS

Any consumer of this role will have the following:

=head1 DIAGNOSTICS

<TODO>
A list of every error and warning message that the module can generate
(even the ones that will "never happen"), with a full explanation of each
problem, one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

None

=head1 DEPENDENCIES

None

=head1 INCOMPATIBILITIES

None

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

User feedback is an integral part of the evolution of this and other Biome and
BioPerl modules. Send your comments and suggestions preferably to one of the
BioPerl mailing lists. Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

Patches are always welcome.

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and reponsive
experts will be able look at the problem and quickly address it. Please include
a thorough description of the problem with code and data examples if at all
possible.

=head2 Reporting Bugs

Preferrably, Biome bug reports should be reported to the GitHub Issues bug
tracking system:

  http://github.com/cjfields/biome/issues

Bugs can also be reported using the BioPerl bug tracking system, submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 FREQUENTLY ASKED QUESTIONS

None yet.

=head1 COMMON USAGE MISTAKES

None known.

=head1 SEE ALSO

L<Biome>
L<Biome::Role>

=head1 (DISCLAIMER OF) WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

The core BioPerl team.

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
