
package Bio::Moose::Role::Annotation;

use Moose::Role;



=head2 as_text

 Title   : as_text
 Usage   :
 Function: single text string, without newlines representing the
           annotation, mainly for human readability. It is not aimed
           at being able to store/represent the annotation.
 Example :
 Returns : a string
 Args    : none


=cut

requires 'as_text';


=head2 display_text

 Title   : display_text
 Usage   : my $str = $ann->display_text();
 Function: returns a string. Unlike as_text(), this method returns a string
           formatted as would be expected for the specific implementation.

           Implementations should allow passing a callback as an argument which
           allows custom text generation; the callback will be passed the
           current implementation.

           Note that this is meant to be used as a simple representation
           of the annotation data but probably shouldn't be used in cases
           where more complex comparisons are needed or where data is
           stored.
 Example :
 Returns : a string
 Args    : [optional] callback

=cut


requires 'display_text';

=head2 hash_tree

 Title   : hash_tree
 Usage   :
 Function: should return an anonymous hash with "XML-like" formatting
 Example :
 Returns : a hash reference
 Args    : none


=cut


require 'hash_tree';

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


require 'tagname';


no Moose::Role;

1;
