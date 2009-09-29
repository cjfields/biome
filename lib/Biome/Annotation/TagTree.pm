package Biome::Annotation::TagTree;

use 5.010;
use Biome;
use Moose::Util::TypeConstraints;
use Data::Stag ();

with 'Biome::Role::Annotate';

subtype 'VALID_TAGTREE_FORMAT'
    => as 'Str'
    => where {$_ =~ /(?:xml|indent|sxpr|perl|itext)/ixmso};

# data stag instance
subtype 'Biome::StagI'
    => as class_type('Data::Stag::StagI');

coerce 'Biome::StagI'
    => from 'Biome::Annotation::TagTree'
        => via {$_->node->duplicate }
    => from 'Data::Stag::StagI'
        => via {$_->duplicate }  # TODO: this isn't working for some reason...
    => from 'Str'
        => via {
            # we have to munge data here, as we have no idea what the format
            # is expected to be; for now assuming itext
            my $format;
            given ($_) {
                when    (/[^\n]+\s:\s/) { $format = 'itext' }
                when    (/^</)          { $format = 'xml'   }
                when    (/^'\(/)        { $format = 'sxpr'  }
                when    (/^\[/)         { $format = 'perl'  }
                default                 { $format = 'indent'}
            }
            Data::Stag->from( $format, $_ )
            }
    => from 'ArrayRef'
        => via { Data::Stag->nodify($_) }
    ;
    
has '+DEFAULT_CB' => (
    default => sub {sub { $_[0]->value || '' }},
    lazy    => 1
    );

sub as_text {
    my ($self) = @_;
    return "TagTree: " . $self->value;
}

# we should probably allow for other serializable backends, such as JSON, XML,
# YAML, a simple hash tree, etc.  This works for now.

has 'node' => (
    is          => 'rw',
    isa         => 'Biome::StagI',
    default     => sub { Data::Stag->new() },
    predicate   => 'has_node',
    lazy        => 1,
    handles     => [qw(element data children subnodes get find findnode findval
                    addchild add set unset free hash pairs qmatch tnodes
                    ntnodes get_all_values duplicate)],
    coerce      => 1,
    init_arg    => 'value',
);

# TODO: value is not a first-class attribute (it is a method here).
# Can we shadow 'alias' attributes?

sub value {
    my ($self, $value) = @_;
    if (defined $value) {
        $self->node($value); # coercions shoud catch any variants
    }
    my $format = $self->tagformat;
    $self->node->$format;
}

has 'tagformat' => (
    is          => 'rw',
    isa         => 'VALID_TAGTREE_FORMAT',
    default     => 'itext'
);

no Biome;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;

1;

__END__

# $Id: TagTree.pm 11693 2007-09-17 20:54:04Z cjfields $
#
# BioPerl module for Bio::Annotation::TagTree
#
# Cared for Chris Fields
#
# You may distribute this module under the same terms as perl itself.
# Refer to the Perl Artistic License (see the license accompanying this
# software package, or see http://www.perl.com/language/misc/Artistic.html)
# for the terms under which you may use, modify, and redistribute this module.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# POD documentation - main docs before the code

=head1 NAME

Bio::Annotation::TagTree - AnnotationI with tree-like hierarchal key-value
relationships ('structured tags') that can be represented as simple text.

=head1 SYNOPSIS

   use Bio::Annotation::TagTree;
   use Bio::Annotation::Collection;

   my $col = Bio::Annotation::Collection->new();

   # data structure can be an array reference with a data structure
   # corresponding to that defined by Data::Stag:

   my $sv = Bio::Annotation::TagTree->new(-tagname => 'mytag1',
                                          -value => $data_structure);
   $col->add_Annotation($sv);

   # regular text passed is parsed based on the tagformat().
   my $sv2 = Bio::Annotation::TagTree->new(-tagname => 'mytag2',
                                          -tagformat => 'xml',
                                          -value => $xmltext);
   $col->add_Annotation($sv2);

=head1 DESCRIPTION

This takes tagged data values and stores them in a hierarchal structured
element-value hierarchy (complements of Chris Mungall's Data::Stag module). Data
can then be represented as text using a variety of output formats (indention,
itext, xml, spxr). Furthermore, the data structure can be queried using various
means. See L<Data::Stag> for details.

Data passed in using value() or the '-value' parameter upon instantiation
can either be:

1) an array reference corresponding to the data structure for Data::Stag;

2) a text string in 'xml', 'itext', 'spxr', or 'indent' format. The default
format is 'xml'; this can be changed using tagformat() prior to using value() or
by passing in the proper format using '-tagformat' upon instantiation;

3) another Bio::Annotation::TagTree or Data::Stag node instance.  In both cases
a deep copy (duplicate) of the instance is generated.

Beyond checking for an array reference no format guessing occurs (so, for
roundtrip tests ensure that the IO formats correspond). For now, we recommend
when using text input to set tagformat() to one of these formats prior to data
loading to ensure the proper Data::Stag parser is selected. After data loading,
the tagformat() can be changed to change the text string format returned by
value(). (this may be rectified in the future)

This Annotation type is fully BioSQL compatible and could be considered a
temporary replacement for nested Bio::Annotation::Collections, at least until
BioSQL and bioperl-db can support nested annotation collections.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists. Your participation is much appreciated.

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
the bugs and their resolution.  Bug reports can be submitted via
or the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR 

Chris Fields

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal
methods are usually preceded with a _

=cut

=head1 AnnotationI implementing functions

=cut

=head2 as_text

 Title   : as_text
 Usage   : my $text = $obj->as_text
 Function: return the string "Value: $v" where $v is the value
 Returns : string
 Args    : none

=cut

=head2 display_text

 Title   : display_text
 Usage   : my $str = $ann->display_text();
 Function: returns a string. Unlike as_text(), this method returns a string
           formatted as would be expected for the specific implementation.

           One can pass a callback as an argument which allows custom text
           generation; the callback is passed the current instance and any text
           returned
 Example :
 Returns : a string
 Args    : [optional] callback

=cut

=head2 hash_tree

 Title   : hash_tree
 Usage   : my $hashtree = $value->hash_tree
 Function: For supporting the AnnotationI interface just returns the value
           as a hashref with the key 'value' pointing to the value
           Maybe reimplement using Data::Stag::hash()?
 Returns : hashrf
 Args    : none

=cut

=head2 tagname

 Title   : tagname
 Usage   : $obj->tagname($newval)
 Function: Get/set the tag name for this annotation value.

           Setting this is optional. If set, it obviates the need to provide
           a tag to AnnotationCollection when adding this object.
 Example :
 Returns : value of tag name (a scalar)
 Args    : new value (a scalar, optional)

=cut

=head1 Specific accessors for TagTree

=cut

=head2 value

 Title   : value
 Usage   : $obj->value($newval)
 Function: Get/set the value for this annotation.
 Returns : value of value
 Args    : newvalue (optional)

=cut

=head2 new

 Title   : new
 Usage   : my $sv = Bio::Annotation::TagTree->new();
 Function: Instantiate a new TagTree object
 Returns : Bio::Annotation::TagTree object
 Args    : -value => $value to initialize the object data field [optional]
           -tagname => $tag to initialize the tagname [optional]
           -tagformat => format for output [optional]
                      (types 'xml', 'itext', 'sxpr', 'indent', default = 'itext')
           -node => Data::Stag node or Bio::Annotation::TagTree instance

=cut

=head2 tagformat

 Title   : tagformat
 Usage   : $obj->tagformat($newval)
 Function: Get/set the output tag format for this annotation.
 Returns : value of tagformat
 Args    : newvalue (optional) - format for the data passed into value
           must be of values 'xml', 'indent', 'sxpr', 'itext', 'perl'

=cut

=head2 node

 Title   : node
 Usage   : $obj->node()
 Function: Get/set the topmost Data::Stag node used for this annotation.  
 Returns : Data::Stag node implementation
           (default is Data::Stag::StagImpl)
 Args    : (optional) Data::Stag node implementation
           (optional)'copy' => flag to create a copy of the node

=cut

=head2 clone_node

 Title   : clone_node
 Usage   : my $copy = $obj->clone_node()
 Function: Get/set the topmost Data::Stag node used for this annotation.  
 Returns : copy of whatever is in node()
 Args    : none

=cut

=head2 Data::Stag convenience methods

Because Data::Stag uses blessed arrays and the core Bioperl class uses blessed
hashes, TagTree uses an internal instance of a Data::Stag node for data storage.
Therefore the following methods actually delegate to the Data:::Stag internal
instance.

For consistency (since one could recursively check child nodes), methods retain
the same names as Data::Stag. Also, no 'magic' (AUTOLOAD'ed) methods are
employed, simply b/c full-fledged Data::Stag functionality can be attained by
grabbing the Data::Stag instance using node().

=head2 element

 Title   : element
 Usage   :
 Function: Returns the element name (key name) for this node
 Example :
 Returns : scalar
 Args    : none

=cut

=head2 data

 Title   : data
 Usage   :
 Function: Returns the data structure (array ref) for this node
 Example :
 Returns : array ref
 Args    : none

=cut

=head2 children

 Title   : children
 Usage   :
 Function: Get the top-level array of Data::Stag nodes or (if the top level is
           a terminal node) a scalar value.

           This is similar to StructuredValue's get_values() method, with the
           key difference being instead of array refs and scalars you get either
           Data::Stag nodes or the value for this particular node.

           For consistency (since one could recursively check nodes),
           we use the same method name as Data::Stag children().
 Example :
 Returns : an array
 Args    : none

=cut

=head2 subnodes

 Title   : subnodes
 Usage   :
 Function: Get the top-level array of Data::Stag nodes.  Unlike children(),
           this only returns an array of nodes (if this is a terminal node,
           no value is returned)
 Example :
 Returns : an array of nodes
 Args    : none

=cut

=head2 get

 Title   : get
 Usage   : 
 Function: Returns the nodes or value for the named element or path
 Example : 
 Returns : returns array of nodes or a scalar (if node is terminal)
           dependent on wantarray
 Args    : none

=cut

=head2 find

 Title   : find
 Usage   : 
 Function: Recursively searches for and returns the nodes or values for the
           named element or path
 Example : 
 Returns : returns array of nodes or scalars (for terminal nodes)
 Args    : none

=cut

=head2 findnode

 Title   : findnode
 Usage   : 
 Function: Recursively searches for and returns a list of nodes
           of the given element path
 Example : 
 Returns : returns array of nodes
 Args    : none

=cut

=head2 findval

 Title   : findval
 Usage   : 
 Function: 
 Example : 
 Returns : returns array of nodes or values
 Args    : none

=cut

=head2 addchild

 Title   : addchild
 Usage   : $struct->addchild(['name' => [['foo'=> 'bar1']]]);
 Function: add new child node to the current node.  One can pass in a node, TagTree,
           or data structure; for instance, in the above, this would translate
           to (in XML):

           <name>
             <foo>bar1</foo>
           </name>

 Returns : node
 Args    : first arg = element name
           all other args are added as tag-value pairs

=cut

=head2 add

 Title   : add
 Usage   : $struct->add('foo', 'bar1', 'bar2', 'bar3');
 Function: add tag-value nodes to the current node.  In the above, this would
           translate to (in XML):
           <foo>bar1</foo>
           <foo>bar2</foo>
           <foo>bar3</foo>
 Returns : 
 Args    : first arg = element name
           all other args are added as tag-value pairs

=cut

=head2 set

 Title   : set
 Usage   : $struct->set('foo','bar');
 Function: sets a single tag-value pair in the current node.  Note this
           differs from add() in that this replaces any data already present
 Returns : node
 Args    : first arg = element name
           all other args are added as tag-value pairs

=cut

=head2 unset

 Title   : unset
 Usage   : $struct->unset('foo');
 Function: unsets all key-value pairs of the passed element from the
           current node
 Returns : node
 Args    : element name

=cut

=head2 free

 Title   : free
 Usage   : $struct->free
 Function: removes all data from the current node
 Returns : 
 Args    : 

=cut

=head2 hash

 Title   : hash
 Usage   : $struct->hash;
 Function: turns the tag-value tree into a hash, all data values are array refs
 Returns : hash
 Args    : first arg = element name
           all other args are added as tag-value pairs

=cut

=head2 pairs

 Title   : pairs
 Usage   : $struct->pairs;
 Function: turns the tag-value tree into a hash, all data values are scalar
 Returns : hash
 Args    : first arg = element name
           all other args are added as tag-value pairs, note that duplicates
           will be lost

=cut

=head2 qmatch

 Title    : qmatch
 Usage    : @persons = $s->qmatch('person', ('name'=>'fred'));
 Function : returns all elements in the node tree which match the
            element name and the key-value pair
 Returns  : Array of nodes
 Args     : return-element str, match-element str, match-value str

=cut

=head2 tnodes

 Title    : tnodes
 Usage    : @termini = $s->tnodes;
 Function : returns all terminal nodes below this node
 Returns  : Array of nodes
 Args     : return-element str, match-element str, match-value str

=cut

=head2 ntnodes

 Title    : ntnodes
 Usage    : @termini = $s->ntnodes;
 Function : returns all nonterminal nodes below this node
 Returns  : Array of nodes
 Args     : return-element str, match-element str, match-value str

=cut

=head2 StructureValue-like methods

=cut

=head2 get_all_values

 Title    : get_all_values
 Usage    : @termini = $s->get_all_values;
 Function : returns all terminal node values
 Returns  : Array of values
 Args     : return-element str, match-element str, match-value str

This is meant to emulate the values one would get from StructureValue's
get_all_values() method. Note, however, using this method dissociates the
tag-value relationship (i.e. you only get the value list, no elements)

=cut

