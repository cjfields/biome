package Bio::Tree::NodeI;

use Biome::Role;

requires qw(
    create_Node_on_branch
    add_Descendent
    each_Descendent
    remove_Descendent
    remove_all_Descendents
    get_all_Descendents
    get_Descendents
    descendent_count

    ancestor
    branch_length
    bootstrap
    description
    id
    internal_id
    id_output

    is_Leaf
    to_string
    height
    invalidate_height
    depth

    set_tag_value
    add_tag_value
    remove_tag
    remove_all_tags
    get_all_tags
    get_tag_values
    has_tag

    reverse_edge
);

# tag values to specific Role
# description in a Role already (Describe)
# combine tag methods into a common Annotatable-like Role

no Biome::Role;

1;

__END__

# $Id: Node.pm 15549 2009-02-21 00:48:48Z maj $
#
# Biome module for Bio::Role::Tree::Node
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

Bio::Role::Tree::Node - abstract Role describing a Tree Node

=head1 SYNOPSIS

    # get a Tree::Node somehow
    # like from a TreeIO
    use Bio::TreeIO;
    # read in a clustalw NJ in phylip/newick format
    my $treeio = Bio::TreeIO->new(-format => 'newick', -file => 'file.dnd');

    my $tree = $treeio->next_tree; # we'll assume it worked for demo purposes
                                   # you might want to test that it was defined

    my $rootnode = $tree->get_root_node;

    # process just the next generation
    foreach my $node ( $rootnode->each_Descendent() ) {
	print "branch len is ", $node->branch_length, "\n";
    }

    # process all the children
    my $example_leaf_node;
    foreach my $node ( $rootnode->get_all_Descendents() ) {
	if( $node->is_Leaf ) {
	    print "node is a leaf ... ";
            # for example use below
            $example_leaf_node = $node unless defined $example_leaf_node;
	}
	print "branch len is ", $node->branch_length, "\n";
    }

    # The ancestor() method points to the parent of a node
    # A node can only have one parent

    my $parent = $example_leaf_node->ancestor;

    # parent won't likely have an description because it is an internal node
    # but child will because it is a leaf

    print "Parent id: ", $parent->id," child id: ",
          $example_leaf_node->id, "\n";


=head1 DESCRIPTION

A NodeI is capable of the basic structure of building a tree and
storing the branch length between nodes.  The branch length is the
length of the branch between the node and its ancestor, thus a root
node in a Tree will not typically have a valid branch length.

Various implementations of NodeI may extend the basic functions and
allow storing of other information (like attatching a species object
or full sequences used to build a tree or alternative sequences).  If
you don't know how to extend a Bioperl object please ask, happy to
help, we would also greatly appreciate contributions with improvements
or extensions of the objects back to the Bioperl code base so that
others don't have to reinvent your ideas.


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

Aaron Mackey amackey@virginia.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

=head2 add_Descendent

 Title   : add_Descendent
 Usage   : $node->add_Descendent($node);
 Function: Adds a descendent to a node
 Returns : number of current descendents for this node
 Args    : Bio::Node::NodeI


=cut

=head2 each_Descendent

 Title   : each_Descendent
 Usage   : my @nodes = $node->each_Descendent;
 Function: all the descendents for this Node (but not their descendents
					      i.e. not a recursive fetchall)
 Returns : Array of Bio::Tree::NodeI objects
 Args    : none

=cut

=head2 Decorated Interface methods

=cut

=head2 get_all_Descendents

 Title   : get_all_Descendents($sortby)
 Usage   : my @nodes = $node->get_all_Descendents;
 Function: Recursively fetch all the nodes and their descendents
           *NOTE* This is different from each_Descendent
 Returns : Array or Bio::Tree::NodeI objects
 Args    : $sortby [optional] "height", "creation", "alpha", "revalpha",
           or a coderef to be used to sort the order of children nodes.

=cut

=head2 is_Leaf

 Title   : is_Leaf
 Usage   : if( $node->is_Leaf )
 Function: Get Leaf status
 Returns : boolean
 Args    : none

=cut

=head2 descendent_count

 Title   : descendent_count
 Usage   : my $count = $node->descendent_count;
 Function: Counts the number of descendents a node has
           (and all of their subnodes)
 Returns : integer
 Args    : none

=cut

=head2 to_string

 Title   : to_string
 Usage   : my $str = $node->to_string()
 Function: For debugging, provide a node as a string
 Returns : string
 Args    : none


=cut

=head2 height

 Title   : height
 Usage   : my $len = $node->height
 Function: Returns the height of the tree starting at this
           node.  Height is the maximum branchlength to get to the tip.
 Returns : The longest length (weighting branches with branch_length) to a leaf
 Args    : none

=cut

=head2 depth

 Title   : depth
 Usage   : my $len = $node->depth
 Function: Returns the depth of the tree starting at this
           node.  Depth is the distance from this node to the root.
 Returns : The branch length to the root.
 Args    : none

=cut

=head2 Get/Set methods

=cut

=head2 branch_length

 Title   : branch_length
 Usage   : $obj->branch_length()
 Function: Get/Set the branch length
 Returns : value of branch_length
 Args    : newvalue (optional)


=cut

=head2 id

 Title   : id
 Usage   : $obj->id($newval)
 Function: The human readable identifier for the node
 Returns : value of human readable id
 Args    : newvalue (optional)


=cut

=head2 internal_id

 Title   : internal_id
 Usage   : my $internalid = $node->internal_id
 Function: Returns the internal unique id for this Node
 Returns : unique id
 Args    : none

=cut

=head2 description

 Title   : description
 Usage   : $obj->description($newval)
 Function: Get/Set the description string
 Returns : value of description
 Args    : newvalue (optional)


=cut

=head2 bootstrap

 Title   : bootstrap
 Usage   : $obj->bootstrap($newval)
 Function: Get/Set the bootstrap value
 Returns : value of bootstrap
 Args    : newvalue (optional)


=cut

=head2 ancestor

 Title   : ancestor
 Usage   : my $node = $node->ancestor;
 Function: Get/Set the ancestor node pointer for a Node
 Returns : Null if this is top level node
 Args    : none

=cut

=head2 invalidate_height

 Title   : invalidate_height
 Usage   : private helper method
 Function: Invalidate our cached value of the node height in the tree
 Returns : nothing
 Args    : none

=cut

=head2 Methods for associating Tag/Values with a Node

These methods associate tag/value pairs with a Node

=head2 set_tag_value

 Title   : set_tag_value
 Usage   : $node->set_tag_value($tag,$value)
           $node->set_tag_value($tag,@values)
 Function: Sets a tag value(s) to a node. Replaces old values.
 Returns : number of values stored for this tag
 Args    : $tag   - tag name
           $value - value to store for the tag

=cut

=head2 add_tag_value

 Title   : add_tag_value
 Usage   : $node->add_tag_value($tag,$value)
 Function: Adds a tag value to a node
 Returns : number of values stored for this tag
 Args    : $tag   - tag name
           $value - value to store for the tag


=cut

=head2 remove_tag

 Title   : remove_tag
 Usage   : $node->remove_tag($tag)
 Function: Remove the tag and all values for this tag
 Returns : boolean representing success (0 if tag does not exist)
 Args    : $tag - tagname to remove


=cut

=head2 remove_all_tags

 Title   : remove_all_tags
 Usage   : $node->remove_all_tags()
 Function: Removes all tags
 Returns : None
 Args    : None


=cut

=head2 get_all_tags

 Title   : get_all_tags
 Usage   : my @tags = $node->get_all_tags()
 Function: Gets all the tag names for this Node
 Returns : Array of tagnames
 Args    : None


=cut

=head2 get_tag_values

 Title   : get_tag_values
 Usage   : my @values = $node->get_tag_values($tag)
 Function: Gets the values for given tag ($tag)
 Returns : Array of values or empty list if tag does not exist
 Args    : $tag - tag name


=cut

=head2 has_tag

 Title   : has_tag
 Usage   : $node->has_tag($tag)
 Function: Boolean test if tag exists in the Node
 Returns : Boolean
 Args    : $tag - tagname


=cut

=head2 Helper Functions

=cut

=head2 id_output

 Title   : id_output
 Usage   : my $id = $node->id_output;
 Function: Return an id suitable for output in format like newick
           so that if it contains spaces or ():; characters it is properly
           quoted
 Returns : $id string if $node->id has a value
 Args    : none


=cut

