package Biome::Factory::FTLocationFactory;

use Biome;
use namespace::autoclean;

my $LOCREG;

# the below is an optimized regex obj. from J. Freidl's Mastering Reg Exp.
$LOCREG = qr{
            (?>
            [^()]+
            |
            \(
            (??{$LOCREG})
            \)
            )*
            }xmso;

has     'locatable_class' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Biome::SeqFeature::Generic'
);

has     'default_strand' => (
    is      => 'ro',
    isa     => 'Int',
    default => 1
);

my %OPS = map { $_ => 1 } qw(join order bond complement);

{
    # TODO: benchmark caching the class and default strand vs simple att call

my ($LOC_CLASS, $DEF_STR);

sub BUILD {
    my ($self) = @_;
    $self->load_modules($self->locatable_class);
    ($LOC_CLASS, $DEF_STR) = ($self->locatable_class, $self->default_string);
}

sub from_string {
    my ($self, $locstr, $op, $depth) = @_;
    #
    $depth ||= 0;
    my $loc;

    # run on first pass only
    # Note : These location types are now deprecated in GenBank (Oct. 2006)

    # TODO: deprecate support for these?
    if (!defined($op)) {
        # convert all (X.Y) to [X.Y]
        $locstr =~ s{\((\d+\.\d+)\)}{\[$1\]}g;
        # convert ABC123:(X..Y) to ABC123:[X..Y]
        # we should never see the above
        $locstr =~ s{:\((\d+\.{2}\d+)\)}{:\[$1\]}g;
    }

    if ($locstr =~ m{(.*?)\(($LOCREG)\)(.*)}o) { # any matching parentheses?

        my ($beg, $mid, $end) = ($1, $2, $3);

        my @sublocs = grep {$_} (split(q(,),$beg), $mid, split(q(,),$end));

        my @loc_objs;
        my $loc_obj;

        SUBLOCS:
        while (@sublocs) {
            my $oparg = lc(shift @sublocs);

            # has operator, requires further work (recurse)
            if (exists($OPS{$oparg})) {
                my $sub = shift @sublocs;

                # simple split operators (no recursive calls needed)
                if ($sub !~ m{(?:join|order|bond)}) {
                    my @splitlocs = split(/,/, $sub);
                    if (@splitlocs == 1) {
                        # this should be a single complement only
                        $loc_obj = $self->_parse_range($splitlocs[0]);
                        $loc_obj->strand(-1);
                    } else {
                        $loc_obj = $self->locatable_class->new(-location_type => uc $oparg);
                        my @loc_objs = map {
                                my $sobj;
                                if (m{\(($LOCREG)\)}) {
                                    my $comploc = $1;
                                    $sobj = $self->_parse_range($comploc);
                                    $sobj->strand(-1);
                                } else { # normal
                                    $sobj = $self->_parse_range($_);
                                }
                                $sobj;
                            } @splitlocs;
                        $loc_obj->add_sub_Locations(\@loc_objs);
                    }
                } else {
                    $loc_obj = $self->from_string($sub, $oparg, ++$depth);
                    if ($oparg eq 'complement') {
                        $loc_obj->strand(-1);
                    } else {
                        $loc_obj->location_type(uc $oparg) ;
                    }
                }
            }
            # no operator, simple or fuzzy
            else {
                $loc_obj = $self->from_string($oparg, 1, ++$depth);
            }
            push @loc_objs, $loc_obj;
        }
        my $ct = @loc_objs;
        if ($op && !($op eq 'join' || $op eq 'order' || $op eq 'bond')
                && $ct > 1 ) {
            $self->throw("Bad operator $op: had multiple locations ".
                         scalar(@loc_objs).", should be SplitLocationI");
        }
        if ($ct > 1) {
            $loc = $self->locatable_class->new();
            $loc->add_sub_Locations(\@loc_objs);
            return $loc;
        } else {
            return $loc_objs[0];
        }
    } else { # simple location(s)
        $loc = $self->_parse_range($locstr);
        $loc->strand(-1) if ($op && $op eq 'complement');
    }
    return $loc;
}

my @STRING_ORDER = qw(start loc_type end);

sub _parse_range {
    my ($self, $string) = @_;
    return unless $string;

    my %atts;
    $atts{strand} = $self->default_strand;

    my @loc_data = split(/(\.{2}|\^|\:)/, $string);

    # SeqID
    if (@loc_data == 5) {
        $atts{seq_id} = shift @loc_data;
        $atts{is_remote} = 1;
        shift @loc_data; # get rid of ':'
    }
    for my $i (0..$#loc_data) {
        my $order = $STRING_ORDER[$i];
        my $str = $loc_data[$i];
        if ($order eq 'start' || $order eq 'end') {
            $str =~ s{[\[\]\(\)]+}{}g;
            if ($str =~ /^([<>\?])?(\d+)?$/) {
                $atts{"${order}_pos_type"} = $1 if $1;
                $atts{$order} = $2;
            } elsif ($str =~ /^(\d+)\.(\d+)$/) {
                $atts{"${order}_pos_type"} = '.';
                $atts{$order} = $1;
                $atts{"${order}_offset"} = $2 - $1;
            } else {
                $self->throw("Can't parse location string: $str");
            }
        } else {
            $atts{location_type} = $str;
        }
    }
    if ($atts{start_pos_type} && $atts{start_pos_type} eq '.' &&
        (!$atts{end} && !$atts{end_pos_type})
        ) {
        $atts{end} = $atts{start} + $atts{start_offset};
        delete @atts{qw(start_offset start_pos_type end_pos_type)};
        $atts{location_type} = '.';
    }
    $atts{end} ||= $atts{start} unless $atts{end_pos_type};

    # TODO: will very likely bork w/o all atts defined...
    return $self->locatable_class->new(%atts);
}

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Biome::Factory::FTLocationFactory - A FeatureTable Location Parser

=head1 VERSION

This documentation refers to Biome::Factory::FTLocationFactory version 0.01.

=head1 SYNOPSIS

  use Biome::Factory::FTLocationFactory;
  # parse a string into a location object
  $loc = Biome::Factory::FTLocationFactory->from_string("join(100..200,400..500");

=head1 DESCRIPTION

<TODO>
A full description of the module and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 SUBROUTINES/METHODS

=head2 from_string

 Title   : from_string
 Usage   : $loc = $locfactory->from_string("100..200");
 Function: Parses the given string and returns a Bio::LocationI implementing
           object representing the location encoded by the string.

           This implementation parses the Genbank feature table
           encoding of locations.
 Example :
 Returns : A Bio::LocationI implementing object.
 Args    : A string.

=head2 _parse_location

 Title   : _parse_location
 Usage   : $loc = $locfactory->_parse_location( $loc_string)

 Function: Parses the given location string and returns a location object
           with start() and end() and strand() set appropriately.
           Note that this method is private.
 Returns : A Bio::LocationI implementing object or undef on failure
 Args    : location string

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

=head1 DESCRIPTION

Implementation of string-encoded location parsing for the Genbank feature
table encoding of locations.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support

Please direct usage questions or support issues to the mailing list:

I<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and
reponsive experts will be able look at the problem and quickly
address it. Please include a thorough description of the problem
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Hilmar Lapp

Email hlapp at gmx.net

=head1 CONTRIBUTORS

Jason Stajich, jason-at-bioperl-dot-org
Chris Fields, cjfields-at-uiuc-dot-edu

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _
