package Biome::Role::Location::Simple;

use 5.010;
use Biome::Role;
use namespace::autoclean -except => 'meta';

use List::MoreUtils qw(all);

use Biome::Type::Location qw(Location_Type
    Split_Location_Type
    Location_Symbol
    Location_Pos_Type
    Location_Pos_Symbol);

use Biome::Type::Sequence qw(Sequence_Strand);

has 'start' => (
    isa         => 'Num',
    is          => 'rw',
    trigger     => \&_check_coord
);

has 'end' => (
    isa         => 'Num',
    is          => 'rw',
    trigger     => \&_check_coord
);

sub _check_coord {
    my $self = shift;
    my ($start, $end) = ($self->start, $self->end);

    # only check if both are defined
    return unless defined($start) && defined($end);
    $self->throw("Start must be less than end") if $start > $end;
    if ($self->location_type eq 'IN-BETWEEN' &&
        (abs($end - $start) != 1) ) {
        $self->throw("length of location with IN-BETWEEN position type ".
                     "cannot be larger than 1; got ".abs($end - $start));
    }
}

has strand  => (
    isa     => Sequence_Strand,
    is      => 'rw',
    default => 0,
    coerce  => 1
);

has 'start_pos_type'    => (
    isa             => Location_Pos_Type,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    trigger         => sub {
        my ($self, $v) = @_;
        return unless $self->end && $self->start;
        $self->throw("Start position can't have type $v") if $v eq 'AFTER';
    }
);

has 'end_pos_type'      => (
    isa             => Location_Pos_Type,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    trigger         => sub {
        my ($self, $v) = @_;
        return unless $self->end && $self->start;
        $self->throw("End position can't have type $v") if $v eq 'BEFORE';
    }
);

# this is for 'fuzzy' locations like WITHIN, BEFORE, AFTER
has [qw(start_offset end_offset)]  => (
    isa             => 'Int',
    is              => 'rw',
    lazy            => 1,
    default         => 0
);

has 'location_type'  => (
    isa         => Location_Type,
    is          => 'rw',
    lazy        => 1,
    default     => 'EXACT',
    coerce      => 1
);

has 'is_remote' => (
    is              => 'rw',
    isa             => 'Bool',
    default         => 0
);

sub length {
    my ($self) = @_;
    given ($self->location_type) {
        when ([qw(EXACT WITHIN)]) {
            return $self->end - $self->start + 1;
        }
        default {
            return 0
        }
    }
}

my %IS_FUZZY = map {$_ => 1} qw(BEFORE AFTER WITHIN UNCERTAIN);

# these just delegate to start, end, using the indicated offsets
sub max_start {
    my ($self) = @_;
    my $start = $self->start;
    return unless $start;
    ($start + $self->start_offset);
}

sub min_start {
    my ($self) = @_;
    my $start = $self->start;
    return if !$start || ($self->start_pos_type eq 'BEFORE');
    $start;
}

sub max_end {
    my ($self) = @_;
    my $end = $self->end;
    return if !$end || ($self->end_pos_type eq 'AFTER');
    return ($end + $self->end_offset);
}

sub min_end {
    my ($self) = @_;
    my $end = $self->end;
    return unless $end;
}

sub is_fuzzy {
    my $self = shift;
    (exists $IS_FUZZY{$self->start_pos_type} ||
        exists $IS_FUZZY{$self->end_pos_type}) ? 1 : 0;
}

# TODO: change to validate(), ban from roles (method should be defined in consuming class)
# TODO: method doesn't take into account '?' and undef start/end
sub valid_Location {
    defined($_[0]->start) && defined($_[0]->end) ? 1 : 0;
}

# TODO: remove or make specific to role
sub to_string {
    my ($self) = @_;

    my $type = $self->location_type;

    # TODO: should be in Split role, with a method modifier?
    if (is_Split_Location_Type($type)) {
        my @segs = $self->sub_Locations;
        my $str;
        if ($self->strand == -1) {
            $str = lc($type).'('.join(',', map {$_->to_string} @segs).')';
            $str = "complement($str)";
        } else {
            $str = lc($type).'('.join(',', map {$_->to_string} @segs).')'
        }
        return $str;
    }

    my %data;
    for (qw(
        start end
        min_start max_start
        min_end max_end
        start_offset end_offset
        start_pos_type end_pos_type
        is_remote
        seq_id
        location_type)) {
        $data{$_} = $self->$_;
    }

    for my $pos (qw(start end)) {
        my $pos_str = $data{$pos} || '';
        given ($data{"${pos}_pos_type"}) {
            when ('WITHIN') {
                $pos_str = '('.$data{"min_$pos"}.'.'.$data{"max_$pos"}.')';
            }
            when ('BEFORE') {
                $pos_str = '<'.$pos_str;
            }
            when ('AFTER') {
                $pos_str = '>'.$pos_str;
            }
            when ('UNCERTAIN') {
                $pos_str = '?'.$pos_str;
            }
            default {
                # is there an easier way to deal with this?
                if ($pos eq 'end' &&
                    ($data{start} && $data{end}) &&
                    ($data{start} == $data{end})) {
                    $pos_str = ''
                }
            }
        }
        $data{"${pos}_string"} = $pos_str;
    }

    my $str = $data{start_string}. ($data{end_string} ?
            to_Location_Symbol($data{location_type}).
            $data{end_string} : '');
    $str = "$data{seq_id}:$str" if $data{seq_id} && $data{is_remote};
    $str = "($str)" if $data{location_type} eq 'WITHIN';
    if ($self->strand == -1) {
        $str = sprintf("complement(%s)",$str)
    }
    $str;
}

sub flip_strand {
    my $self= shift;
    $self->strand($self->strand * -1);
}

sub _build_union {
    my ($self, $five_prime, $three_prime, $strand) = @_;
    return (blessed $self)->new(-start 			=> $five_prime->start,
                            -start_pos_type	=> $five_prime->start_pos_type,
                            -end 			=> $three_prime->end,
                            -end_pos_type	=> $three_prime->end_pos_type,
                            -strand 		=> $strand);
}

1;

__END__

=head1 NAME

Biome::Role::Location::Simple - Role for describing simple biological locations
and coordinates.

=head1 SYNOPSIS

   with 'Biome::Role::Location::Simple';
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

This role describes a biological location or segment, one which has a simple
start, end, and strand (all attributes).

=head1 SUBROUTINES/METHODS

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

Copyright (c) 2011 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head2 location_type

  Title   : location_type
  Usage   : my $location_type = $location->location_type();
  Function: Get location type encoded as text
  Returns : string ('EXACT', 'WITHIN', 'IN-BETWEEN')
  Args    : none

=head2 start

  Title   : start
  Usage   : $start = $location->start();
  Function: Get the start coordinate of this location. In
            simple cases, this will return the same number as
            min_start() and max_start(), in more ambiguous cases like
            fuzzy locations the number may be equal to one or neither
            of both.
  Returns : A positive integer value.
  Args    : none

=head2 end

  Title   : end
  Usage   : $end = $location->end();
  Function: Get the end coordinate of this location as defined by the
            currently active coordinate computation policy. In simple
            cases, this will return the same number as min_end() and
            max_end(), in more ambiguous cases like fuzzy locations
            the number may be equal to one or neither of both.

            We override this here from Bio::RangeI in order to delegate
            'get' to a L<Bio::Location::CoordinatePolicy> implementing
            object. Implementing classes may also wish to provide
            'set' functionality, in which case they *must* override
            this method. The implementation provided here will throw
            an exception if called with arguments.

  Returns : A positive integer value.
  Args    : none

See L<Bio::Location::CoordinatePolicy> and L<Bio::RangeI> for more
information

=head2 strand

  Title   : strand
  Usage   : $strand = $loc->strand();
  Function: get/set the strand of this range
  Returns : the strandidness (-1, 0, +1)
  Args    : optionaly allows the strand to be set
          : using $loc->strand($strand)

=head2 to_FTstring

  Title   : to_FTstring
  Usage   : my $locstr = $location->to_FTstring()
  Function: returns the FeatureTable string of this location
  Returns : string
  Args    : none

=head2 valid_Segment

 Title   : valid_Segment
 Usage   : if ($location->valid_Location) {...};
 Function: boolean method to determine whether location is considered valid
           (has minimum requirements for a specific Location implementation)
 Returns : Boolean value: true if location is valid, false otherwise
 Args    : none

=head2 is_remote

 Title   : is_remote
 Usage   : $is_remote_loc = $loc->is_remote()
 Function: Whether or not a location is a remote location.

           A location is said to be remote if it is on a different
           'object' than the object which 'has' this
           location. Typically, features on a sequence will sometimes
           have a remote location, which means that the location of
           the feature is on a different sequence than the one that is
           attached to the feature. In such a case, $loc->seq_id will
           be different from $feat->seq_id (usually they will be the
           same).

           While this may sound weird, it reflects the location of the
           kind of AB18375:450-900 which can be found in GenBank/EMBL
           feature tables.

 Example :
 Returns : TRUE if the location is a remote location, and FALSE otherwise
 Args    :

=head2 flip_strand

  Title   : flip_strand
  Usage   : $location->flip_strand();
  Function: Flip-flop a strand to the opposite
  Returns : None
  Args    : None

=head2 start_pos_type

  Title   : pos_type
  Usage   : my $start_pos_type = $location->pos_type('start');
  Function: Get indicated position type encoded as text

            Known valid values are 'BEFORE' (<5..100), 'AFTER' (>5..100),
            'EXACT' (5..100), 'WITHIN' ((5.10)..100), 'BETWEEN', (5^6), with
            their meaning best explained by their GenBank/EMBL location string
            encoding in brackets.

  Returns : string ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none


=head2 end_pos_type

  Title   : pos_type
  Usage   : my $start_pos_type = $location->pos_type('start');
  Function: Get indicated position type encoded as text

            Known valid values are 'BEFORE' (<5..100), 'AFTER' (>5..100),
            'EXACT' (5..100), 'WITHIN' ((5.10)..100), 'BETWEEN', (5^6), with
            their meaning best explained by their GenBank/EMBL location string
            encoding in brackets.

  Returns : string ('BEFORE', 'AFTER', 'EXACT','WITHIN', 'BETWEEN')
  Args    : none

=head2 seq_id

  Title   : seq_id
  Usage   : my $seqid = $location->seq_id();
  Function: Get/Set seq_id that location refers to
  Returns : seq_id (a string)
  Args    : [optional] seq_id value to set

=cut
