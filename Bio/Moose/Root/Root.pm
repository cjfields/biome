package Bio::Moose::Root::Root;
use Moose 0.79;

extends 'Moose::Object';

# run BEGIN block to check for exception class, default to light output?
# or should that go in Bio::Moose?

# Now separating verbosity and strictness/exceptions. Global settings override local
# ones, but this can be overridden in child classes

has 'verbose' => (
    is   => 'rw',
    isa  => 'Bool',
    default => $ENV{BIOPERL_DEBUG} || 0
    );

# strictness level; setting to True converts warnings to exceptions
has 'strict' => (
    is      => 'rw',
    isa     => 'Int',
    where   => sub {$_ >= -1 && $_ <= 1},
    default => $ENV{BIOPERL_STRICT} || 0
    );

sub debug {
    my ($self, @msgs) = @_;
    if (defined $self->verbose) {
        CORE::warn @msgs;
    }
}

sub warn {
    #my ($self,$string) = @_;
    #
    #my $verbose = $self->verbose;
    #
    #my $header = "\n--------------------- WARNING ---------------------\nMSG: ";
    #my $footer =   "---------------------------------------------------\n";
    #
    #if ($verbose >= 2) {
    #    $self->throw($string);
    #}
    #elsif ($verbose <= -1) {
    #    return;
    #}
    #elsif ($verbose == 1) {
    #    CORE::warn $header, $string, "\n", $self->stack_trace_dump, $footer;
    #    return;
    #}    
    #
    #CORE::warn $header, $string, "\n", $footer;
}

sub throw {
    my ($self, @args) = @_;
    
    # Note: value isn't passed on (not sure why, we should address that)
    
    # This delegates to the Bio::Moose::Meta::Class throw_error(), which calls
    # proper error class. Therefore we should probably do most of the
    # grunt work there so it also BP-izes the other errors that'll pop up, such
    # as type check errors, etc.
    
    my ($text, $class, $value) = $self->rearrange([qw(TEXT CLASS VALUE)], @args);
    $text ||= $args[0] if @args == 1;
    
    if (defined $class) {
        $self->meta->error_class($class)
    } else {
        $class = $self->meta->error_class() || '';
    }
    
    # the following should work for any error class set in the meta class,
    # including the text-only Moose fallback using Carp
    $self->meta->throw_error($text, value => $value);
}

sub deprecated{
    #my ($self) = shift;
    #my ($msg, $version) = $self->_rearrange([qw(MESSAGE VERSION)], @_);
    #if (!defined $msg) {
    #    my $prev = (caller(0))[3];
    #    $msg = "Use of ".$prev."() is deprecated";
    #}
    ## delegate to either warn or throw based on whether a version is given
    #if ($version) {
    #    $self->throw('Version must be numerical, such as 1.006000 for v1.6.0, not '.
    #                 $version) unless $version =~ /^\d+\.\d+$/;
    #    $msg .= "\nDeprecated in $version";
    #    if ($Bio::Root::Version::VERSION >= $version) {
    #        $self->throw($msg)
    #    } 
    #}
    ## passing this on to warn() should deal properly with verbosity issues
    #$self->warn($msg);
}

sub throw_not_implemented {
    my $self = shift;

    # Bio::Root::Root::throw() knows how to check for Error.pm and will
    # throw an Error-derived object of the specified class (Bio::Root::NotImplemented),
    # which is defined in Bio::Root::Exception.
    # If Error.pm is not available, the name of the class is just included in the
    # error message.

    my $message = $self->_not_implemented_msg;

    $self->throw(-text=>$message,
                 -class=>'Bio::Root::NotImplemented');
}


=head2 warn_not_implemented

 Purpose : Generates a warning that a method has not been implemented.
           Intended for use in the method definitions of 
           abstract interface modules where methods are defined
           but are intended to be overridden by subclasses.
           Generally, throw_not_implemented() should be used,
           but warn_not_implemented() may be used if the method isn't
           considered essential and convenient no-op behavior can be 
           provided within the interface.
 Usage   : $object->warn_not_implemented( method-name-string );
 Example : $self->warn_not_implemented( "get_foobar" );
 Returns : Calls $self->warn on this object, if available.
           If the object doesn't have a warn() method,
           Carp::carp() will be used.
 Args    : n/a


=cut

#'

sub warn_not_implemented {
#    my $self = shift;
#    my $message = $self->_not_implemented_msg;
#    if( $self->can('warn') ) {
#        $self->warn( $message );
#    }else {
#	    carp $message ;
#    }
}

#sub _not_implemented_msg {
#    my $self = shift;
#    my $package = ref $self;
#    my $meth = (caller(2))[3]; # may not work as intended here; 
#    my $msg =<<EOD_NOT_IMP;
#Abstract method \"$meth\" is not implemented by package $package.
#This is not your fault - author of $package should be blamed!
#EOD_NOT_IMP
#    return $msg;
#}

# Maybe move into a role or trait for optional root utilities (though it's
# fairly ubiquitous in bp).  Switch to MooseX::Method::Signatures?

sub rearrange {
    my $dummy = shift;
    my $order = shift;
    return @_ unless (substr($_[0]||'',0,1) eq '-');
    push @_,undef unless $#_ %2;
    my %param;
    while( @_ ) {
	(my $key = shift) =~ tr/a-z\055/A-Z/d; #deletes all dashes!
	$param{$key} = shift;
    }
    map { $_ = uc($_) } @$order; # for bug #1343, but is there perf hit here?
    return @param{@$order};
}


sub BUILDARGS {
    my ($class, @args) = @_;
    
    # allow hash refs
    my $params;
    if ( scalar(@args) % 2 ) {
        if (defined $args[0] && ref $args[0] eq 'HASH') {
            @args = %{$args[0]};
        } else {
            Class::MOP::class_of($class)->throw_error(
                "Odd-number of parameters passed to new(). Arguments must be ".
                "named parameters or a hash reference of named parameters",
                data => $args[0] );            
        }
    }
    
    # take care of bp-like named parameters
    while( @args ) {
        my $key = shift @args;
        $key =~ tr/\055//d if index($key,'-') == 0; #deletes all dashes!
        $params->{$key} = shift @args;
    }

    return $params;
}

#sub _load_module {
#    shift->meta->load_module(shift);
#}

# cleanup methods needed?  These should probably go into the meta class

no Moose;
__PACKAGE__->meta->make_immutable();

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

=head2 _load_module

 Title   : _load_module
 Usage   : $self->_load_module("Bio::SeqIO::genbank");
 Function: Loads up (like use) the specified module at run time on demand.
 Example : 
 Returns : TRUE on success. Throws an exception upon failure.
 Args    : The module to load (_without_ the trailing .pm).
 Status  : Unstable

=cut