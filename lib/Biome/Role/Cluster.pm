package Biome::Role::Cluster;

use Biome::Role; 
use Moose::Meta::Attribute::Native;

requires 'display_id';     # Identifiable
requires 'description';    # Describable
requires 'get_members';    # possibly greedy, non-specific interface, returns object
requires 'next_member';    # lazy, iteratively returns object

has 'member_map' => (
    is          => 'rw',
    isa         => 'HashRef[Any]',
);

has 'cluster_score' => (
    is          => 'rw',
    isa         => 'Num',
);

no Biome::Role;

1;

__END__

=head1 NAME

Biome::Role::Cluster - Simple role for defining a cluster or grouping of
objects.

=head1 VERSION

This documentation refers to Biome::Role::Cluster version 0.01.

=head1 SYNOPSIS

   use Biome::Role::Cluster;
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

This is a simple abstract role that defines what is the minimum expected of
consuming classes that wish to group objects based on specified properties.

Though not required, implementations are encouraged to have a lazy or memory-
efficient way for accessing instance data, for instance using a remote/local
database or using iteration. With this in mind, the default role methods simply
store the ID in a hash with a simple Bool as the value. Implementations can
cache/store the member in this hash, but it is up to the implementation to
properly disambiguate between stored instances and the simple default bool
value.

For instance, the method next_Cluster is used to iterate through the various
objects in this Cluster using an optional filter, whereas get_members may be
used to return a specific subset of objects based on object attributes.

=head1 SUBROUTINES/METHODS

=head2 display_id

 Title    : display_id
 Usage    : 
 Function : Get the display name or identifier for the cluster
 Returns  : a string
 Args     : 
 Status   :

=head2 description

 Title    : description
 Usage    : $cluster->description("POLYUBIQUITIN")
 Function : get/set for the consensus description of the cluster
 Returns  : the description string 
 Args     : Optional the description string 
 Status   :

=head2 size

 Title    : size
 Usage    : $cluster->size();
 Function : get/set for the size of the family, 
            calculated from the number of members
 Returns  : the size of the family 
 Args     :
 Status   :

=head2 cluster_score

 Title    : cluster_score
 Usage    : $cluster ->cluster_score(100);
 Function : get/set for cluster_score which
            represent the score in which the clustering
            algorithm assigns to this cluster.
 Returns  : a number
 Args     : 
 Status   :

=head2 get_members

 Title    : get_members
 Usage    : Bio::ClusterI->get_members(($seq1, $seq2));
 Function : retrieve the members of the family by some criteria, for
            example :
            
            $cluster->get_members(-species => 'homo sapiens'); 
            Will return all members if no criteria are provided.
            
 Returns  : the array of members
 Args     :
 Status   : 
 
=head2 get_member_ids

 Title    : get_members
 Usage    : Bio::ClusterI->get_member_ids();
 Function : retrieve the indicated Bio::Identifiable attribute of the family 
 Returns  : the array of members
 Args     : 
 Status   :

=head2 next_member

 Title    : get_members
 Usage    : Bio::ClusterI->get_members(($seq1, $seq2));
 Function : retrieve the indicated Bio::Identifiable attribute of the family 
 Returns  : the array of members
 Args     : 
 Status   :
 
=head1 DIAGNOSTICS

Implementation-dependent

=head1 DEPENDENCIES

Implementation-dependent

=head1 INCOMPATIBILITIES

Implementation-dependent (none known)

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

=head1 EXAMPLES

<TODO>

=head1 FREQUENTLY ASKED QUESTIONS

<TODO>

=head1 COMMON USAGE MISTAKES

<TODO>

=head1 SEE ALSO

<TODO>

=head1 (DISCLAIMER OF) WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

The original BioPerl interface author (Shawn Hoon).  

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
