package Bio::Moose::Role::PrimarySeq;

use Bio::Moose::Role;

#requires qw(translate);

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
    
    my $out = $self->clone(-rawseq => $revseq);
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
    my ($self) = shift;
    return $self->clone(-rawseq => $self->subseq(@_));
}

# needs minor cleaning up, CodonTable (or similar) implementation
# Speaking of, we need a common base class that contains simple
# data, such as IUPAC, codon table info, etc. 

sub translate {
    my ($self,@args) = @_;
    $self->throw_not_implemented();
    #my ($terminator, $unknown, $frame, $codonTableId, $complete, $throw,
    #     $codonTable, $orf, $start_codon, $offset) =
    #        $self->rearrange([qw(TERMINATOR
    #                           UNKNOWN
    #                           FRAME
    #                           CODONTABLE_ID
    #                           COMPLETE
    #                           THROW
    #                           CODONTABLE
    #                           ORF
    #                           START
    #                           OFFSET)], @args);
    ### Initialize termination codon, unknown codon, codon table id, frame
    #$terminator //= '*';
    #$unknown //= "X";
    #$frame //= 0;
    #$codonTableId //= 1;
    #
    ### Get a CodonTable, error if custom CodonTable is invalid
    ##if ($codonTable) {
    ##     $self->throw("Need a Bio::Tools::CodonTable object, not ". $codonTable)
    ##        unless $codonTable->isa('Bio::Tools::CodonTable');
    ##} else {
    ##     $codonTable = Bio::Tools::CodonTable->new( -id => $codonTableId);
    ##}
    #
    ### Error if alphabet is "protein"
    #$self->throw("Can't translate an amino acid sequence.") if
    #    ($self->alphabet =~ /protein/i);
    #
    ### Error if -start parameter isn't a valid codon
    #if ($start_codon) {
    #    $self->throw("Invalid start codon: $start_codon.") if
    #       ( $start_codon !~ /^[A-Z]{3}$/i );
    #}
    # 
    #my $seq;
    # 
    #if ($offset) {
    #   $self->throw("Offset must be 1, 2, or 3.") if
    #       ( $offset !~ /^[123]$/ );
    #   my ($start, $end) = ($offset, $self->length);
    #   ($seq) = $self->subseq($start, $end);
    #} else {
    #   ($seq) = $self->seq();
    #}
    #
    ### ignore frame if an ORF is supposed to be found
    #if ($orf) {
    #    $seq = $self->_find_orf($seq,$codonTable,$start_codon);
    #} else {
    ### use frame, error if frame is not 0, 1 or 2
    #    $self->throw("Valid values for frame are 0, 1, or 2, not $frame.")
    #       unless ($frame == 0 or $frame == 1 or $frame == 2);
    #    $seq = substr($seq,$frame);
    #}
    #
    ### Translate it
    #my $output = $codonTable->translate($seq);
    ## Use user-input terminator/unknown
    #$output =~ s/\*/$terminator/g;
    #$output =~ s/X/$unknown/g;
    #
    ### Only if we are expecting to translate a complete coding region
    #if ($complete) {
    #    my $id = $self->display_id;
    #    # remove the terminator character
    #    if( substr($output,-1,1) eq $terminator ) {
    #        chop $output;
    #    } else {
    #        $throw && $self->throw("Seq [$id]: Not using a valid terminator codon!");
    #        $self->warn("Seq [$id]: Not using a valid terminator codon!");
    #    }
    #    # test if there are terminator characters inside the protein sequence!
    #    if ($output =~ /\*/) {
    #        $throw && $self->throw("Seq [$id]: Terminator codon inside CDS!");
    #        $self->warn("Seq [$id]: Terminator codon inside CDS!");
    #    }
    #    # if the initiator codon is not ATG, the amino acid needs to be changed to M
    #    if ( substr($output,0,1) ne 'M' ) {
    #        if ($codonTable->is_start_codon(substr($seq, 0, 3)) ) {
    #            $output = 'M'. substr($output,1);
    #        }  elsif ($throw) {
    #            $self->throw("Seq [$id]: Not using a valid initiator codon!");
    #        } else {
    #            $self->warn("Seq [$id]: Not using a valid initiator codon!");
    #        }
    #    }
    #}
    #
    #my $seqclass;
    #if ($self->can_call_new()) {
    #    $seqclass = ref($self);
    #} else {
    #    $seqclass = 'Bio::PrimarySeq';
    #    $self->_attempt_to_load_Seq();
    #}
    #my $out = $seqclass->new( '-seq' => $output,
    #            '-display_id'  => $self->display_id,
    #            '-accession_number' => $self->accession_number,
    #            # is there anything wrong with retaining the
    #            # description?
    #            '-desc' => $self->desc(),
    #            '-alphabet' => 'protein',
    #  '-verbose' => $self->verbose
    #              );
    #return $out;
}

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
