package Biome::Role::Root;

use 5.014;
use Moose::Role;
use Moose::Exception;
use Class::Load ();
use Biome::Util ();
use Method::Signatures;

#__PACKAGE__->meta->error_class('Biome::Root::Error');
# run BEGIN block to check for exception class, default to light output?
# or should that go in Biome?

# Now separating verbosity and strictness/exceptions. Global settings override local
# ones, but this can be overridden in child classes

has 'verbose' => (
    is   => 'rw',
    isa  => 'Bool',
    default => $ENV{BIOME_DEBUG} || 0
    );

# strictness level; setting to True converts warnings to exceptions
has 'strict' => (
    is      => 'rw',
    isa     => 'Int',
    default => $ENV{BIOME_STRICT} || 0
    );

method warn ($string) {
    my $strict = $self->strict || $self->verbose;

    my $header = "\n--------------------- WARNING ---------------------\nMSG: ";
    my $footer =   "---------------------------------------------------\n";
    if ($strict >= 2) {
        $self->throw($string);
    }
    elsif ($strict <= -1) {
        return;
    }
    elsif ($strict == 1) {
        CORE::warn $header. $string. "\n". $self->meta->stack_trace_dump. $footer;
        return;
    }

    CORE::warn $header. $string. "\n". $footer;
}

method throw ($text, $class = '', $value?) {
    Biome::Util::throw_exception($class, message =>  $text);
}

method deprecated () {
    my $prev = (caller(0))[3];
    my $msg = "Use of ".$prev."() is deprecated";
    # delegate to either warn or throw based on whether a version is given
    $self->warn($msg);
}

method throw_not_implemented {
    my $message = $self->_not_implemented_msg;
    $self->throw(text => $message); # no class yet for unimplemented methods
}

method warn_not_implemented () {
    my $message = $self->_not_implemented_msg;
    $self->warn( $message );
}

method _not_implemented_msg () {
    my $pkg = ref $self;
    my $meth = (caller(2))[3]; # may not work as intended here;
    my $msg =<<EOD_NOT_IMP;
Abstract method \"$meth\" is not implemented by package $pkg.
This is not your fault - author of $pkg should be blamed!
EOD_NOT_IMP
    return $msg;
}

method debug (@msgs) {
    if ($self->verbose) {
        CORE::warn @msgs;
    }
}

# simple clone; calls meta class clone_object. This may be replaced by
# MooseX::Clone functionality (so we have more introspection and control over
# what is and what isn't cloned, and so we can do recursive cloning)

# until then if needed we can override this in inheriting classes for recursive
# cloning

method clone (@p) {
    my $params = $self->BUILDARGS(@p);
    $self->meta->clone_object($self, %$params);
}

# cleanup methods needed?  These should probably go into the meta class

# Module::Load::Conditional caches already loaded modules
method load_modules (@mods) {
    Class::Load::load_class($_) for @mods;
}

method load_module ($mod) {
    Class::Load::load_class($mod);
}

1;

__END__

=head2 verbose

 Title   : verbose
 Usage   : $self->verbose(1)
 Function: Sets verbose flag for debugging output
 Returns : The current verbosity setting (0 or 1)
 Args    : 0 or 1 (Boolean value)
 Status  : Unstable

=cut

=head2 strict

 Title   : strict
 Usage   : $self->strict(1)
 Function: Sets strictness level for ->warn
           -1 = no warnings
            0 = standard, small warning
            1 = warning with stack trace
            2 = converts warning to an exception
 Returns : The current verbosity setting (integer between -1 to 2)
 Args    : -1,0,1 or 2
 Status  : Unstable

=cut
