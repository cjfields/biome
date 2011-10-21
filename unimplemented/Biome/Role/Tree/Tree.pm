package Biome::Role::Tree::Tree;

use Biome::Role;

# tag methods to be pulled out into another Role (maybe a lightweight
# annotation collection)
requires qw(
    get_Nodes
    get_root_Node
    set_root_Node
    get_leaf_Nodes
    get_lineage_Nodes
    number_Nodes
    find_Nodes
    find_Node_by_id
    remove_Node

    total_branch_length
    subtree_length
    height
    as_text
    id
    score

    splice
    get_lca
    merge_lineage
    contract_linear_paths
    is_binary
    is_monophyletic
    is_paraphyletic
    force_binary
    simplify_to_leaves_string
    distance
    reroot
    reroot_at_midpoint
    move_ids_to_bootstrap
);

# as_text may be left out

no Biome::Role;

1;

__END__

# $Id: TreeI.pm 15549 2009-02-21 00:48:48Z maj $
#
# BioPerl module for Bio::Tree::TreeI
#
# Please direct questions and support issues to <bioperl-l@bioperl.org>
#
# Cared for by Jason Stajich <jason@bioperl.org>
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code


# Let the code begin...

=head1 NAME

Bio::Tree::TreeI - A Tree object suitable for lots of things, designed
  originally for Phylogenetic Trees.

=head1 SYNOPSIS

  # get a Bio::Tree::TreeI somehow
  # like from a TreeIO
  my $treeio = Bio::TreeIO->new(-format => 'newick', -file => 'treefile.dnd');
  my $tree   = $treeio->next_tree;
  my @nodes  = $tree->get_nodes;
  my @leaves = $tree->get_leaf_nodes;
  my $root   = $tree->get_root_node;

=head1 DESCRIPTION

This object holds a pointer to the Root of a Tree which is a
Bio::Tree::NodeI.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support

Please direct usage questions or support issues to the mailing list:

L<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and
reponsive experts will be able look at the problem and quickly
address it. Please include a thorough description of the problem
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Jason Stajich

Email jason@bioperl.org

=head1 CONTRIBUTORS

Aaron Mackey, amackey@virginia.edu
Elia Stupka,  elia@fugu-sg.org
Sendu Bala,   bix@sendu.me.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

=head2 get_nodes

 Title   : get_nodes
 Usage   : my @nodes = $tree->get_nodes()
 Function: Return list of Tree::NodeI objects
 Returns : array of Tree::NodeI objects
 Args    : (named values) hash with one value
           order => 'b|breadth' first order or 'd|depth' first order

=cut

=head2 get_root_node

 Title   : get_root_node
 Usage   : my $node = $tree->get_root_node();
 Function: Get the Top Node in the tree, in this implementation
           Trees only have one top node.
 Returns : Bio::Tree::NodeI object
 Args    : none

=cut

=head2 number_nodes

 Title   : number_nodes
 Usage   : my $size = $tree->number_nodes
 Function: Find the number of nodes in the tree.
 Returns : int
 Args    : none

=cut

=head2 total_branch_length

 Title   : total_branch_length
 Usage   : my $size = $tree->total_branch_length
 Function: Returns the sum of the length of all branches
 Returns : integer
 Args    : none

=cut

=head2 height

 Title   : height
 Usage   : my $height = $tree->height
 Function: Gets the height of tree - this LOG_2($number_nodes)
           WARNING: this is only true for strict binary trees.  The TreeIO
           system is capable of building non-binary trees, for which this
           method will currently return an incorrect value!!
 Returns : integer
 Args    : none

=cut

=head2 id

 Title   : id
 Usage   : my $id = $tree->id();
 Function: An id value for the tree
 Returns : scalar
 Args    :


=cut

=head2 score

 Title   : score
 Usage   : $obj->score($newval)
 Function: Sets the associated score with this tree
           This is a generic slot which is probably best used
           for log likelihood or other overall tree score
 Returns : value of score
 Args    : newvalue (optional)


=cut

=head2 get_leaf_nodes

 Title   : get_leaf_nodes
 Usage   : my @leaves = $tree->get_leaf_nodes()
 Function: Returns the leaves (tips) of the tree
 Returns : Array of Bio::Tree::NodeI objects
 Args    : none


=cut

=head2 Methods for associating Tag/Values with a Tree

These methods associate tag/value pairs with a Tree

=head2 set_tag_value

 Title   : set_tag_value
 Usage   : $tree->set_tag_value($tag,$value)
           $tree->set_tag_value($tag,@values)
 Function: Sets a tag value(s) to a tree. Replaces old values.
 Returns : number of values stored for this tag
 Args    : $tag   - tag name
           $value - value to store for the tag

=cut

=head2 add_tag_value

 Title   : add_tag_value
 Usage   : $tree->add_tag_value($tag,$value)
 Function: Adds a tag value to a tree
 Returns : number of values stored for this tag
 Args    : $tag   - tag name
           $value - value to store for the tag


=cut

=head2 remove_tag

 Title   : remove_tag
 Usage   : $tree->remove_tag($tag)
 Function: Remove the tag and all values for this tag
 Returns : boolean representing success (0 if tag does not exist)
 Args    : $tag - tagname to remove


=cut

=head2 remove_all_tags

 Title   : remove_all_tags
 Usage   : $tree->remove_all_tags()
 Function: Removes all tags
 Returns : None
 Args    : None


=cut

=head2 get_all_tags

 Title   : get_all_tags
 Usage   : my @tags = $tree->get_all_tags()
 Function: Gets all the tag names for this Tree
 Returns : Array of tagnames
 Args    : None


=cut

=head2 get_tag_values

 Title   : get_tag_values
 Usage   : my @values = $tree->get_tag_values($tag)
 Function: Gets the values for given tag ($tag)
 Returns : Array of values or empty list if tag does not exist
 Args    : $tag - tag name


=cut

=head2 has_tag

 Title   : has_tag
 Usage   : $tree->has_tag($tag)
 Function: Boolean test if tag exists in the Tree
 Returns : Boolean
 Args    : $tag - tagname


=cut

