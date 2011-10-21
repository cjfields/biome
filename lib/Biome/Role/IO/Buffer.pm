package Biome::Role::IO::Buffer;

use Biome::Role;

requires 'fh';

has  buffer     => (
    isa     => 'ArrayRef[Str]',
    traits  => ['Array'],
    is      => 'ro',
    handles  => {
        '_push_buffer'  => 'push',
        '_shift_buffer' => 'shift',
        'has_buffer'    => 'count',
        'clear_buffer'  => 'clear'
        },
    default => sub {[]}
);

sub readline {
    my $self = shift;
    my %param =@_;
    my $fh = $self->fh or return;
    my $line;
    # if the buffer been filled by pushback() then return the buffer
    # contents, rather than read from the filehandle
    if( $self->has_buffer ) {
        $line = $self->_shift_buffer;
    } else {
        $line = <$fh>;
    }

    if(
       #!$HAS_EOL &&
       !$param{-raw} && (defined $line) ) {
        $line =~ s/\015\012/\012/g; # Change all CR/LF pairs to LF
        $line =~ tr/\015/\n/;
    }
    return $line;
}

sub pushback {
    my ($self, $value) = @_;
    if (index($value, $/) >= 0 || eof($self->fh)) {
        $self->_push_buffer($value);
    } else {
        $self->throw("Pushing back data with modified line ending ".
                     "is not supported: $value");
    }
}

sub print {
    my $self = shift;
    my $fh = $self->fh() || \*STDOUT;
    my $ret = print $fh @_;
    return $ret;
}

after 'close' => sub {
    my ($self) = @_;
    return if $self->no_close;
    $self->clear_buffer;
};

no Biome::Role;

1;

__END__

=head1 NAME

Biome::Role::IO::Buffer - Role describing methods and attributes for working
with buffered IO..

=head1 SYNOPSIS

   # this is generally combined with a filehandle role
   with 'Biome::Role::IO::Handle';
   with 'Biome::Role::IO::Buffer';

   # input stream, per line
   while (my $line = $in->readline) {
       # output stream
       $out->print($line);
   }

=head1 DESCRIPTION

This is a role that defines basic methods and attribute delaing with buffered
IO.  At the moment this is not optimized due to the way Moose (and thus Biome)
works, namely that no values are stored directly in an object's hash.

=head1 SUBROUTINES/METHODS

=head2 readline

 Title    : readline
 Usage    : $obj->readline
 Function :
 Returns  :
 Args     :
 Status   :

=cut

=head2 pushback

 Title    : pushback
 Usage    : $obj->pushback
 Function :
 Returns  :
 Args     :
 Status   :

=cut

=head2 print

 Title    : print
 Usage    : $obj->print
 Function :
 Returns  :
 Args     :
 Status   :

=cut



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

Chris Fields  C<< <cjfields at bioperl dot org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
