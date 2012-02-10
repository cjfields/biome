package Biome::Role::Location::Split;

use 5.010;
use Biome::Role;
use Biome::Type::Location qw(Split_Location_Type ArrayRef_of_Locatable);
use Biome::Type::Sequence qw(Maybe_Sequence_Strand);
use List::Util qw(reduce);
use namespace::clean -except => 'meta';

# TODO: make this a parameterized role at some point? The
# attributes and methods could be named based on the consuming class...

has     'locations'  => (
    is          => 'ro',
    isa         => ArrayRef_of_Locatable,
    traits      => ['Array'],
    init_arg    => undef,
    writer      => '_set_locations',
    handles     => {
        #  override this to allow for expansion of parent location
        #push_sub_Location     => 'push',
        sub_Locations         => 'elements',
        remove_sub_Locations  => 'clear',
        get_sub_Location      => 'get',
        num_sub_Locations     => 'count',
    },
    lazy        => 1,
    default     => sub { [] }
);

has     'auto_expand'   => (
    isa         => 'Bool',
    is          => 'ro',
    default     => 1
);

sub add_sub_Location {
    my ($self, $loc) = @_;

    if (!is_Split_Location_Type($self->location_type)) {
        $self->throw("Type ".$self->location_type." does not allow sub locations, change location_type");
    }

    my $locs = $self->locations;

    #if ($self->auto_expand && !$loc->is_remote) {
    #    my ($start,$end,$strand) = @$locs ? ($self->union($loc)) :
    #        ($loc->start, $loc->end, $loc->strand);
    #    $self->strand($strand);
    #    $self->start($start);
    #    $self->end($end);
    #    $self->seq_id($loc->seq_id) if $loc->seq_id && @$locs;
    #}

    if ($self->auto_expand && !$loc->is_remote) {
        my $union_loc =  @$locs ? $self->union($locs) : $loc;
        print STDERR "Union:".$union_loc->to_string."\n";

        $self->strand($union_loc->strand);
        $self->start($union_loc->start);
        $self->end($union_loc->end);
        #$self->max_start($loc->max_start);
        #$self->min_start($loc->min_start);
        #$self->start_pos_type($loc->start_pos_type);
        #$self->end_pos_type($loc->end_pos_type);
        $self->seq_id($loc->seq_id) if $loc->seq_id && @$locs;
    }

    push @$locs, $loc;

    1;
}

#has     'location_type'    => (
#    isa         => Split_Location_Type,
#    is          => 'rw',
#    lazy        => 1,
#    default     => 'JOIN'
#);

#has     'resolve_Locations'      => (
#    isa         => 'Bool',
#    is          => 'rw',
#    lazy        => 1,
#    default     => 1,
#);
#
#sub length {
#    my ($self) = @_;
#    return $self->end - $self->start + 1;
#}
#
#sub sub_Location_strand {
#    my ($self) = @_;
#    my ($strand, $lstrand);
#
#    # this could use reduce()
#    foreach my $loc ($self->sub_Locations()) {
#        $lstrand = $loc->strand();
#        if((! $lstrand) ||
#           ($strand && ($strand != $lstrand)) ||
#           $loc->is_remote()) {
#            $strand = undef;
#            last;
#        } elsif(! $strand) {
#            $strand = $lstrand;
#        }
#    }
#    return $strand;
#}
#
## overrides
#
#has     'strand'      => (
#    isa         => Maybe_Sequence_Strand,
#    is          => 'rw',
#    lazy        => 1,
#    predicate   => 'has_strand',
#    default     => sub {
#        my $self = shift;
#        return $self->sub_Location_strand;
#        },
#);
#
#sub start {
#    my ($self, $start) = @_;
#    $self->get_sub_Location(0)->start($start) if defined($start);
#    return $self->get_sub_Location(0)->start if $self->is_remote;
#    return $self->_reduce('start');
#}
#
#sub end {
#    my ($self, $end) = @_;
#    $self->get_sub_Location(0)->end($end) if defined($end);
#    return $self->get_sub_Location(0)->end if $self->is_remote;
#    return $self->_reduce('end');
#}
#
#sub is_remote {
#    my $self = shift;
#    for my $seg ($self->sub_Locations) {
#        return 1 if $seg->is_remote;
#    }
#    0;
#}
#
#sub min_start {
#    my $self = shift;
#    return $self->get_sub_Location(0)->min_start if $self->is_remote;
#    return $self->_reduce('min_start');
#}
#
#sub max_start {
#    my $self = shift;
#    return $self->get_sub_Location(0)->max_start if $self->is_remote;
#    return $self->_reduce('max_start');
#}
#
#sub min_end {
#    my $self = shift;
#    return $self->get_sub_Location(0)->min_end if $self->is_remote;
#    return $self->_reduce('min_end');
#}
#
#sub max_end {
#    my $self = shift;
#    return $self->get_sub_Location(0)->max_end if $self->is_remote;
#    return $self->_reduce('max_end');
#}
#
#sub start_pos_type {
#    my $self = shift;
#    my $type = reduce {$a eq $b ? $a : undef}
#        map {$_->start_pos_type} $self->sub_Locations;
#    return $type;
#}
#
#sub end_pos_type {
#    my $self = shift;
#    my $type = reduce {$a eq $b ? $a : undef}
#        map {$_->end_pos_type} $self->sub_Locations;
#    return $type;
#}
#
#sub valid_Location {
#    # TODO: add tests
#    my $self = shift;
#    my $type = reduce {$a eq $b ? 1 : 0}
#        map {$_->valid_Location} $self->sub_Locations;
#}
#
#sub is_fuzzy {
#    # TODO: add tests
#    my $self = shift;
#    my $type = reduce {$a eq $b ? 1 : 0}
#        map {$_->is_fuzzy} $self->sub_Locations;
#}
#
## no offsets for splits?  Or maybe for only the first/last one?
#sub start_offset { 0 }
#
#sub end_offset { 0 }
#
#sub flip_strand {
#    my $self = shift;
#    my @segs = @{$self->locations()};
#    @segs = map {$_->flip_strand(); $_} reverse @segs;
#    $self->_set_locations(\@segs);
#}
#
#sub to_string {
#    my $self = shift;
#    # JOIN assumes specific order, ORDER does not, BOND ?
#    my $type = $self->location_type;
#    if ($self->resolve_Locations) {
#        my $substrand = $self->sub_Location_strand;
#        if ($substrand && $substrand < 0) {
#            $self->flip_strand();
#            $self->strand(-1);
#        }
#    }
#    my @segs = $self->sub_Locations;
#    my $str = lc($type).'('.join(',', map {$_->to_string} @segs).')';
#    if ($self->strand && $self->strand < 0) {
#        $str = "complement($str)";
#    }
#    $str;
#}
#
## could do all string parsing here instead of FTLocationFactory...
#sub from_string {
#    shift->throw_not_implemented;
#}
#
## helper, just grabs the indicated value for the contained locations
#sub _reduce {
#    my ($self, $caller) = @_;
#    my @segs = sort {
#        $a->$caller <=> $b->$caller
#                     }
#    grep {$_->$caller} $self->sub_Locations;
#    return unless @segs == $self->num_sub_Locations;
#    $caller =~ /start/ ? return $segs[0]->$caller : return $segs[-1]->$caller;
#}

1;

__END__

=head1 NAME

Biome::Role::Location::Split - Role describing split locations.

=head1 SYNOPSIS

    {
        package Foo;

        with 'Biome::Role::Location::Split';
         other necessary roles...

    }

    {
        package Bar;
        with 'Biome::Role::Location::Simple';
         other necessary roles...
    }

    my $split = Foo->new(-start => 7, -end => 100, -strand => 1);

    my $loc1 = Bar->new(-start => 1, -end => 50, -strand => -1);
    my $loc2 = Bar->new(-start => 75, -end => 150); # no strandedness defined

    $split->add_subLocation($loc1);
    $split->add_subLocation($loc2);

     Split locations autoexpand to whatever subLocations they contain by
     default and the strand is defined by the subLocations. This is b/c this
     implementation is just a simple top-level location that contains other
     simple Locations, so the borders should match accordingly and the strand
     be dictated by them. However, as this is a simple location, the strand
     won't be affected.

    say $split->start; # 1
    say $split->end;   # 150
    say $split->strand; # 0, strand for sublocations is different

     If you want to explicitly change the top-level coordinate in some way,
     then do so after one has finished adding subLocations.

    $split->start(100);
    $split->strand(1);
    say $split->start; # 100

     If you really don't want the split location coordinates set by
     subLocations, set autoexpand to 0

    $split = Foo->new(-start => 7, -end => 100, -strand => 1, -autoexpand => 0);

    my $loc1 = Bar->new(-start => 1, -end => 50, -strand => -1);
    my $loc2 = Bar->new(-start => 75, -end => 150); # no strandedness defined

    $split->add_subLocation($loc1);
    $split->add_subLocation($loc2);

    say $split->start; # 7
    say $split->end;   # 100
    say $split->strand; # 1

     The default internal behavior for storing sub-Locations is as they are
     added (similar in behavior to a JOIN). One can change this by designating
     the split_location_type to ORDER, which sorts internal locations by the
     start.



=head1 DESCRIPTION

This role describes

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

Chris Fields  C<< <cjfields at bioperl dot org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
