package Biome::Role::Root;

use 5.014;
use Moose::Role;
use Moose::Exception;
use Class::Load ();
use Moose::Util;
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

method throw ($text, $class = 'Legacy', $value?) {
    Moose::Util::throw_exception($class, message =>  $text);
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

=head2 rearrange

 Usage   : $object->_rearrange( array_ref, list_of_arguments)
 Purpose : Rearranges named parameters to requested order.
 Example : $self->_rearrange([qw(SEQUENCE ID DESC)],@param);
         : Where @param = (sequence => $s,
	     :                 desc     => $d,
	     :                 id       => $i);
 Returns : @params - an array of parameters in the requested order.
         : The above example would return ($s, $i, $d).
         : Unspecified parameters will return undef. For example, if
         :        @param = (sequence => $s);
         : the above _rearrange call would return ($s, undef, undef)
 Argument: $order : a reference to an array which describes the desired
         :          order of the named parameters.
         : @param : an array of parameters, either as a list (in
         :          which case the function simply returns the list),
         :          or as an associative array with hyphenated tags
         :          (in which case the function sorts the values
         :          according to @{$order} and returns that new array.)
	     :	      The tags can be upper, lower, or mixed case
         :          but they must start with a hyphen (at least the
         :          first one should be hyphenated.)
 Source  : This function was taken from CGI.pm, written by Dr. Lincoln
         : Stein, and adapted for use in Bio::Seq by Richard Resnick and
         : then adapted for use in Bio::Root::Object.pm by Steve Chervitz,
         : then migrated into Bio::Root::RootI.pm by Ewan Birney.
 Comments: Uppercase tags are the norm,
         : (SAC)
         : This method may not be appropriate for method calls that are
         : within in an inner loop if efficiency is a concern.
         :
         : Parameters can be specified using any of these formats:
         :  @param = (-name=>'me', -color=>'blue');
         :  @param = (-NAME=>'me', -COLOR=>'blue');
         :  @param = (-Name=>'me', -Color=>'blue');
         :  @param = ('me', 'blue');
         : A leading hyphenated argument is used by this function to
         : indicate that named parameters are being used.
         : Therefore, the ('me', 'blue') list will be returned as-is.
         :
	     : Note that Perl will confuse unquoted, hyphenated tags as
         : function calls if there is a function of the same name
         : in the current namespace:
         :    -name => 'foo' is interpreted as -&name => 'foo'
	     :
         : For ultimate safety, put single quotes around the tag:
	     : ('-name'=>'me', '-color' =>'blue');
         : This can be a bit cumbersome and I find not as readable
         : as using all uppercase, which is also fairly safe:
	     : (-NAME=>'me', -COLOR =>'blue');
	     :
         : Personal note (SAC): I have found all uppercase tags to
         : be more managable: it involves less single-quoting,
         : the key names stand out better, and there are no method naming
         : conflicts.
         : The drawbacks are that it's not as easy to type as lowercase,
         : and lots of uppercase can be hard to read.
         :
         : Regardless of the style, it greatly helps to line
	     : the parameters up vertically for long/complex lists.
         :
         : Note that if @param is a single string that happens to start with
         : a dash, it will be treated as a hash key and probably fail to
         : match anything in the array_ref, so not be returned as normally
         : happens when @param is a simple list and not an associative array.
 Status  : Unstable (this may change into a trait for optional use)

=cut
