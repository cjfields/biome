# Let the code begin...
package Biome::Annotation::SimpleValue;

use Biome;
use namespace::autoclean;
use Method::Signatures;

with 'Biome::Role::Annotate' => {
    'data_slots'        => [qw(value term)]
};

has '+DEFAULT_CB' => (
    default => sub {sub { $_[0]->value}},
    lazy    => 1
    );

method as_text () {
    return "Value: ".$self->value;
}

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__

# $Id: SimpleValue.pm 15549 2009-02-21 00:48:48Z maj $
#
# BioPerl module for Bio::Annotation::SimpleValue
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

Bio::Annotation::SimpleValue - A simple scalar

=head1 SYNOPSIS

   use Bio::Annotation::SimpleValue;
   use Bio::Annotation::Collection;

   my $col = Bio::Annotation::Collection->new();
   my $sv = Bio::Annotation::SimpleValue->new(-value => 'someval');
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

=head1 AUTHOR  - Ewan Birney 

Email birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

=head2 new

 Title   : new
 Usage   : my $sv = Bio::Annotation::SimpleValue->new();
 Function: Instantiate a new SimpleValue object
 Returns : Bio::Annotation::SimpleValue object
 Args    : -value    => $value to initialize the object data field [optional]
           -tagname  => $tag to initialize the tagname [optional]

=cut

=head1 Annotate Role functions

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
 Returns : hashrf
 Args    : none

=cut

=head2 tagname

 Title   : tagname
 Usage   : $obj->tagname($newval)
 Function: Get/set the tagname for this annotation value.
           Setting this is optional. If set, it obviates the need to
           provide a tag to AnnotationCollection when adding this
           object.
 Example :
 Returns : value of tagname (a scalar)
 Args    : new value (a scalar, optional)

=cut

=head1 Specific accessors for SimpleValue

=cut

=head2 value

 Title   : value
 Usage   : $obj->value($newval)
 Function: Get/Set the value for simplevalue
 Returns : value of value
 Args    : newvalue (optional)

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
