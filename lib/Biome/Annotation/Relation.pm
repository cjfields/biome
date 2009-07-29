package Bio::Annotation::Relation;

use Bio::Moose;

with 'Bio::Moose::Role::Annotate';

sub as_text{
   my ($self) = @_;
   return $self->type." to  ".$self->to->id;
}

has '+DEFAULT_CB' => (
    default => sub {sub { return $_[0]->type." to  ".$_[0]->to->id }},
    lazy    => 1
    );

has [qw(type to)] => (
    is          => 'rw',
    isa         => 'Str'
);

# TODO: NYI. Thinking this should be a role...
#has 'tag_term' => (
#    is          => 'rw',
#    does        => 'Bio::Moose::Role::OntologyTerm'
#);

1;

__END__

# $Id: Relation.pm 14708 2008-06-10 00:08:17Z heikki $
#
# BioPerl module for Bio::Annotation::Relation
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by bioperl <bioperl-l@bioperl.org>
#
# Copyright bioperl
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Annotation::Relation - Relationship (pairwise) with other objects SeqI and NodeI;

=head1 SYNOPSIS

   use Bio::Annotation::Relation;
   use Bio::Annotation::Collection;

   my $col = Bio::Annotation::Collection->new();
   my $sv = Bio::Annotation::Relation->new(-type => "paralogy" -to => "someSeqI");
   $col->add_Annotation('tagname', $sv);

=head1 DESCRIPTION

Scalar value annotation object

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
the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR  - Mira Han

Email mirhan@indiana.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

=head2 new

 Title   : new
 Usage   : my $sv = Bio::Annotation::Relation->new();
 Function: Instantiate a new Relation object
 Returns : Bio::Annotation::Relation object
 Args    : -type    => $type of relation [optional]
           -to     => $obj which $self is in relation to [optional]
           -tagname  => $tag to initialize the tagname [optional]
           -tag_term => ontology term representation of the tag [optional]

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
           formatted as would be expected for te specific implementation.

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
 Returns : hashrf
 Args    : none

=cut

=head2 tag_name

 Title   : tag_name
 Usage   : $obj->tag_name($newval)
 Function: Get/set the tag name for this annotation value.

           Setting this is optional. If set, it obviates the need to
           provide a tag to AnnotationCollection when adding this
           object.

 Example :
 Returns : value of tagname (a scalar)
 Args    : new value (a scalar, optional)

=cut

=head1 Specific accessors for Relation

=cut

=head2 type 

 Title   : type 
 Usage   : $obj->type($newval)
 Function: Get/Set the type
 Returns : type of relation
 Args    : newtype (optional)

=cut

=head2 to

 Title   : to
 Usage   : $obj->to($newval)
 Function: Get/Set the object which $self is in relation to
 Returns : the object which the relation applies to
 Args    : new target object (optional)

=cut

=head2 tag_term

 Title   : tag_term
 Usage   : $obj->tag_term($newval)
 Function: Get/set the L<Bio::Ontology::TermI> object representing
           the tag name.

           This is so you can specifically relate the tag of this
           annotation to an entry in an ontology. You may want to do
           this to associate an identifier with the tag, or a
           particular category, such that you can better match the tag
           against a controlled vocabulary.

           This accessor will return undef if it has never been set
           before in order to allow this annotation to stay
           light-weight if an ontology term representation of the tag
           is not needed. Once it is set to a valid value, tagname()
           will actually delegate to the name() of this term.

 Example :
 Returns : a L<Bio::Ontology::TermI> compliant object, or undef
 Args    : on set, new value (a L<Bio::Ontology::TermI> compliant
           object or undef, optional)


=cut