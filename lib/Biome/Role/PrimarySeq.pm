package Biome::Role::PrimarySeq;

use Biome::Role;
use Biome::Type::Sequence qw(Maybe_Sequence_Alphabet);

use Biome::Tools::CodonTable;

# this should always return a raw sequence
has seq => (
    is    => 'rw',
    isa   => 'Str',
);

# make a subtype or coerce input into a subtype?
has alphabet => (
   is    => 'rw',
   isa   => Maybe_Sequence_Alphabet,
);

has is_circular => (
   is    => 'rw',
   isa   => 'Bool'
);

# this is now localized to the instance (no longer global) due to issues noted
# with BioPerl. Will shift this to a builder for symbol validation (I think we
# should allow a narrow set of symbols for now, maybe enum, i.e. GAP, RESIDUE,
# FRAMESHIFT)


# Should we role Range/Location into this as well? Every sequence has a
# start/end/strand, in this case start = 1, end = length -1, strand maybe based
# on alphabet or 0 This gets tricky with mRNA (split locations).

has symbols => (
    is   => 'rw',
    isa  => 'HashRef[Str]',
    default => sub { {
        'RESIDUE' => 'A-Za-z\*\?=',
        'GAP'     => '-\.~'
    } }
    );

# returns raw subsequence; trunc() calls this for objects
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
    
    if( ref($start) && $start->does('Biome::Role::Location::Range') ) {
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
        my $rawseq = $self->seq;
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
    
    my $out = $self->clone(-seq => $revseq);
    return $out;
}

sub has_gaps {
    my $self = shift;
    my @gap_sym = split('',${$self->symbols}{GAP});
    my $rawseq = $self->seq;
    for my $g (@gap_sym) {
        return 1 if (index($rawseq, $g) >= 0);
    }
    return 0;
}

sub trunc {
    my ($self) = shift;
    return $self->clone(-seq => $self->subseq(@_));
}

sub translate {
    my ($self,@args) = @_;
    my ($terminator, $unknown, $frame, $codonTableId, $complete, $throw,
         $codonTable, $orf, $start_codon, $offset) =
            $self->rearrange([qw(TERMINATOR
                               UNKNOWN
                               FRAME
                               CODONTABLE_ID
                               COMPLETE
                               THROW
                               CODONTABLE
                               ORF
                               START
                               OFFSET)], @args);
    # Initialize termination codon, unknown codon, codon table id, frame
    $terminator //= '*';
    $unknown //= "X";
    $frame //= 0;
    $codonTableId //= 1;
        
    # Get a CodonTable, error if custom CodonTable is invalid
    if ($codonTable) {
         $self->throw("Need a Biome::Tools::CodonTable object, not ". $codonTable)
            unless $codonTable->isa('Biome::Tools::CodonTable');
    } else {
         $codonTable = Biome::Tools::CodonTable->new( -id => $codonTableId);
    }
    
    # Error if alphabet is "protein"
    $self->throw("Can't translate an amino acid sequence.") if
        ($self->alphabet eq 'protein');

    ## Error if -start parameter isn't a valid codon
    if ($start_codon) {
        $self->throw("Invalid start codon: $start_codon.") if
           ( $start_codon !~ /^[A-Z]{3}$/i );
    }
     
    my $seq;
     
    if ($offset) {
        $self->throw("Offset must be 1, 2, or 3.") if
            ( $offset !~ /^[123]$/ );
        my ($start, $end) = ($offset, $self->length);
        ($seq) = $self->subseq($start, $end);
    } else {
        ($seq) = $self->seq();
    }
    
    # ignore frame if an ORF is supposed to be found
    if ($orf) {
        $seq = $self->_find_orf($seq,$codonTable,$start_codon);
    } else {
        # use frame, error if frame is not 0, 1 or 2
        $self->throw("Valid values for frame are 0, 1, or 2, not $frame.")
           unless ($frame == 0 or $frame == 1 or $frame == 2);
        $seq = substr($seq,$frame);
    }
    
    # TODO:
    # Preferentially, CodonTable::translate should handle gaps but currently
    # doesn't; discussion on what to do here.  Gaps are removed for now.
    
    my $gs = ${$self->symbols}{GAP};
    $seq =~ s/[$gs]+//g;
    
    # Translate it
    my $output = $codonTable->translate($seq);
    # Use user-input terminator/unknown
    $output =~ s/\*/$terminator/g;
    $output =~ s/X/$unknown/g;

    # Only if we are expecting to translate a complete coding region
    if ($complete) {
        my $id = $self->display_id;
        # remove the terminator character
        if( substr($output,-1,1) eq $terminator ) {
            chop $output;
        } else {
            $throw && $self->throw("Seq [$id]: Not using a valid terminator codon!");
            $self->warn("Seq [$id]: Not using a valid terminator codon!");
        }
        # test if there are terminator characters inside the protein sequence!
        if ($output =~ /\*/) {
            $throw && $self->throw("Seq [$id]: Terminator codon inside CDS!");
            $self->warn("Seq [$id]: Terminator codon inside CDS!");
        }
        # if the initiator codon is not ATG, the amino acid needs to be changed to M
        if ( substr($output,0,1) ne 'M' ) {
            if ($codonTable->is_start_codon(substr($seq, 0, 3)) ) {
                $output = 'M'. substr($output,1);
            }  elsif ($throw) {
                $self->throw("Seq [$id]: Not using a valid initiator codon!");
            } else {
                $self->warn("Seq [$id]: Not using a valid initiator codon!");
            }
        }
    }

    return $self->clone(
                -seq     => $output,
                -alphabet   => 'protein',
                  );
}

# account for sequences with gaps
sub length {
    my $self = shift;
    my $len = $self->seq();
    if ($self->has_gaps) {
        my $gs = ${$self->symbols}{GAP};
        $len =~ s{[$gs]}{}g;
    }
    CORE::length($len);
}

=head2 _find_orf

 Title   : _find_orf
 Usage   :
 Function: Finds ORF starting at 1st initiation codon in nucleotide sequence.
           The ORF is not required to have a termination codon.
 Example :
 Returns : A nucleotide sequence or nothing, if no initiation codon is found.
 Args    : Nucleotide sequence, CodonTable object, alternative initiation
           codon (optional).

=cut

sub _find_orf {
	my ($self, $sequence, $codonTable, $start_codon) = @_;

	# find initiation codon and remove leading sequence
	while ($sequence) {
		my $codon = substr($sequence,0,3);
		if ($start_codon) {
			last if ( $codon =~ /$start_codon/i );
		} else {
			last if ($codonTable->is_start_codon($codon));
		}
		$sequence = substr($sequence,1);
	}
	return unless $sequence;

	# find termination codon and remove trailing sequence
	my $len = CORE::length($sequence);
	my $offset = 3;
	while ($offset < $len) {
		my $codon = substr($sequence,$offset,3);
		if ( $codonTable->is_ter_codon($codon) ){
			$sequence = substr($sequence, 0, $offset + 3);
			return $sequence;
		}
		$offset += 3;
	}
	$self->warn("No termination codon found, will translate - sequence:\n$sequence");
	$sequence;
}

sub validate_seq {
	my ($self,$seqstr) = @_;
	return 0 unless( defined $seqstr );
    my $MATCHPATTERN = join('',values %{$self->symbols});
	if((CORE::length($seqstr) > 0) && ($seqstr !~ /^([$MATCHPATTERN]+)$/)) {
	    $self->warn("seq doesn't validate, mismatch is ".
			join(",",($seqstr =~ /([^$MATCHPATTERN]+)/g)));
		return 0;
	}
	return 1;
}

no Biome::Role;

1;

__END__
