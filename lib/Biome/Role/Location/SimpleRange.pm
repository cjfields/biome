package Biome::Role::Location::SimpleRange;

use Biome::Role;
use namespace::clean -except => 'meta';

use Biome::Type::Sequence qw(Sequence_Strand);

has strand  => (
    isa     => Sequence_Strand,
    is      => 'rw',
    default => 0,
    coerce  => 1
);


has start   => (
    is      => 'rw',
    isa     => 'Num',
);

has end     => (
    is      => 'rw',
    isa     => 'Num'
);

# TODO - It should be possible to stack roles (have an implementation role
# consume an interface role), but for some reason this isn't working here.
# Problem isn't traceable to Biome-specific classes, so will need to simplify
# this down to trace the problem. For time being, interface is resolved in the
# class, not the role implementation

#with 'Biome::Role::Location::Does_Range';

sub length {
    $_[0]->end - $_[0]->start + 1;
}

sub to_string {
    my ($self) = @_;
    return sprintf("(%s, %s) strand=%s",
                   $self->start,
                   $self->end,
                   $self->strand);
}

sub from_string {
    $_[0]->throw_not_implemented;
}

sub flip_strand {
    $_[0]->strand($_[0]->strand * -1);
}

1;

__END__

=head1 NAME

Biome::Role::Range - Base role for simple ranges or segments

=head1 VERSION

This documentation refers to Biome::Role::Range version 0.001.

=head1 SYNOPSIS

   with 'Biome::Role::Range';
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

This Role describes simple attributes and actions for a Range.  In
biological terms, a Range is a 

=head1 ATTRIBUTES

=head2 start

  Title   : start
  Usage   : $start = $range->start();
  Function: get/set the start of this range
  Returns : the start of this range
  Args    : optionally allows the start to be set
            using $range->start($start)

=cut

=head2 end

  Title   : end
  Usage   : $end = $range->end();
  Function: get/set the end of this range
  Returns : the end of this range
  Args    : optionally allows the end to be set
            using $range->end($end)

=cut

=head2 length

  Title   : length
  Usage   : $length = $range->length();
  Function: get/set the length of this range
  Returns : the length of this range
  Args    : optionally allows the length to be set
             using $range->length($length)

=cut

=head2 strand

  Title   : strand
  Usage   : $strand = $range->strand();
  Function: get/set the strand of this range
  Returns : the strandedness (-1, 0, +1)
  Args    : optionally allows the strand to be set
            using $range->strand($strand)

=cut

=head1 BOOLEAN METHODS

These methods return true or false. They throw an error if start and
end are not defined.

  $range->overlaps($otherRange) && print "Ranges overlap\n";

=head2 overlaps

  Title   : overlaps
  Usage   : if($r1->overlaps($r2)) { do stuff }
  Function: tests if $r2 overlaps $r1
  Args    : arg #1 = a range to compare this one to (mandatory)
            arg #2 = optional strand-testing arg ('strong', 'weak', 'ignore')
  Returns : true if the ranges overlap, false otherwise

=cut

=head2 contains

  Title   : contains
  Usage   : if($r1->contains($r2) { do stuff }
  Function: tests whether $r1 totally contains $r2
  Args    : arg #1 = a range to compare this one to (mandatory)
                 alternatively, integer scalar to test
            arg #2 = optional strand-testing arg ('strong', 'weak', 'ignore')
  Returns : true if the argument is totally contained within this range

=cut

=head2 equals

  Title   : equals
  Usage   : if($r1->equals($r2))
  Function: test whether $r1 has the same start, end, length as $r2
  Args    : arg #1 = a range to compare this one to (mandatory)
            arg #2 = optional strand-testing arg ('strong', 'weak', 'ignore')
  Returns : true if they are describing the same range

=cut

=head1 GEOMETRIC METHODS

These methods do things to the geometry of ranges, and return
Bio::RangeI compliant objects or triplets (start, stop, strand) from
which new ranges could be built.

=head2 intersection

 Title   : intersection
 Usage   : ($start, $stop, $strand) = $r1->intersection($r2); OR
           ($start, $stop, $strand) = Bio::Range->intersection(\@ranges); OR
           my $containing_range = $r1->intersection($r2); OR
           my $containing_range = Bio::Range->intersection(\@ranges);
 Function: gives the range that is contained by all ranges
 Returns : undef if they do not overlap, or
           the range that they do overlap (in the form of an object
            like the calling one, OR a three element array)
 Args    : arg #1 = [REQUIRED] a range to compare this one to,
                    or an array ref of ranges
           arg #2 = optional strand-testing arg ('strong', 'weak', 'ignore')

=cut

=head2 union

   Title   : union
    Usage   : ($start, $stop, $strand) = $r1->union($r2);
            : ($start, $stop, $strand) = Bio::Range->union(@ranges);
              my $newrange = Bio::Range->union(@ranges);
    Function: finds the minimal Range that contains all of the Ranges
    Args    : a Range or list of Range objects
    Returns : the range containing all of the range
              (in the form of an object like the calling one, OR
              a three element array)

=cut

=head2 overlap_extent

 Title   : overlap_extent
 Usage   : ($a_unique,$common,$b_unique) = $a->overlap_extent($b)
 Function: Provides actual amount of overlap between two different
           ranges
 Example :
 Returns : array of values containing the length unique to the calling
           range, the length common to both, and the length unique to
           the argument range
 Args    : a range

=cut

=head2 disconnected_ranges

    Title   : disconnected_ranges
    Usage   : my @disc_ranges = Bio::Range->disconnected_ranges(@ranges);
    Function: finds the minimal set of ranges such that each input range
              is fully contained by at least one output range, and none of
              the output ranges overlap
    Args    : a list of ranges
    Returns : a list of objects of the same type as the input
              (conforms to RangeI)

=cut

=head2 offsetStranded

    Title    : offsetStranded
    Usage    : $rnge->ofsetStranded($fiveprime_offset, $threeprime_offset)
    Function : destructively modifies RangeI implementing object to
               offset its start and stop coordinates by values $fiveprime_offset and
               $threeprime_offset (positive values being in the strand direction).
    Args     : two integer offsets: $fiveprime_offset and $threeprime_offset
    Returns  : $self, offset accordingly.

=cut

=head2 subtract

  Title   : subtract
  Usage   : my @subtracted = $r1->subtract($r2)
  Function: Subtract range r2 from range r1
  Args    : arg #1 = a range to subtract from this one (mandatory)
            arg #2 = strand option ('strong', 'weak', 'ignore') (optional)
  Returns : undef if they do not overlap or r2 contains this RangeI,
            or an arrayref of Range objects (this is an array since some
            instances where the subtract range is enclosed within this range
            will result in the creation of two new disjoint ranges)

=cut

=head1 DIAGNOSTICS

None

=head1 DEPENDENCIES

None

=head1 INCOMPATIBILITIES

This describes a very simplistic range. For more complicate ranges (e.g. ones
with undefined start/end, with location on various segments) this will NOT work,
so relevant methods should be overloaded (and attributes added to) to accomodate
the specific range model.

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

From BioPerl:

Bio::Range
Bio::RangeI

From Biome:

Biome::Role::Segment
Biome::Role::Segment::Simple
Biome::Role::Location

=head1 (DISCLAIMER OF) WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

The original module authors and contributors for Bio::RangeI and Bio::Range:

Matthew Pocock
Heikki Lehvaslaiho
Juha Muilu
Sendu Bala
Malcolm Cook
Stephen Montgomery

=head1 AUTHOR

Chris Fields  C<< <cjfields at bioperl dot org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Chris Fields (cjfields at bioperl dot org). All rights
reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
