package Biome::Role::Does_Range;

use Biome::Role;
use namespace::clean -except => 'meta';

requires qw(
    seq_id
    start
    end
    strand
    length
    
    flip_strand
    
    from_string
    to_string
);

# returns true if strands are equal and non-zero
our %VALID_STRAND_TESTS = (
    'strong' => 1,
    'weak'   => 1,
    'ignore' => 1
    );

sub _strong {
    my ($s1, $s2) = ($_[0]->strand, $_[1]->strand);
    ($s1 != 0 && $s1 == $s2) ? 1 : 0
}

sub _weak {
    my ($s1, $s2) = ($_[0]->strand, $_[1]->strand);
    ($s1 == 0 || $s2 == 0 || $s1 == $s2) ? 1 : 0;
}

sub _ignore { 1 }

# works out what test to use for the strictness and returns true/false
# e.g. $r1->_testStrand($r2, 'strong')
sub _testStrand() {
    my ($r1, $r2, $comp) = @_;
    return 1 unless $comp;
    $r1->throw("$comp is not a supported strand test") unless exists $VALID_STRAND_TESTS{lc $comp};
    my $test = '_'.lc $comp;
    return $r1->$test($r2);
}

sub overlaps {
    my ($self, $other, $so) = @_;
    $self->_eval_ranges($other);
    ($self->_testStrand($other, $so)
        && !(($self->start() > $other->end() || $self->end() < $other->start())))
    ? 1 : 0;
}

sub contains {
    my ($self, $other, $so) = @_;
    $self->_eval_ranges($other);
    ($self->_testStrand($other, $so)
        && $other->start() >= $self->start() && $other->end() <= $self->end())
    ? 1 : 0;
}

sub equals {
    my ($self, $other, $so) = @_;
    $self->_eval_ranges($other);
    ($self->_testStrand($other, $so)
        && $self->start() == $other->start() && $self->end() == $other->end())
    ? 1 : 0;
}

# Original interface for this is a bit odd (accepts array or array ref with
# strand test). API also differs from union()
# Original code did not include appear to include self for some reason.

sub intersection {
    my ($self, $given, $so) = @_;
    $self->throw("Missing arg: you need to pass in another Range") unless $given;
    $so ||= 'ignore';
    my @ranges;
    ref($given) eq 'ARRAY' ? push( @ranges, @{$given}) : push(@ranges, $given);

    $self->_eval_ranges(@ranges);
    my $intersect;
    while (@ranges > 0) {
        unless ($intersect) {
            $intersect = $self;
        }

        my $compare = shift(@ranges);
        
        last if !defined $compare;
        
        if (!$compare->_testStrand($intersect, $so)) {
            return
        }

        my @starts = sort {$a <=> $b} ($intersect->start(), $compare->start());
        my @ends   = sort {$a <=> $b} ($intersect->end(), $compare->end());

        my $start = pop @starts; # larger of the 2 starts
        my $end = shift @ends;   # smaller of the 2 ends

        my $intersect_strand;    # strand for the intersection
        if (defined($intersect->strand) && defined($compare->strand) && $intersect->strand == $compare->strand) {
            $intersect_strand = $compare->strand;
        }
        else {
            $intersect_strand = 0;
        }

        if ($start > $end) {
            return;
        } else {
            $intersect = (blessed $self)->new(-start  => $start,
                                    -end    => $end,
                                    -strand => $intersect_strand);
        }
    }
    return $intersect;     
}

sub union {
    my ($self, $given, $so) = @_;
    
    # strand test doesn't matter here 
    
    $self->_eval_ranges(@$given);
    
    my @start = sort {$a <=> $b} map { $_->start() } ($self, @$given);
    my @end   = sort {$a <=> $b} map { $_->end()   } ($self, @$given);

    my $start = shift @start;
    while( !defined $start ) {
        $start = shift @start;
    }

    my $end = pop @end;

    my $union_strand = $self->strand;  # Strand for the union range object.

    for my $r (@$given) {
        if(!defined $r->strand || $union_strand ne $r->strand) {
            $union_strand = 0;
            last;
        }
    }
    return unless $start || $end;
    return (blessed $self)->new('-start' => $start,
                      '-end' => $end,
                      '-strand' => $union_strand
                      );
}

### Other methods

# should this return lengths or Range implementors?
# currently, returns integers, but I think Ranges would be more informative...

sub overlap_extent{
	my ($a,$b) = @_;

	$a->_eval_ranges($b);

	if( ! $a->overlaps($b) ) {
	    return ($a->clone,0,$b->clone);
	}

	my ($au,$bu) = (0, 0);
	if( $a->start < $b->start ) {
		$au = $b->start - $a->start;
	} else {
		$bu = $a->start - $b->start;
	}

	if( $a->end > $b->end ) {
		$au += $a->end - $b->end;
	} else {
		$bu += $b->end - $a->end;
	}

	my $intersect = $a->intersection($b);
	if( ! $intersect ) {
	    $a->warn("no intersection\n");
	    return ($au, 0, $bu);
	} else {
	    my $ie = $intersect->end;
	    my $is = $intersect->start;
	    return ($au,$ie-$is+1,$bu);
	}
}

sub subtract {
    my ($self, $range, $so) = @_;

    return $self unless $self->_testStrand($range, $so);

    $self->_eval_ranges($range);

    if (!$self->overlaps($range)) {
        return $self;  # no Range; maybe this should be Range?
    }

    # Subtracts everything (empty Range of length = 0 and strand = 0 
    if ($self->equals($range) || $range->contains($self)) {
        return (blessed $self)->new(-start => 0, -end => 0, -strand => 0);
    }

    my $int = $self->intersection($range, $so);
    my ($start, $end, $strand) = ($int->start, $int->end, $int->strand);
    
    #Subtract intersection from $self
    my @outranges = ();
    if ($self->start < $start) {
        push(@outranges, 
		 (blessed $self)->new(
                '-start'=> $self->start,
			    '-end'=>$start - 1,
			    '-strand'=>$self->strand,
			   ));
    }
    if ($self->end > $end) {
        push(@outranges, 
		 (blessed $self)->new('-start'=>$end + 1,
			    '-end'=>$self->end,
			    '-strand'=>$self->strand,
			   ));   
    }
    return @outranges;
}

# should be genericized for nonstranded Ranges.  I'm not sure about
# modifying the object in place...

sub offset_stranded { 
    my ($self, $offset_fiveprime, $offset_threeprime) = @_;
    my ($offset_start, $offset_end) = $self->strand() eq -1 ?
        (- $offset_threeprime, - $offset_fiveprime) :
        ($offset_fiveprime, $offset_threeprime);
    $self->start($self->start + $offset_start);
    $self->end($self->end + $offset_end);
    return $self;
}

############## PRIVATE ##############

# called as instance method only; does slow things down a bit...
sub _eval_ranges {
    my ($self, @ranges) = @_;
    #$self->throw("start is undefined in calling instance") if !defined $self->start;
    #$self->throw("end is undefined in calling instance") if !defined $self->end;    
    for my $obj ($self, @ranges) {
        $self->throw("Not an object") unless ref($obj);
        $self->throw("start is undefined in instance ".$obj->to_string) if !defined $obj->start;
        $self->throw("end is undefined in instance ".$obj->to_string) if !defined $obj->end;
        $self->throw('Rangeable equality or set methods not '.
                     'implemented yet for fuzzy locations') if
            $self->does('Bio::Range::Segment') && $self->is_fuzzy;
    }
}


1;

__END__

=head1 NAME

Biome::Role::Does_Range - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Biome::Role::Does_Range version Biome::Role.

=head1 SYNOPSIS

   with 'Biome::Role::Does_Range';
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

Copyright (c) 2010 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
