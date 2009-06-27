package Bio::Moose::Role::PrimarySeq;

use Bio::Moose::Role;

#requires qw(translate trunc revcom subseq length);

# greedy method, guaranteed to return a raw sequence
# may need make this into a separate method as opposed to an attribute
has rawseq => (
    is    => 'rw',
    isa   => 'Str',
);

# make a subtype or coerce input into a subtype?
has alphabet => (
   is    => 'rw',
   isa   => 'Str',
);

has is_circular => (
   is    => 'rw',
   isa   => 'Bool'
);

# this is now localized to the instance (no longer global) due to issues noted
# with BioPerl. Will shift this to a builder for symbol validation (I think we
# should allow a narrow set of symbols for now, maybe enum, i.e. GAP, RESIDUE,
# FRAMESHIFT)

has symbols => (
    is   => 'rw',
    isa  => 'HashRef[Str]',
    default => sub { {
        'RESIDUE' => 'A-Za-z*?=',
        'GAP'     => '-.~'
    } }
    );

# alias for rawseq, to disambiguate use of this from returning an object
sub seq {
    my $self = shift;
    $self->rawseq();
}

# returns raw subsequence; trunc() returns similar, but object
sub subseq {
    my $self = shift;
    my ($start,$end,$strand,$gaps,$replace) = $self->rearrange([qw(START 
                                                           END
                                                           STRAND
                                                           GAPS
                                                           REPLACE_WITH)],@_);
    
    $strand //= 1;
    $gaps //= 1;
    
    # This doesn't account for classes possibly implementing Ranges or
    # Locations, but only for the presence of simple gaps. Such alternatives
    # will be localized to Range/Location-specific implementations (we can't
    # account for all variations and additional constraints, such as laziness,
    # fly/lightweight, etc.)
    
    if( ref($start) && $start->does('Bio::Moose::Role::Range') ) {
        # does not handle complex locations; not sure whether we should
        # implement or not (segments are much easier, and relevant code such as
        # sliced_seq can DTRT by calling this as needed)
        ($start, $end, $strand) = ($start->start, $start->end, $start->strand);
    }
    if(defined $start && defined $end ) {
        if( $start > $end ) {
        $self->throw("Bad start,end parameters. Start [$start] has to be ".
             "less than end [$end]");
        }
        if( $start <= 0 ) {
            $self->throw("Bad start parameter ($start). Start must be positive.");
        }
        if( $end > $self->length ) {
            $self->throw("Bad end parameter ($end). End must be less than the total length of sequence (total=".$self->length.")");
        }
        
        # convert all coordinates to 0-origin
        $start--;
        $end--;
        my $seqstr;
        my $rawseq = $self->rawseq;
        if ($self->has_gaps) {
            my $gs = ${$self->symbols}{GAP};
            # map gaps prior and post start/end
            my ($newst, $newend) = ($start, $end);
            while ($rawseq =~ m{([$gs]+)}g) {
                my $len = CORE::length($1);
                my $current = pos($rawseq) - $len;
                # optimization : bail if current gap is past the end
                last if $current >= $newend;
                $newst += $len if $current <= $newst;
                $newend += $len if $current <= $newend;
            }
            $seqstr = substr($rawseq, $newst, $newend -$newst + 1);
            $seqstr =~ s/[$gs]//g unless $gaps;
        } else {
            $seqstr = substr($rawseq, $start, $end -$start + 1);            
        }
        return $seqstr;
    }
    else {
        $self->warn("Incorrect parameters to subseq - must be two integers ".
            "or a Bio::LocationI object. Got:", $self,$start,$end,$replace,$gaps);
        return;
    }
}

sub revcom {
    my ($self) = @_;
 
    # check the type is good first.
    my $t = $self->alphabet;
 
    if( $t eq 'protein' ) {
        $self->throw("Sequence is a protein. Cannot revcom");
    }
 
    if( $t ne 'dna' && $t ne 'rna' ) {
        $self->warn("Sequence is not dna or rna, but [$t]. ".
                "Attempting to revcom, but unsure if this is right");
    }

    # yank out the sequence string
 
    my $str = $self->seq();
 
    # if is RNA - map to DNA then map back
 
    if( $t eq 'rna' ) {
        $str =~ tr/uU/tT/;
    }
 
    # revcom etc...
 
    $str =~ tr/acgtrymkswhbvdnxACGTRYMKSWHBVDNX/tgcayrkmswdvbhnxTGCAYRKMSWDVBHNX/;
    my $revseq = CORE::reverse $str;
 
    if( $t eq 'rna' ) {
        $revseq =~ tr/tT/uU/;
    }
 
    my $seqclass = ref($self);
    my $out = $seqclass->clone(
                    '-seq' => $revseq,
                    '-is_circular'  => $self->is_circular,
                    '-display_id'  => $self->display_id,
                    '-accession_number' => $self->accession_number,
                    '-alphabet' => $self->alphabet,
                    '-desc' => $self->desc(),
                    '-verbose' => $self->verbose
                  );
    return $out;
}

sub has_gaps {
    my $self = shift;
    my @gap_sym = split('',${$self->symbols}{GAP});
    my $rawseq = $self->rawseq;
    for my $g (@gap_sym) {
        return 1 if (index($self->rawseq, $g) >= 0);
    }
    return 0;
}

sub trunc {
    my $self = shift;
    my $seq = $self->subseq(@_);
    
}

#sub translate {
#}

# account for sequences with gaps
sub length {
    my $self = shift;
    my $len = $self->rawseq();
    if ($self->has_gaps) {
        my $gs = quotemeta(${$self->symbols}{GAP});
        $len =~ s{$gs}{}g;
    }
    CORE::length($len);
}

no Bio::Moose::Role;

1;

__END__
