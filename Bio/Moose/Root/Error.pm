package Bio::Moose::Root::Error;

use Moose;

# Some oddity with order of loading that is causing problems, likely
# Moose-related, may need to use BUILDALL

# also, Exception::Class::Base is strict re: passed arguments (throws when
# fields aren't present). This class makes it work within a Moose framework. We
# can't guarantee a non-Bio::Moose::Root::Error (beyond those already know to
# work with Moose) will work at this time.

extends qw(Moose::Object Exception::Class::Base);

sub new {
    my $class = shift;

    my $obj = $class->SUPER::new(@_);

    return $class->meta->new_object(
        __INSTANCE__ => $obj,
        @_,
    );
}

has message    => ( isa => "Str",                           is => "ro" );
has attr       => ( isa => "Moose::Meta::Attribute",        is => "ro" );
has method     => ( isa => "Moose::Meta::Method",           is => "ro" );
has metaclass  => ( isa => "Bio::Moose::Meta::Class",       is => "ro" );
has data       => ( is  => "ro" );
has line       => ( isa => "Int",                           is => "ro" );
has file       => ( isa => "Str",                           is => "ro" );
has last_error => ( isa => "Any",                           is => "ro" );

no Moose;

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

__END__

ALL POD HERE
