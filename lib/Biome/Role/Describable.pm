package Biome::Role::Describable;

use Biome::Role;

#maybe move the default to builder method
has [qw(display_name description)] => (
    is          => 'rw',
    isa         => 'Str'
   );

no Biome::Role;

1;

__END__

=head2 display_name

 Title   : display_name
 Usage   : $string    = $obj->display_name()
 Function: A string which is what should be displayed to the user
           the string should have no spaces (ideally, though a cautious
           user of this interface would not assumme this) and should be
           less than thirty characters (though again, double checking 
           this is a good idea)
 Returns : A scalar
 Status  : Stable, may be reimplemented

=head2 description

 Title   : description
 Usage   : $string    = $obj->description()
 Function: A text string suitable for displaying to the user a 
           description. This string is likely to have spaces, but
           should not have any newlines or formatting - just plain
           text. The string should not be greater than 255 characters
           and clients can feel justified at truncating strings at 255
           characters for the purposes of display
 Returns : A scalar
 Status  : Stable

=cut