# Let the code begin...
package Biome::Annotation::Comment;

use Biome;

with 'Biome::Role::Annotate' => {
    'data_slots' => [qw(text type)]
};

has '+DEFAULT_CB' => (
    default => sub { sub { $_[0]->text || ''} },
    lazy    => 1
    );

sub as_text{
    my ($self) = @_;
    return "Comment: ".$self->text;
}

*value = \&text;

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__

# $Id: Comment.pm 15549 2009-02-21 00:48:48Z maj $
#
# BioPerl module for Bio::Annotation::Comment
#
# Please direct questions and support issues to <bioperl-l@bioperl.org>
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Annotation::Comment - A comment object, holding text

=head1 SYNOPSIS


    $comment = Bio::Annotation::Comment->new();
    $comment->text("This is the text of this comment");
    $annotation->add_Annotation('comment', $comment);


=head1 DESCRIPTION

A holder for comments in annotations, just plain text. This is a very simple
object, and justifiably so.

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

=head2 new

 Title   : new
 Usage   : $comment = Bio::Annotation::Comment->new( '-text' => 'some text for this comment');
 Function: This returns a new comment object, optionally with
           text filed
 Example :
 Returns : a Bio::Annotation::Comment object
 Args    : a hash with -text optionally set

=cut

=head1 Annotate Role functions

=cut

=head2 as_text

 Title   : as_text
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

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
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

=head2 tagname

 Title   : tagname
 Usage   : $obj->tagname($newval)
 Function: Get/set the tagname for this annotation value.

           Setting this is optional. If set, it obviates the need to
           provide a tag to Bio::AnnotationCollectionI when adding
           this object. When obtaining an AnnotationI object from the
           collection, the collection will set the value to the tag
           under which it was stored unless the object has a tag
           stored already.

 Example :
 Returns : value of tagname (a scalar)
 Args    : new value (a scalar, optional)

=cut

=head1 Specific accessors for Comments

=cut

=head2 text

 Title   : text
 Usage   : $value = $self->text($newval)
 Function: get/set for the text field. A comment object
           just holds a single string which is accessible through
           this method
 Example :
 Returns : value of text
 Args    : newvalue (optional)


=cut

=head2 value

 Title   : value
 Usage   : $value = $self->value($newval)
 Function: Alias of the 'text' method
 Example :
 Returns : value of text
 Args    : newvalue (optional)

=cut

=head2 type

 Title   : type
 Usage   : $value = $self->type($newval)
 Function: get/set for the comment type field.  The comment type
           is normally found as a subfield within comment sections
           in some files, such as SwissProt
 Example :
 Returns : value of text
 Args    : newvalue (optional)

=cut
