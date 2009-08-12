# $Id: CodonTable.pm 15549 2009-02-21 00:48:48Z maj $
#
# bioperl module for Bio::Tools::CodonTable
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Heikki Lehvaslaiho <heikki-at-bioperl-dot-org>
#
# Copyright Heikki Lehvaslaiho
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Tools::CodonTable - Codon table object

=head1 SYNOPSIS

  # This is a read-only class for all known codon tables.  The IDs are
  # the ones used by nucleotide sequence databases.  All common IUPAC
  # ambiguity codes for DNA, RNA and amino acids are recognized.

  use Bio::Tools::CodonTable;

  # defaults to ID 1 "Standard"
  $myCodonTable   = Bio::Tools::CodonTable->new();
  $myCodonTable2  = Bio::Tools::CodonTable->new( -id => 3 );

  # change codon table
  $myCodonTable->id(5);

  # examine codon table
  print  join (' ', "The name of the codon table no.", $myCodonTable->id(4),
           "is:", $myCodonTable->name(), "\n");

  # print possible codon tables
  $tables = Bio::Tools::CodonTable->tables;
  while ( ($id,$name) = each %{$tables} ) {
    print "$id = $name\n";
  }

  # translate a codon
  $aa = $myCodonTable->translate('ACU');
  $aa = $myCodonTable->translate('act');
  $aa = $myCodonTable->translate('ytr');

  # reverse translate an amino acid
  @codons = $myCodonTable->revtranslate('A');
  @codons = $myCodonTable->revtranslate('Ser');
  @codons = $myCodonTable->revtranslate('Glx');
  @codons = $myCodonTable->revtranslate('cYS', 'rna');

  # reverse translate an entire amino acid sequence into a IUPAC
  # nucleotide string

  my $seqobj    = Bio::PrimarySeq->new(-seq => 'FHGERHEL');
  my $iupac_str = $myCodonTable->reverse_translate_all($seqobj);

  # boolean tests
  print "Is a start\n"       if $myCodonTable->is_start_codon('ATG');
  print "Is a terminator\n" if $myCodonTable->is_ter_codon('tar');
  print "Is a unknown\n"     if $myCodonTable->is_unknown_codon('JTG');

=head1 DESCRIPTION

Codon tables are also called translation tables or genetic codes
since that is what they represent. A bit more complete picture
of the full complexity of codon usage in various taxonomic groups
is presented at the NCBI Genetic Codes Home page.

CodonTable is a BioPerl class that knows all current translation
tables that are used by primary nucleotide sequence databases
(GenBank, EMBL and DDBJ). It provides methods to output information
about tables and relationships between codons and amino acids.

This class and its methods recognized all common IUPAC ambiguity codes
for DNA, RNA and animo acids. The translation method follows the
conventions in EMBL and TREMBL databases.

It is a nuisance to separate RNA and cDNA representations of nucleic
acid transcripts. The CodonTable object accepts codons of both type as
input and allows the user to set the mode for output when reverse
translating. Its default for output is DNA.

Note: 

This class deals primarily with individual codons and amino
acids. However in the interest of speed you can L<translate>
longer sequence, too. The full complexity of protein translation
is tackled by L<Bio::PrimarySeqI::translate>.


The amino acid codes are IUPAC recommendations for common amino acids:

          A           Ala            Alanine
          R           Arg            Arginine
          N           Asn            Asparagine
          D           Asp            Aspartic acid
          C           Cys            Cysteine
          Q           Gln            Glutamine
          E           Glu            Glutamic acid
          G           Gly            Glycine
          H           His            Histidine
          I           Ile            Isoleucine
          L           Leu            Leucine
          K           Lys            Lysine
          M           Met            Methionine
          F           Phe            Phenylalanine
          P           Pro            Proline
          O           Pyl            Pyrrolysine (22nd amino acid)
          U           Sec            Selenocysteine (21st amino acid)
          S           Ser            Serine
          T           Thr            Threonine
          W           Trp            Tryptophan
          Y           Tyr            Tyrosine
          V           Val            Valine
          B           Asx            Aspartic acid or Asparagine
          Z           Glx            Glutamine or Glutamic acid
          J           Xle            Isoleucine or Valine (mass spec ambiguity)
          X           Xaa            Any or unknown amino acid


It is worth noting that, "Bacterial" codon table no. 11 produces an
polypeptide that is, confusingly, identical to the standard one. The
only differences are in available initiator codons.


NCBI Genetic Codes home page:
     http://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi?mode=c

EBI Translation Table Viewer:
     http://www.ebi.ac.uk/cgi-bin/mutations/trtables.cgi

Amended ASN.1 version with ids 16 and 21 is at:
     ftp://ftp.ebi.ac.uk/pub/databases/geneticcode/

Thanks to Matteo diTomasso for the original Perl implementation
of these tables.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing lists  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and 
reponsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.  Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Heikki Lehvaslaiho

Email:  heikki-at-bioperl-dot-org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Biome::Tools::CodonTable;

use Biome;
use MooseX::ClassAttribute;
use MooseX::AttributeHelpers;

use Biome::Tools::IUPAC;

# first set internal values for all translation tables

class_has codons => (
	metaclass   => 'Collection::ImmutableHash',
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
    provides    => {
        'get'   => 'get_codon'
        },
    builder     => '_build_codons',
);

class_has reverse_codons  => (
	metaclass   => 'Collection::ImmutableHash',
	isa 		=> 'HashRef',
	is      	=> 'ro',
    init_arg    => undef,
    lazy        => 1,
    default     => sub {
        my $codons = __PACKAGE__->codons;
        my %trcols = map { $codons->{$_} => $_ }
                     sort { $codons->{$a} <=> $codons->{$b} } keys %$codons;
        \%trcols;
                    },
);

class_has codon_size => (
    isa         => 'Int',
    is          => 'ro',
    init_arg    => undef,  
    default     => 3
    );

class_has genetic_code => (
	metaclass   => 'Collection::Hash',
	isa 		=> 'HashRef',
	is      	=> 'rw',
    init_arg    => undef,
    lazy        => 1,
    provides    => {
        'set'   => '_add_table',
        'count' => '_code_elements'
        },
    default => sub {
    {
    1  => { name  => 'Standard',
            code  => 'FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '---M---------------M---------------M----------------------------'},
    2  => { name  => 'Vertebrate Mitochondrial',
            code  => 'FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSS**VVVVAAAADDEEGGGG',
            start => '--------------------------------MMMM---------------M------------'},
    3  => { name  => 'Yeast Mitochondrial',
            code  => 'FFLLSSSSYY**CCWWTTTTPPPPHHQQRRRRIIMMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '----------------------------------MM----------------------------'},
    4  => { name  => 'Mold, Protozoan, and CoelenterateMitochondrial and Mycoplasma/Spiroplasma',
            code  => 'FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '--MM---------------M------------MMMM---------------M------------'},
    5  => { name  => 'Invertebrate Mitochondrial',
            code  => 'FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSSSSVVVVAAAADDEEGGGG',
            start => '---M----------------------------MMMM---------------M------------'},
    6  => { name  => 'Ciliate, Dasycladacean and Hexamita Nuclear',
            code  => 'FFLLSSSSYYQQCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'}, 
    9  => { name  => 'Echinoderm Mitochondrial',
            code  => 'FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNNKSSSSVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    10 => { name  => 'Euplotid Nuclear',
            code  => 'FFLLSSSSYY**CCCWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    11 => { name  => 'Bacterial',
            code  => 'FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '---M---------------M------------MMMM---------------M------------'},
    12 => { name  => 'Alternative Yeast Nuclear',
            code  => 'FFLLSSSSYY**CC*WLLLSPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '-------------------M---------------M----------------------------'},
    13 => { name  => 'Ascidian Mitochondrial',
            code  => 'FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSSGGVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    14 => { name  => 'Flatworm Mitochondrial',
            code  => 'FFLLSSSSYYY*CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNNKSSSSVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    15 => { name  => 'Blepharisma Nuclear',
            code  => 'FFLLSSSSYY*QCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    16 => { name  => 'Chlorophycean Mitochondrial',
            code  => 'FFLLSSSSYY*LCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    21 => { name  => 'Trematode Mitochondrial',
            code  => 'FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNNKSSSSVVVVAAAADDEEGGGG',
            start => '-----------------------------------M---------------M------------'},
    22 => { name  => 'Scenedesmus obliquus Mitochondrial',
            code  => 'FFLLSS*SYY*LCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '-----------------------------------M----------------------------'},
    23 => { name  => 'Thraustochytrium Mitochondrial',
            code  => 'FF*LSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG',
            start => '--------------------------------M--M---------------M------------'},
    }
    }  
    );

class_has iupac_dna => (
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
    default     => sub {Biome::Tools::IUPAC->iupac_dna},
);

has gap => (
    isa => 'Str',
    is  => 'rw',
    default => '-'
    );

has terminator => (
    isa => 'Str',
    is  => 'rw',
    default => '*'
    );

has id => (
    isa  => 'Int',
    is   => 'rw',
    default => 1
);

#BEGIN { 
    #%IUPAC_DNA = Bio::Tools::IUPAC->iupac_iub();    
    #%IUPAC_AA = Bio::Tools::IUPAC->iupac_iup();
    #%THREELETTERSYMBOLS = Bio::SeqUtils->valid_aa(2);
    #$VALID_PROTEIN = '['.join('',Bio::SeqUtils->valid_aa(0)).']';
#}

=head2 name

 Title   : name
 Usage   : $obj->name()
 Function: returns the descriptive name of the translation table
 Example :
 Returns : A string
 Args    : None

=cut

sub name {
    my ($self) = @_;
    my ($id) = $self->id;
    return ${$self->genetic_code()}{$id}{name};
}

=head2 tables

 Title   : tables
 Usage   : $obj->tables()  or  Bio::Tools::CodonTable->tables()
 Function: returns a hash reference where each key is a valid codon
           table id() number, and each value is the corresponding
           codon table name() string
 Example :
 Returns : A hashref
 Args    : None

=cut

sub tables {
    my $self = shift;
    my $codes = $self->genetic_code;
    my %data = map {$_ => $codes->{$_}{name} } keys %$codes;
    \%data;
}

=head2 translate

 Title   : translate
 Usage   : $obj->translate('YTR')
 Function: Returns a string of one letter amino acid codes from 
           nucleotide sequence input. The imput can be of any length.

           Returns 'X' for unknown codons and codons that code for
           more than one amino acid. Returns an empty string if input
           is not three characters long. Exceptions for these are:

             - IUPAC amino acid code B for Aspartic Acid and
               Asparagine, is used.
             - IUPAC amino acid code Z for Glutamic Acid, Glutamine is
               used.
             - if the codon is two nucleotides long and if by adding
               an a third character 'N', it codes for a single amino
               acid (with exceptions above), return that, otherwise
               return empty string.

           Returns empty string for other input strings that are not
           three characters long.

 Example :
 Returns : a string of one letter ambiguous IUPAC amino acid codes
 Args    : ambiguous IUPAC nucleotide string

=cut

sub translate {
    my ($self, $seq) = @_;
    $self->throw("Calling translate without a seq argument!") unless defined $seq;
    return '' unless $seq;

    my $table = ${ $self->genetic_code }{$self->id}{code};

    my ($codons, $codonsize, $gap) = ($self->codons, $self->codon_size, $self->gap);
    my $codongap = $gap x $codonsize;

    my ($partial) = 0;
    $partial = 2 if length($seq) % $codonsize == 2;
    $seq = lc $seq;
    $seq =~ tr/u/t/;
    my $protein = "";
    
    if ($seq =~ /[^actg]/ ) { #ambiguous chars
        for (my $i = 0; $i < (length($seq) - ($codonsize-1)); $i+= $codonsize) {
            my $triplet = substr($seq, $i, $codonsize);
            if( $triplet eq $codongap ) {
                $protein .= $gap;
            } elsif (exists $codons->{$triplet}) {
                $protein .= substr($table, 
                       $codons->{$triplet},1);
            } else {
                $protein .= $self->_translate_ambiguous_codon($triplet, $partial, $table, $codons);
            }
        }
    } else { # simple, strict translation
        for (my $i = 0; $i < (length($seq) - ($codonsize -1)); $i+=$codonsize) {
            my $triplet = substr($seq, $i, $codonsize); 
            if( $triplet eq $codongap) {
                $protein .= $gap;
            } if (exists $codons->{$triplet}) {
                $protein .= substr($table, $codons->{$triplet}, 1);
            } else {
                $protein .= 'X';
            }
        }
    }
    if ($partial == 2) { # 2 overhanging nucleotides
        my $triplet = substr($seq, ($partial -4)). "n";
        if( $triplet eq $codongap ) {
            $protein .= $gap;
        } elsif (exists $codons->{$triplet}) {
            my $aa = substr($table, $codons->{$triplet},1);       
            $protein .= $aa;
        } else {
            $protein .= $self->_translate_ambiguous_codon($triplet, $partial, $table, $codons);
        }
    }
    return $protein;
}

sub _translate_ambiguous_codon {
    my ($self, $triplet, $partial, $table, $codons) = @_;
    $partial ||= 0;
    my $aa;
    my @codons = _unambiquous_codons($triplet);
    my %aas = ();
    for my $codon (@codons) {
        $aas{substr($table,$codons->{$codon},1)} = 1;
    }
    my $count = scalar keys %aas;
    if ( $count == 1 ) {
        $aa = (keys %aas)[0];
    } elsif ( $count == 2 ) {
        if ($aas{'D'} and $aas{'N'}) {
            $aa = 'B';
        }
        elsif ($aas{'E'} and $aas{'Q'}) {
            $aa = 'Z';
        } else {
            $partial ? ($aa = '') : ($aa = 'X');
        }
    } else {
        $partial ? ($aa = '') :  ($aa = 'X');
    }
    return $aa;
}

=head2 translate_strict

 Title   : translate_strict
 Usage   : $obj->translate_strict('ACT')
 Function: returns one letter amino acid code for a codon input

           Fast and simple translation. User is responsible to resolve
           ambiguous nucleotide codes before calling this
           method. Returns 'X' for unknown codons and an empty string
           for input strings that are not three characters long.

           It is not recommended to use this method in a production
           environment. Use method translate, instead.

 Example :
 Returns : A string
 Args    : a codon = a three nucleotide character string

=cut

sub translate_strict{
    my ($self, $value) = @_;
    my $code = ${$self->genetic_code}{$self->id};
 
    $value  = lc $value;
    $value  =~ tr/u/t/;
 
    if (length $value != 3 ) {
        return '';
    } else {
        my $v = $self->get_codon($value);
        defined $v ? return substr($code->{code},$v,1)
            : return 'X';
    }
}

#=head2 revtranslate
#
# Title   : revtranslate
# Usage   : $obj->revtranslate('G')
# Function: returns codons for an amino acid
#
#           Returns an empty string for unknown amino acid
#           codes. Ambiquous IUPAC codes Asx,B, (Asp,D; Asn,N) and
#           Glx,Z (Glu,E; Gln,Q) are resolved. Both single and three
#           letter amino acid codes are accepted. '*' and 'Ter' are
#           used for terminator.
#
#           By default, the output codons are shown in DNA.  If the
#           output is needed in RNA (tr/t/u/), add a second argument
#           'RNA'.
#
# Example : $obj->revtranslate('Gly', 'RNA')
# Returns : An array of three lower case letter strings i.e. codons
# Args    : amino acid, 'RNA'
#
#=cut
#
#sub revtranslate {
#    my ($self, $value, $coding) = @_;
#    my ($id) = $self->{'id'};
#    my (@aas,  $p);
#    my (@codons) = ();
#
#    if (length($value) == 3 ) {
#        $value = lc $value;
#        $value = ucfirst $value;
#        $value = $THREELETTERSYMBOLS{$value};
#    }
#    if ( defined $value and $value =~ /$VALID_PROTEIN/ 
#          and length($value) == 1 ) {
#        $value = uc $value;
#        @aas = @{$IUPAC_AA{$value}};    
#        foreach my $aa (@aas) {
#            #print $aa, " -2\n";
#            $aa = '\*' if $aa eq '*';
#          while ($TABLES[$id-1] =~ m/$aa/g) {
#              $p = pos $TABLES[$id-1];
#              push (@codons, $TRCOL->{--$p});
#          }
#        }
#    }
#
#   if ($coding and uc ($coding) eq 'RNA') {
#       for my $i (0..$#codons)  {
#          $codons[$i] =~ tr/t/u/;
#       }
#   }
#    
#   return @codons;
#}
#
#=head2 reverse_translate_all
#
# Title   : reverse_translate_all
# Usage   : my $iup_str = $cttable->reverse_translate_all($seq_object)
#           my $iup_str = $cttable->reverse_translate_all($seq_object,
#                                                         $cutable,
#                                                         15);
# Function: reverse translates a protein sequence into IUPAC nucleotide
#           sequence. An 'X' in the protein sequence is converted to 'NNN'
#           in the nucleotide sequence.
# Returns : a string
# Args    : a Bio::PrimarySeqI compatible object (mandatory)
#           a Bio::CodonUsage::Table object and a threshold if only
#             codons with a relative frequency above the threshold are
#             to be considered.
#=cut
#
#sub reverse_translate_all {
#    
#    my ($self, $obj, $cut, $threshold) = @_;
#
#    ## check args are OK
#
#    if (!$obj || !$obj->isa('Bio::PrimarySeqI')){
#        $self->throw(" I need a Bio::PrimarySeqI object, not a [".
#                        ref($obj) . "]");
#        }
#    if($obj->alphabet ne 'protein') {
#        $self->throw("Cannot reverse translate, need an amino acid sequence .".
#                     "This sequence is of type [" . $obj->alphabet ."]");
#        }
#    my @data;
#    my @seq = split '', $obj->seq;
#
#    ## if we're not supplying a codon usage table...
#    if( !$cut && !$threshold) {
#        ## get lists of possible codons for each aa. 
#        for my $aa (@seq) {
#            if ($aa =~ /x/i) {
#                push @data, (['NNN']);
#            }else {
#                my @cods = $self->revtranslate($aa);
#                push @data, \@cods;
#            }
#        }
#    }else{
#    #else we are supplying a codon usage table, we just want common codons
#    #check args first. 
#        if(!$cut->isa('Bio::CodonUsage::Table'))    {
#            $self->throw("I need a Bio::CodonUsage::Table object, not a [".
#                     ref($cut). "].");
#            }
#        my $cod_ref = $cut->probable_codons($threshold);
#        for my $aa (@seq) {
#            if ($aa =~ /x/i) {
#                push @data, (['NNN']);
#                next;
#                }
#            push @data, $cod_ref->{$aa};
#        }
#    }
#
#    return $self->_make_iupac_string(\@data);
#
#}
#
#=head2 reverse_translate_best
#
# Title   : reverse_translate_best
# Usage   : my $str = $cttable->reverse_translate_best($seq_object,$cutable);
# Function: Reverse translates a protein sequence into plain nucleotide
#           sequence (GATC), uses the most common codon for each amino acid
# Returns : A string
# Args    : A Bio::PrimarySeqI compatible object and a Bio::CodonUsage::Table object
#
#=cut
#
#sub reverse_translate_best {
#
#    my ($self, $obj, $cut) = @_;
#
#    if (!$obj || !$obj->isa('Bio::PrimarySeqI')){
#        $self->throw(" I need a Bio::PrimarySeqI object, not a [".
#                         ref($obj) . "]");
#    }
#    if ($obj->alphabet ne 'protein')    {
#        $self->throw("Cannot reverse translate, need an amino acid sequence .".
#                         "This sequence is of type [" . $obj->alphabet ."]");
#    }
#    if ( !$cut | !$cut->isa('Bio::CodonUsage::Table'))  {
#        $self->throw("I need a Bio::CodonUsage::Table object, not a [".
#                         ref($cut). "].");
#    }
#
#    my $str = '';
#    my @seq = split '', $obj->seq;
#
#    my $cod_ref = $cut->most_common_codons();
#
#    for my $aa ( @seq ) {
#        if ($aa =~ /x/i) {
#            $str .= 'NNN';
#            next;
#        }
#        if ( defined $cod_ref->{$aa} ) {
#            $str .= $cod_ref->{$aa};
#        } else {
#            $self->throw("Input sequence contains invalid character: $aa");         
#        }
#    }
#   $str;
#}
#
=head2 is_start_codon

 Title   : is_start_codon
 Usage   : $obj->is_start_codon('ATG')
 Function: returns true (1) for all codons that can be used as a
           translation start, false (0) for others.
 Example : $myCodonTable->is_start_codon('ATG')
 Returns : boolean
 Args    : codon

=cut

sub is_start_codon{
    my ($self, $value) = @_;
    
    my $code = ${$self->genetic_code}{$self->id};
    $value  = lc $value;
    $value  =~ tr/u/t/;
 
    if (length $value != 3  )  {
        return 0;
    }
    else {
        my $result = 1;
        my @ms = map { substr($code->{start},$self->get_codon($_),1) } _unambiquous_codons($value);
        foreach my $c (@ms) {
            $result = 0 if $c ne 'M';
        }
        return $result;
    }
}

=head2 is_ter_codon

 Title   : is_ter_codon
 Usage   : $obj->is_ter_codon('GAA')
 Function: returns true (1) for all codons that can be used as a
           translation tarminator, false (0) for others.
 Example : $myCodonTable->is_ter_codon('ATG')
 Returns : boolean
 Args    : codon

=cut

sub is_ter_codon{
    my ($self, $value) = @_;
 
    my $code = ${$self->genetic_code}{$self->id};
    $value  = lc $value;
    $value  =~ tr/u/t/;
 
    if (length $value != 3  )  {
        return 0;
    }
    else {
        my $result = 1;
        my @ms = map { substr($code->{code},$self->get_codon($_),1) } _unambiquous_codons($value);
        foreach my $c (@ms) {
            $result = 0 if $c ne $self->terminator;
        }
        return $result;
    }
}

=head2 is_unknown_codon

 Title   : is_unknown_codon
 Usage   : $obj->is_unknown_codon('GAJ')
 Function: returns false (0) for all codons that are valid,
        true (1) for others.
 Example : $myCodonTable->is_unknown_codon('NTG')
 Returns : boolean
 Args    : codon


=cut

sub is_unknown_codon{
    my ($self, $value) = @_;
    my $code = ${$self->genetic_code}{$self->id};
 
    $value  = lc $value;
    $value  =~ tr/u/t/;
 
    if (length $value != 3  )  {
        return 1;
    }
    else {
        my $result = 0;
        my @cs = map { substr($code->{code},$self->get_codon($_),1) } _unambiquous_codons($value);
        $result = 1 if scalar @cs == 0;
        return $result;
    }
}

=head2 _unambiquous_codons

 Title   : _unambiquous_codons
 Usage   : @codons = _unambiquous_codons('ACN')
 Function:
 Example :
 Returns : array of strings (one letter unambiguous amino acid codes)
 Args    : a codon = a three IUPAC nucleotide character string

=cut

sub _unambiquous_codons{
    my ($value) = @_;
    my @nts = ();
    my %iupac = %{__PACKAGE__->iupac_dna};
    my %mapping = map {$_ => [split('',$iupac{$_})] } keys %iupac;
    my @codons = ();
    my ($i, $j, $k);
    @nts = map { $mapping{uc $_} }  split(//, $value);
    for my $i (@{$nts[0]}) {
        for my $j (@{$nts[1]}) {
            for my $k (@{$nts[2]}) {
                push @codons, lc "$i$j$k";
            }
        }
    }
    return @codons;
}

=head2 add_table

 Title   : add_table
 Usage   : $newid = $ct->add_table($name, $table, $starts)
 Function: Add a custom Codon Table into the object.
           Know what you are doing, only the length of
           the argument strings is checked!
 Returns : the id of the new codon table
 Args    : name, a string, optional (can be empty)
           table, a string of 64 characters
           startcodons, a string of 64 characters, defaults to standard

=cut

sub add_table {
    my ($self, @args) = @_;
    my ($name, $table, $starts) = $self->rearrange([qw(NAME TABLE STARTS)], @args);
    my $data = $self->genetic_code;
    my $top = (sort {$a <=> $b} keys %$data)[-1];
    $top++;
    $name ||= 'Custom'. $self->_code_elements + 1;
    $starts ||= $data->{1}->{start}; 
    $self->throw('Suspect input!')
        unless length($table) == 64 and length($starts) == 64;
    $self->_add_table($top,
                      {name  => $name,
                       code  => $table,
                       start => $starts}
                       );
    return $top;
}

#sub _make_iupac_string {
#
#    my ($self, $cod_ref) = @_;
#    if(ref($cod_ref) ne 'ARRAY') {
#        $self->throw(" I need a reference to a list of references to codons, ".
#                     " not a [". ref($cod_ref) . "].");
#        }
#    my %iupac_hash   = Bio::Tools::IUPAC->iupac_rev_iub();
#    my $iupac_string = ''; ## the string to be returned
#    for my $aa (@$cod_ref) {
#
#        ## scan through codon positions, record the differing values,   
#        # then look up in the iub hash
#        for my $index(0..2) {
#            my %h;
#            map { my $k = substr($_,$index,1);
#                $h{$k}  = undef;} @$aa;
#            my $lookup_key = join '', sort{$a cmp $b}keys %h;
#
#            ## extend string 
#            $iupac_string .= $iupac_hash{uc$lookup_key};
#        }
#    }
#    return $iupac_string;
#
#}

sub _build_codons {
    my $self = shift;
    my @nucs = qw(t c a g);
    my $x = 0;
    my $codons;
    my $trcol;
    for my $i (@nucs) {
        for my $j (@nucs) {
            for my $k (@nucs) {
                $codons->{"$i$j$k"} = $x++;
            }
        }
    }
    return $codons;
}

no Biome;
no MooseX::ClassAttribute;
no MooseX::AttributeHelpers;

__PACKAGE__->meta->make_immutable;

1;
