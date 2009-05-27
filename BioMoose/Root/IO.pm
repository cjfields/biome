package Bio::Root::IO;

use Bio::Root::Role;

# IO is a role

no Bio::Root::Role;

1;

__END__

# $Id: Role.pm 15549 2009-02-21 00:48:48Z maj $

=head1 NAME

Bio::Root::Meta::Role - Moose-based Role metaclass for BioPerl

=head1 SYNOPSIS

  package Bio::Foo::Bar;
  
  # imports Moose methods, base class is Bio::Root::Root
  use Bio::Root::Moose;

=head1 DESCRIPTION

This is a simple starter metaclass that imports Moose methods and sets up
Bio::Root::Root as the (Moose::Object-based) base class. All meta class methods
are designated here, whereas base class-specific attributes/methods are
designated in Bio::Root::Root.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
to one of the Bioperl mailing lists.

Your participation is much appreciated.

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
the bugs and their resolution.  Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR

Functions originally from Steve Chervitz. 
Refactored by Ewan Birney.
Re-refactored by Lincoln Stein.

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

##'
#
#use vars qw($DEBUG $ID $VERBOSITY $ERRORLOADED);
#use strict;
#use Bio::Root::IO;
#
#use base qw(Bio::Root::RootI);
#
#BEGIN { 
#
#    $ID        = 'Bio::Root::Root';
#    $DEBUG     = 0;
#    $VERBOSITY = 0;
#    $ERRORLOADED = 0;
#
#    # Check whether or not Error.pm is available.
#
#    # $main::DONT_USE_ERROR is intended for testing purposes and also
#    # when you don't want to use the Error module, even if it is installed.
#    # Just put a INIT { $DONT_USE_ERROR = 1; } at the top of your script.
#    if( not $main::DONT_USE_ERROR ) {
#        if ( eval "require Error"  ) {
#            import Error qw(:try);
#            require Bio::Root::Exception;
#            $ERRORLOADED = 1;
#            $Error::Debug = 1; # enable verbose stack trace 
#        }
#    } 
#    if( !$ERRORLOADED ) {
#        require Carp; import Carp qw( confess );
#    }    
#    $main::DONT_USE_ERROR;  # so that perl -w won't warn "used only once"
#
#}
#
#
#
#=head2 new
#
# Purpose   : generic instantiation function can be overridden if 
#             special needs of a module cannot be done in _initialize
#
#=cut
#
#sub new {
##    my ($class, %param) = @_;
#    my $class = shift;
#    my $self = {};
#    bless $self, ref($class) || $class;
#
#    if(@_ > 1) {
#	# if the number of arguments is odd but at least 3, we'll give
#	# it a try to find -verbose
#	shift if @_ % 2;
#	my %param = @_;
#	## See "Comments" above regarding use of _rearrange().
#	$self->verbose($param{'-VERBOSE'} || $param{'-verbose'});
#    }
#    return $self;
#}
#
#
#=head2 verbose
#
# Title   : verbose
# Usage   : $self->verbose(1)
# Function: Sets verbose level for how ->warn behaves
#           -1 = no warning
#            0 = standard, small warning
#            1 = warning with stack trace
#            2 = warning becomes throw
# Returns : The current verbosity setting (integer between -1 to 2)
# Args    : -1,0,1 or 2
#
#
#=cut
#
#sub verbose {
#   my ($self,$value) = @_;
#   # allow one to set global verbosity flag
#   return $DEBUG  if $DEBUG;
#   return $VERBOSITY unless ref $self;
#   
#    if (defined $value || ! defined $self->{'_root_verbose'}) {
#       $self->{'_root_verbose'} = $value || 0;
#    }
#    return $self->{'_root_verbose'};
#}
#
#sub _register_for_cleanup {
#  my ($self,$method) = @_;
#  if($method) {
#    if(! exists($self->{'_root_cleanup_methods'})) {
#      $self->{'_root_cleanup_methods'} = [];
#    }
#    push(@{$self->{'_root_cleanup_methods'}},$method);
#  }
#}
#
#sub _unregister_for_cleanup {
#  my ($self,$method) = @_;
#  my @methods = grep {$_ ne $method} $self->_cleanup_methods;
#  $self->{'_root_cleanup_methods'} = \@methods;
#}
#
#
#sub _cleanup_methods {
#  my $self = shift;
#  return unless ref $self && $self->isa('HASH');
#  my $methods = $self->{'_root_cleanup_methods'} or return;
#  @$methods;
#
#}
#
#=head2 throw
#
# Title   : throw
# Usage   : $obj->throw("throwing exception message");
#           or
#           $obj->throw( -class => 'Bio::Root::Exception',
#                        -text  => "throwing exception message",
#                        -value => $bad_value  );
# Function: Throws an exception, which, if not caught with an eval or
#           a try block will provide a nice stack trace to STDERR 
#           with the message.
#           If Error.pm is installed, and if a -class parameter is
#           provided, Error::throw will be used, throwing an error 
#           of the type specified by -class.
#           If Error.pm is installed and no -class parameter is provided
#           (i.e., a simple string is given), A Bio::Root::Exception 
#           is thrown.
# Returns : n/a
# Args    : A string giving a descriptive error message, optional
#           Named parameters:
#           '-class'  a string for the name of a class that derives 
#                     from Error.pm, such as any of the exceptions 
#                     defined in Bio::Root::Exception.
#                     Default class: Bio::Root::Exception
#           '-text'   a string giving a descriptive error message
#           '-value'  the value causing the exception, or $! (optional)
#
#           Thus, if only a string argument is given, and Error.pm is available,
#           this is equivalent to the arguments:
#                 -text  => "message",
#                 -class => Bio::Root::Exception
# Comments : If Error.pm is installed, and you don't want to use it
#            for some reason, you can block the use of Error.pm by
#            Bio::Root::Root::throw() by defining a scalar named
#            $main::DONT_USE_ERROR (define it in your main script
#            and you don't need the main:: part) and setting it to 
#            a true value; you must do this within a BEGIN subroutine.
#
#=cut
#
#sub throw {
#    my ($self, @args) = @_;
#    
#    my ($text, $class, $value) = $self->_rearrange( [qw(TEXT
#                                                        CLASS
#                                                        VALUE)], @args);
#    $text ||= $args[0] if @args == 1;
#    
#    if ($ERRORLOADED) {
#        # Enable re-throwing of Error objects.
#        # If the error is not derived from Bio::Root::Exception, 
#        # we can't guarantee that the Error's value was set properly
#        # and, ipso facto, that it will be catchable from an eval{}.
#        # But chances are, if you're re-throwing non-Bio::Root::Exceptions,
#        # you're probably using Error::try(), not eval{}.
#        # TODO: Fix the MSG: line of the re-thrown error. Has an extra line
#        # containing the '----- EXCEPTION -----' banner.
#        if (ref($args[0])) {
#            if( $args[0]->isa('Error')) {
#                my $class = ref $args[0];
#                $class->throw( @args );
#            }
#            else {
#                my $text .= "\nWARNING: Attempt to throw a non-Error.pm object: " . ref$args[0];
#                my $class = "Bio::Root::Exception";
#                $class->throw( '-text' => $text, '-value' => $args[0] ); 
#            }
#        }
#        else {
#            $class ||= "Bio::Root::Exception";
#            
#            my %args;
#            if( @args % 2 == 0 && $args[0] =~ /^-/ ) {
#                %args = @args;
#                $args{-text} = $text;
#                $args{-object} = $self;
#            }
#            
#            $class->throw( scalar keys %args > 0 ? %args : @args ); # (%args || @args) puts %args in scalar context!
#        }
#    }
#    else {
#        $class ||= '';
#        $class = ' '.$class if $class;
#        my $std = $self->stack_trace_dump();
#        my $title = "------------- EXCEPTION$class -------------";
#        my $footer = ('-' x CORE::length($title))."\n";
#        $text ||= '';
#        
#        die "\n$title\n", "MSG: $text\n", $std, $footer, "\n";
#    }
#}
#
#=head2 debug
#
# Title   : debug
# Usage   : $obj->debug("This is debugging output");
# Function: Prints a debugging message when verbose is > 0
# Returns : none
# Args    : message string(s) to print to STDERR
#
#=cut
#
#sub debug {
#    my ($self, @msgs) = @_;
#    
#    if (defined $self->verbose && $self->verbose > 0) {
#        CORE::warn @msgs;
#    }
#}
#
#=head2 _load_module
#
# Title   : _load_module
# Usage   : $self->_load_module("Bio::SeqIO::genbank");
# Function: Loads up (like use) the specified module at run time on demand.
# Example : 
# Returns : TRUE on success. Throws an exception upon failure.
# Args    : The module to load (_without_ the trailing .pm).
#
#=cut
#
#sub _load_module {
#    my ($self, $name) = @_;
#    my ($module, $load, $m);
#    $module = "_<$name.pm";
#    return 1 if $main::{$module};
#
#    # untaint operation for safe web-based running (modified after
#    # a fix by Lincoln) HL
#    if ($name !~ /^([\w:]+)$/) {
#	$self->throw("$name is an illegal perl package name");
#    } else { 
#	$name = $1;
#    }
#
#    $load = "$name.pm";
#    my $io = Bio::Root::IO->new();
#    # catfile comes from IO
#    $load = $io->catfile((split(/::/,$load)));
#    eval {
#        require $load;
#    };
#    if ( $@ ) {
#        $self->throw("Failed to load module $name. ".$@);
#    }
#    return 1;
#}
#
#
#sub DESTROY {
#    my $self = shift;
#    my @cleanup_methods = $self->_cleanup_methods or return;
#    for my $method (@cleanup_methods) {
#      $method->($self);
#    }
#}
#
#

1;

