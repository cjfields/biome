package Biome::Role::IO;

use Biome::Role;

use MooseX::Types::IO;

# attributes
has file    => (
    is      => 'rw',
    isa     => 'Str',
    trigger => sub {
        my ($self, $new) = @_;
        if ($self->fh) {
            close($self->fh);
            $self->_clear_fh
        }
        open(my $newfh, '<', $new) || die "Can't open file:$!";
        $self->_set_fh($newfh);
    }
);

has fh      => (
    is      => 'ro',
    isa     => IO,
    writer  => '_set_fh',
    clearer => '_clear_fh',
    init_arg => undef,
);

# factor these out into a loaded module map

#has 'LWP_LOADED' => (
#    is          => 'ro',
#    isa         => 'Bool',
#    lazy        => 1,
#    default     => sub {
#        eval {Class::MOP::load_class('LWP::UserAgent')};
#        $@ ? 1 : 0;
#    }
#);
#
#has 'EOL_LOADED' => (
#    is          => 'ro',
#    isa         => 'Bool',
#    lazy        => 1,
#    default     => sub {
#        eval {Class::MOP::load_class('PerlIO::eol')};
#        $@ ? 1 : 0;
#    }
#);

# the three below modules are in core so should always return true

has 'ROOTDIR' => (
    is          => 'ro',
    isa         => 'Str',
    lazy        => 1,
    default     => sub {
        my $self = shift;
        if ($self->FILESPEC_LOADED) {   # use Root's module cache to check
            return File::Spec->tmpdir()
        } else {
            $self->throw("File::Temp not loaded, required for tempfile creations");
        }
    }
);

# READ

sub _readline {
    my $self = shift;
    my %param = @_;
    my $fh = $self->_fh or return;
    my $line;

    # if the buffer been filled by _pushback then return the buffer
    # contents, rather than read from the filehandle
    if( @{$self->{'_readbuffer'} || [] } ) {
        $line = shift @{$self->{'_readbuffer'}};
    } else {
        $line = <$fh>;
    }

    #don't strip line endings if -raw is specified
    # $line =~ s/\r\n/\n/g if( (!$param{-raw}) && (defined $line) );
    # Dave Howorth's fix
    if( (!$param{-raw}) && (defined $line) ) {
        $line =~ s/\015\012/\012/g; # Change all CR/LF pairs to LF
        $line =~ tr/\015/\n/; # Change all single CRs to NEWLINE
    }
    return $line;
}

# _pushback now checks the line endings against $/ and dies if there isn't a
# match.  However, I'll likely relax this and indic
sub _pushback {
    my ($obj, $value) = @_;    
    if (index($value, $/) >= 0) {
        push @{$obj->{'_readbuffer'}}, $value;
    } else {
        $obj->throw("Pushing modifed data back not supported: $value");
    }
}

# WRITE
sub _print {
    my $self = shift;
    my $fh = $self->_fh() || \*STDOUT;
    my $ret = print $fh @_;
    return $ret;
}

sub close {
   my ($self) = @_;
   return if $self->noclose; # don't close if we explictly asked not to
   if( defined $self->{'_filehandle'} ) {
       $self->flush;
       return if( \*STDOUT == $self->_fh ||
		  \*STDERR == $self->_fh ||
		  \*STDIN == $self->_fh
		  ); # don't close STDOUT fh
       if( ! ref($self->{'_filehandle'}) ||
	   ! $self->{'_filehandle'}->isa('IO::String') ) {
	   close($self->{'_filehandle'});
       }
   }
   $self->{'_filehandle'} = undef;
   delete $self->{'_readbuffer'};
}

#sub flush {
#    my ($self) = shift;
#    
#    if( !defined $self->{'_filehandle'} ) {
#        $self->throw("Attempting to call flush but no filehandle active");
#    }
#  
#    if( ref($self->{'_filehandle'}) =~ /GLOB/ ) {
#      my $oldh = select($self->{'_filehandle'});
#      $| = 1;
#      select($oldh);
#    } else {
#      $self->{'_filehandle'}->flush();
#    }
#}

#sub _io_cleanup {
#    my ($self) = @_;
#    $self->close();
#    my $v = $self->verbose;
#
#    # we are planning to cleanup temp files no matter what    
#    if( exists($self->{'_rootio_tempfiles'}) &&
#	ref($self->{'_rootio_tempfiles'}) =~ /array/i &&
#    !$self->save_tempfiles) { 
#	if( $v > 0 ) {
#	    warn( "going to remove files ", 
#		  join(",",  @{$self->{'_rootio_tempfiles'}}), "\n");
#	}
#	unlink  (@{$self->{'_rootio_tempfiles'}} );
#    }
#    # cleanup if we are not using File::Temp
#    if( $self->{'_cleanuptempdir'} &&
#	exists($self->{'_rootio_tempdirs'}) &&
#	ref($self->{'_rootio_tempdirs'}) =~ /array/i &&
#    !$self->save_tempfiles) {	
#	if( $v > 0 ) {
#	    warn( "going to remove dirs ", 
#		  join(",",  @{$self->{'_rootio_tempdirs'}}), "\n");
#	}
#	$self->rmtree( $self->{'_rootio_tempdirs'});
#    }
#}

sub exists_exe {
    my ($self, $exe) = @_;
    $self->throw("Must pass a defined value to exists_exe") unless defined $exe;
    $exe = $self if (!(ref($self) || $exe));
    $exe .= '.exe' if(($^O =~ /mswin/i) && ($exe !~ /\.(exe|com|bat|cmd)$/i));
    return $exe if ( -f $exe && -x $exe ); # full path and exists

    # Not a full path, or does not exist. Let's see whether it's in the path.
    if ($self->FILESPEC_LOADED) {
        foreach my $dir (File::Spec->path()) {
            my $f = File::Spec->catfile($dir, $exe);
            return $f if( -f $f && -x $f );
        }
    }
    return 0;
}

# this should just delegate to File::Temp using relevant mappings from the
# instance, not passed args

#sub tempfile {
#    my ($self, %params) = @_;
#    my ($tfh, $file);
#    
#    # map between naming with and without dash
#    foreach my $key (keys(%params)) {
#        if( $key =~ /^-/  ) {
#            my $v = $params{$key};
#            delete $params{$key};
#            $params{uc(substr($key,1))} = $v;
#        } else { 
#            # this is to upper case
#            my $v = $params{$key};
#            delete $params{$key};	    
#            $params{uc($key)} = $v;
#        }
#    }
#    
#    # reconcile tempfile related attributes set per instance here
#    
#    $params{'DIR'} = $self->TEMPDIR if(! exists($params{'DIR'}));
#    unless (exists $params{'UNLINK'} && 
#	    defined $params{'UNLINK'} &&
#	    ! $params{'UNLINK'} ){
#        $params{'UNLINK'} = 1;
#    } else {
#        $params{'UNLINK'} = 0
#    }
#	    
#    if($self->FILETEMP_LOADED) {
#        if(exists($params{'TEMPLATE'})) {
#            my $template = $params{'TEMPLATE'};
#            delete $params{'TEMPLATE'};
#            ($tfh, $file) = File::Temp::tempfile($template, %params);
#        } else {
#            ($tfh, $file) = File::Temp::tempfile(%params);
#        }
#    } else {
#        my $dir = $params{'DIR'};
#        $file = $self->catfile($dir,
#                       (exists($params{'TEMPLATE'}) ?
#                    $params{'TEMPLATE'} :
#                    sprintf( "%s.%s.%s",  
#                         $ENV{USER} || 'unknown', $$, 
#                         $TEMPCOUNTER++)));
#
#        # sneakiness for getting around long filenames on Win32?
#        #if( $HAS_WIN32 ) {
#        #    $file = Win32::GetShortPathName($file);
#        #}
#    
#        # Try to make sure this will be marked close-on-exec
#        # XXX: Win32 doesn't respect this, nor the proper fcntl,
#        #      but may have O_NOINHERIT. This may or may not be in Fcntl.
#        local $^F = 2; 
#        # Store callers umask
#        my $umask = umask();
#        # Set a known umaskr
#        umask(066);
#        # Attempt to open the file
#        if ( sysopen($tfh, $file, $OPENFLAGS, 0600) ) {
#            # Reset umask
#            umask($umask); 
#        } else { 
#            $self->throw("Could not open tempfile $file: $!\n");
#        }
#    }
#
#    if(  $params{'UNLINK'} ) {
#        push @{$self->{'_rootio_tempfiles'}}, $file;
#    } 
#
#
#    return wantarray ? ($tfh,$file) : $tfh;
#}

#sub tempdir {
#    my ( $self, @args ) = @_;
#    if($self->FILETEMP_LOADED && File::Temp->can('tempdir') ) {
#        return File::Temp::tempdir(@args);
#    }
#
#    # we have to do this ourselves, not good
#    #
#    # we are planning to cleanup temp files no matter what
#    my %params = @args;
#    $self->{'_cleanuptempdir'} = ( defined $params{CLEANUP} && 
#				   $params{CLEANUP} == 1);
#    my $tdir = $self->catfile($TEMPDIR,
#			      sprintf("dir_%s-%s-%s", 
#				      $ENV{USER} || 'unknown', $$, 
#				      $TEMPCOUNTER++));
#    mkdir($tdir, 0755);
#    push @{$self->{'_rootio_tempdirs'}}, $tdir; 
#    return $tdir;
#}

sub catfile {
    my ($self, @args) = @_;
    return File::Spec->catfile(@args);
}

#sub rmtree {
#    my($self,$roots, $verbose, $safe) = @_;
#    if( $FILEPATHLOADED ) { 
#	return File::Path::rmtree ($roots, $verbose, $safe);
#    }
#
#    my $force_writeable = ($^O eq 'os2' || $^O eq 'dos' || $^O eq 'MSWin32'
#		       || $^O eq 'amigaos' || $^O eq 'cygwin');
#    my $Is_VMS = $^O eq 'VMS';
#
#    my(@files);
#    my($count) = 0;
#    $verbose ||= 0;
#    $safe ||= 0;
#    if ( defined($roots) && length($roots) ) {
#	$roots = [$roots] unless ref $roots;
#    } else {
#	$self->warn("No root path(s) specified\n");
#	return 0;
#    }
#
#    my($root);
#    foreach $root (@{$roots}) {
#	$root =~ s#/\z##;
#	(undef, undef, my $rp) = lstat $root or next;
#	$rp &= 07777;	# don't forget setuid, setgid, sticky bits
#	if ( -d _ ) {
#	    # notabene: 0777 is for making readable in the first place,
#	    # it's also intended to change it to writable in case we have
#	    # to recurse in which case we are better than rm -rf for 
#	    # subtrees with strange permissions
#	    chmod(0777, ($Is_VMS ? VMS::Filespec::fileify($root) : $root))
#	      or $self->warn("Can't make directory $root read+writeable: $!")
#		unless $safe;
#	    if (opendir(DIR, $root) ){
#		@files = readdir DIR;
#		closedir(DIR);
#	    } else {
#	        $self->warn( "Can't read $root: $!");
#		@files = ();
#	    }
#
#	    # Deleting large numbers of files from VMS Files-11 filesystems
#	    # is faster if done in reverse ASCIIbetical order 
#	    @files = reverse @files if $Is_VMS;
#	    ($root = VMS::Filespec::unixify($root)) =~ s#\.dir\z## if $Is_VMS;
#	    @files = map("$root/$_", grep $_!~/^\.{1,2}\z/s,@files);
#	    $count += $self->rmtree([@files],$verbose,$safe);
#	    if ($safe &&
#		($Is_VMS ? !&VMS::Filespec::candelete($root) : !-w $root)) {
#		print "skipped $root\n" if $verbose;
#		next;
#	    }
#	    chmod 0777, $root
#	      or $self->warn( "Can't make directory $root writeable: $!")
#		if $force_writeable;
#	    print "rmdir $root\n" if $verbose;
#	    if (rmdir $root) {
#		++$count;
#	    }
#	    else {
#		$self->warn( "Can't remove directory $root: $!");
#		chmod($rp, ($Is_VMS ? VMS::Filespec::fileify($root) : $root))
#		    or $self->warn("and can't restore permissions to "
#		            . sprintf("0%o",$rp) . "\n");
#	    }
#	}
#	else {
#
#	    if ($safe &&
#		($Is_VMS ? !&VMS::Filespec::candelete($root)
#		         : !(-l $root || -w $root)))
#	    {
#		print "skipped $root\n" if $verbose;
#		next;
#	    }
#	    chmod 0666, $root
#	      or $self->warn( "Can't make file $root writeable: $!")
#		if $force_writeable;
#	    warn "unlink $root\n" if $verbose;
#	    # delete all versions under VMS
#	    for (;;) {
#		unless (unlink $root) {
#		    $self->warn( "Can't unlink file $root: $!");
#		    if ($force_writeable) {
#			chmod $rp, $root
#			    or $self->warn("and can't restore permissions to "
#			            . sprintf("0%o",$rp) . "\n");
#		    }
#		    last;
#		}
#		++$count;
#		last unless $Is_VMS && lstat $root;
#	    }
#	}
#    }
#
#    $count;
#}

no Moose::Util::TypeConstraints;

no Biome::Role;

1;


__END__

=head1

use vars qw($FILESPECLOADED $FILETEMPLOADED $FILEPATHLOADED
	    $TEMPDIR $PATHSEP $ROOTDIR $OPENFLAGS $VERBOSE $ONMAC
            $HAS_LWP
           );

use Symbol;
use POSIX qw(dup);
use IO::Handle;
use Bio::Root::HTTPget;

use base qw(Bio::Root::Root);

my $TEMPCOUNTER;
my $HAS_WIN32 = 0;
#my $HAS_LWP = 1;

BEGIN {
    $TEMPCOUNTER = 0;
    $FILESPECLOADED = 0;
    $FILETEMPLOADED = 0;
    $FILEPATHLOADED = 0;
    $VERBOSE = 0;

    # try to load those modules that may cause trouble on some systems
    eval { 
	require File::Path;
	$FILEPATHLOADED = 1;
    }; 
    if( $@ ) {
	print STDERR "Cannot load File::Path: $@" if( $VERBOSE > 0 );
	# do nothing
    }

    eval {
	require LWP::UserAgent;
    };
    if( $@ ) {
	print STDERR "Cannot load LWP::UserAgent: $@" if( $VERBOSE > 0 );
        $HAS_LWP = 0;
    } else {
        $HAS_LWP = 1;
    }

    # If on Win32, attempt to find Win32 package

    if($^O =~ /mswin/i) {
	eval {
	    require Win32;
	    $HAS_WIN32 = 1;
	};
    }

    # Try to provide a path separator. Why doesn't File::Spec export this,
    # or did I miss it?
    if($^O =~ /mswin/i) {
	$PATHSEP = "\\";
    } elsif($^O =~ /macos/i) {
	$PATHSEP = ":";
    } else { # unix
	$PATHSEP = "/";
    }
    eval {
	require File::Spec;
	$FILESPECLOADED = 1;
	$TEMPDIR = File::Spec->tmpdir();
	$ROOTDIR = File::Spec->rootdir();
	require File::Temp; # tempfile creation
	$FILETEMPLOADED = 1;
    };
    if( $@ ) { 
	if(! defined($TEMPDIR)) { # File::Spec failed
	    # determine tempdir
	    if (defined $ENV{'TEMPDIR'} && -d $ENV{'TEMPDIR'} ) {
		$TEMPDIR = $ENV{'TEMPDIR'};
	    } elsif( defined $ENV{'TMPDIR'} && -d $ENV{'TMPDIR'} ) {
		$TEMPDIR = $ENV{'TMPDIR'};
	    }
	    if($^O =~ /mswin/i) {
		$TEMPDIR = 'C:\TEMP' unless $TEMPDIR;
		$ROOTDIR = 'C:';
	    } elsif($^O =~ /macos/i) {
		$TEMPDIR = "" unless $TEMPDIR; # what is a reasonable default on Macs?
		$ROOTDIR = ""; # what is reasonable??
	    } else { # unix
		$TEMPDIR = "/tmp" unless $TEMPDIR;
		$ROOTDIR = "/";
	    }
	    if (!( -d $TEMPDIR && -w $TEMPDIR )) {
		$TEMPDIR = '.'; # last resort
	    }
	}
	# File::Temp failed (alone, or File::Spec already failed)
	#
	# determine open flags for tempfile creation -- we'll have to do this
	# ourselves
	use Fcntl;
	use Symbol;
	$OPENFLAGS = O_CREAT | O_EXCL | O_RDWR;
	for my $oflag (qw/FOLLOW BINARY LARGEFILE EXLOCK NOINHERIT TEMPORARY/){
	    my ($bit, $func) = (0, "Fcntl::O_" . $oflag);
	    no strict 'refs';
	    $OPENFLAGS |= $bit if eval { $bit = &$func(); 1 };
	}
    }
    $ONMAC = "\015" eq "\n";
}

=head2 _initialize_io

 Title   : initialize_io
 Usage   : $self->_initialize_io(@params);
 Function: Initializes filehandle and other properties from the parameters.

           Currently recognizes the following named parameters:
              -file     name of file to open
              -url      name of URL to open
              -input    name of file, or GLOB, or IO::Handle object
              -fh       file handle (mutually exclusive with -file)
              -flush    boolean flag to autoflush after each write
              -noclose  boolean flag, when set to true will not close a
                        filehandle (must explictly call close($io->_fh)
              -retries  number of times to try a web fetch before failure
                        
              -ua_parms hashref of key => value parameters to pass 
                        to LWP::UserAgent->new()
                        (only meaningful with -url is set)
                        A useful value might be, for example,
                        { timeout => 60 } (ua default is 180 sec)
 Returns : TRUE
 Args    : named parameters

=head2 _fh

 Title   : _fh
 Usage   : $obj->_fh($newval)
 Function: Get/set the file handle for the stream encapsulated.
 Example :
 Returns : value of _filehandle
 Args    : newvalue (optional)

=head2 mode

 Title   : mode
 Usage   : $obj->mode()
 Function:
 Example :
 Returns : mode of filehandle:
           'r' for readable
           'w' for writeable
           '?' if mode could not be determined
 Args    : -force (optional), see notes.
 Notes   : once mode() has been called, the filehandle's mode is cached
           for further calls to mode().  to override this behavior so
           that mode() re-checks the filehandle's mode, call with arg
           -force

=head2 file

 Title   : file
 Usage   : $obj->file($newval)
 Function: Get/set the filename, if one has been designated.
 Example :
 Returns : value of file
 Args    : newvalue (optional)

=head2 _print

 Title   : _print
 Usage   : $obj->_print(@lines)
 Function:
 Example :
 Returns : 1 on success, undef on failure

=head2 _readline

 Title   : _readline
 Usage   : $obj->_readline(%args)
 Function: Reads a line of input.

           Note that this method implicitely uses the value of $/ that is
           in effect when called.

           Note also that the current implementation does not handle pushed
           back input correctly unless the pushed back input ends with the
           value of $/.

 Example :
 Args    : Accepts a hash of arguments, currently only -raw is recognized
           passing (-raw => 1) prevents \r\n sequences from being changed
           to \n.  The default value of -raw is undef, allowing \r\n to be
           converted to \n.
 Returns : 

=head2 _pushback

 Title   : _pushback
 Usage   : $obj->_pushback($newvalue)
 Function: puts a line previously read with _readline back into a buffer.
           buffer can hold as many lines as system memory permits.
 Example : $obj->_pushback($newvalue)
 Returns : none
 Args    : newvalue
 Note    : This is only supported for pushing back data ending with the
		   current, localized value of $/. Using this method to push modified
		   data back onto the buffer stack is not supported; see bug 843.

=head2 close

 Title   : close
 Usage   : $io->close()
 Function: Closes the file handle associated with this IO instance.
           Will not close the FH if  -noclose is specified
 Returns : none
 Args    : none

=head2 flush

 Title   : flush
 Usage   : $io->flush()
 Function: Flushes the filehandle
 Returns : none
 Args    : none

=head2 noclose

 Title   : noclose
 Usage   : $obj->noclose($newval)
 Function: Get/Set the NOCLOSE flag - setting this to true will
           prevent a filehandle from being closed
           when an object is cleaned up or explicitly closed
           This is a bit of hack 
 Returns : value of noclose (a scalar)
 Args    : on set, new value (a scalar or undef, optional)

=head2 exists_exe

 Title   : exists_exe
 Usage   : $exists = $obj->exists_exe('clustalw');
           $exists = Bio::Root::IO->exists_exe('clustalw')
           $exists = Bio::Root::IO::exists_exe('clustalw')
 Function: Determines whether the given executable exists either as file
           or within the path environment. The latter requires File::Spec
           to be installed.
           On Win32-based system, .exe is automatically appended to the program
           name unless the program name already ends in .exe.
 Example :
 Returns : 1 if the given program is callable as an executable, and 0 otherwise
 Args    : the name of the executable

=head2 tempfile

 Title   : tempfile
 Usage   : my ($handle,$tempfile) = $io->tempfile(); 
 Function: Returns a temporary filename and a handle opened for writing and
           and reading.

 Caveats : If you do not have File::Temp on your system you should avoid
           specifying TEMPLATE and SUFFIX. (We don't want to recode
           everything, okay?)
 Returns : a 2-element array, consisting of temporary handle and temporary 
           file name
 Args    : named parameters compatible with File::Temp: DIR (defaults to
           $Bio::Root::IO::TEMPDIR), TEMPLATE, SUFFIX.

=head2  tempdir

 Title   : tempdir
 Usage   : my ($tempdir) = $io->tempdir(CLEANUP=>1); 
 Function: Creates and returns the name of a new temporary directory.

           Note that you should not use this function for obtaining "the"
           temp directory. Use $Bio::Root::IO::TEMPDIR for that. Calling this
           method will in fact create a new directory.

 Returns : The name of a new temporary directory.
 Args    : args - ( key CLEANUP ) indicates whether or not to cleanup 
           dir on object destruction, other keys as specified by File::Temp

=head2 catfile

 Title   : catfile
 Usage   : $path = Bio::Root::IO->catfile(@dirs,$filename);
 Function: Constructs a full pathname in a cross-platform safe way.

           If File::Spec exists on your system, this routine will merely
           delegate to it. Otherwise it tries to make a good guess.

           You should use this method whenever you construct a path name
           from directory and filename. Otherwise you risk cross-platform
           compatibility of your code.

           You can call this method both as a class and an instance method.

 Returns : a string
 Args    : components of the pathname (directories and filename, NOT an
           extension)

=head2 rmtree

 Title   : rmtree
 Usage   : Bio::Root::IO->rmtree($dirname );
 Function: Remove a full directory tree

           If File::Path exists on your system, this routine will merely
           delegate to it. Otherwise it runs a local version of that code.

           You should use this method to remove directories which contain 
           files.

           You can call this method both as a class and an instance method.

 Returns : number of files successfully deleted
 Args    : roots - rootdir to delete or reference to list of dirs

           verbose - a boolean value, which if TRUE will cause
                     C<rmtree> to print a message each time it
                     examines a file, giving the name of the file, and
                     indicating whether it's using C<rmdir> or
                     C<unlink> to remove it, or that it's skipping it.
                     (defaults to FALSE)

           safe - a boolean value, which if TRUE will cause C<rmtree>
                  to skip any files to which you do not have delete
                  access (if running under VMS) or write access (if
                  running under another OS).  This will change in the
                  future when a criterion for 'delete permission'
                  under OSs other than VMS is settled.  (defaults to
                  FALSE)

=head2 _flush_on_write

 Title   : _flush_on_write
 Usage   : $obj->_flush_on_write($newval)
 Function: Boolean flag to indicate whether to flush 
           the filehandle on writing when the end of 
           a component is finished (Sequences,Alignments,etc)
 Returns : value of _flush_on_write
 Args    : newvalue (optional)

=head2 save_tempfiles

 Title   : save_tempfiles
 Usage   : $obj->save_tempfiles(1)
 Function: Boolean flag to indicate whether to retain tempfiles/tempdir
 Returns : Boolean value : 1 = save tempfiles/tempdirs, 0 = remove (default)
 Args    : Value evaluating to TRUE or FALSE

1;

=cut

__END__

=head1 NAME

Biome::Role::IO - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Biome::Role::IO version Biome::Role.

=head1 SYNOPSIS

   with 'Biome::Role::IO';
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

<TODO>
A full description of the module and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 SUBROUTINES/METHODS

<TODO>
A separate section listing the public components of the module's interface.
These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module provides.
Name the section accordingly.

In an object-oriented module, this section should begin with a sentence of the
form "An object of this class represents...", to give the reader a high-level
context to help them understand the methods that are subsequently described.

=head1 DIAGNOSTICS

<TODO>
A list of every error and warning message that the module can generate
(even the ones that will "never happen"), with a full explanation of each
problem, one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

<TODO>
A full explanation of any configuration system(s) used by the module,
including the names and locations of any configuration files, and the
meaning of any environment variables or properties that can be set. These
descriptions must also include details of any configuration language used.

=head1 DEPENDENCIES

<TODO>
A list of all the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules are
part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

<TODO>
A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for
system or program resources, or due to internal limitations of Perl
(for example, many modules that use source code filters are mutually
incompatible).

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

User feedback is an integral part of the evolution of this and other Biome and
BioPerl modules. Send your comments and suggestions preferably to one of the
BioPerl mailing lists. Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

Patches are always welcome.

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and reponsive
experts will be able look at the problem and quickly address it. Please include
a thorough description of the problem with code and data examples if at all
possible.

=head2 Reporting Bugs

Preferrably, Biome bug reports should be reported to the GitHub Issues bug
tracking system:

  http://github.com/cjfields/biome/issues

Bugs can also be reported using the BioPerl bug tracking system, submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 EXAMPLES

<TODO>
Many people learn better by example than by explanation, and most learn better
by a combination of the two. Providing a /demo directory stocked with
well-commented examples is an excellent idea, but your users might not have
access to the original distribution, and the demos are unlikely to have been
installed for them. Adding a few illustrative examples in the documentation
itself can greatly increase the "learnability" of your code.

=head1 FREQUENTLY ASKED QUESTIONS

<TODO>
Incorporating a list of correct answers to common questions may seem like extra
work (especially when it comes to maintaining that list), but in many cases it
actually saves time. Frequently asked questions are frequently emailed
questions, and you already have too much email to deal with. If you find
yourself repeatedly answering the same question by email, in a newsgroup, on a
web site, or in person, answer that question in your documentation as well. Not
only is this likely to reduce the number of queries on that topic you
subsequently receive, it also means that anyone who does ask you directly can
simply be directed to read the fine manual.

=head1 COMMON USAGE MISTAKES

<TODO>
This section is really "Frequently Unasked Questions". With just about any kind
of software, people inevitably misunderstand the same concepts and misuse the
same components. By drawing attention to these common errors, explaining the
misconceptions involved, and pointing out the correct alternatives, you can once
again pre-empt a large amount of unproductive correspondence. Perl itself
provides documentation of this kind, in the form of the perltrap manpage.

=head1 SEE ALSO

<TODO>
Often there will be other modules and applications that are possible
alternatives to using your software. Or other documentation that would be of use
to the users of your software. Or a journal article or book that explains the
ideas on which the software is based. Listing those in a "See Also" section
allows people to understand your software better and to find the best solution
for their problem themselves, without asking you directly.

By now you have no doubt detected the ulterior motive for providing more
extensive user manuals and written advice. User documentation is all about not
having to actually talk to users.

=head1 (DISCLAIMER OF) WARRANTY

<TODO>
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

<TODO>
Acknowledging any help you received in developing and improving your software is
plain good manners. But expressing your appreciation isn't only courteous; it's
also enlightened self-interest. Inevitably people will send you bug reports for
your software. But what you'd much prefer them to send you are bug reports
accompanied by working bug fixes. Publicly thanking those who have already done
that in the past is a great way to remind people that patches are always
welcome.

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

