package Biome::Tools::IUPAC;

use Biome;

# may need to think about whether we want this as a class attribute or
# as simple exportable data
use MooseX::ClassAttribute;

# ambiguity mappings
class_has iupac_dna => (
	traits      => ['Hash'],
	isa 		=> 'HashRef',
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
	handles     => {
		'count_iupac_dna'   => 'count',
		'get_iupac_dna'     => 'get'
		},
	default 	=> sub {
		{
			A => qw(A),
			C => qw(C),
			G => qw(G),
			T => qw(T),
			U => qw(U),
			M => qw(AC),
			R => qw(AG),
			W => qw(AT),
			S => qw(CG),
			Y => qw(CT),
			K => qw(GT),
			V => qw(ACG),
			H => qw(ACT),
			D => qw(AGT),
			B => qw(CGT),
			X => qw(ACGT),
			N => qw(ACGT)
		}
	}
	);

class_has iupac_rev_dna => (
	traits      => ['Hash'],
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
	handles    => {
		'count_iupac_rev_dna'		=> 'count',
		'get_iupac_rev_dna'    	    => 'get'
		},
	default     => sub {
		{
			A	=> 'A',
			T	=> 'T',
			C	=> 'C',
			G 	=> 'G',
			AC	=> 'M',
			AG	=> 'R',
			AT	=> 'W',
			CG	=> 'S',
			CT	=> 'Y',
			GT  => 'K',
			ACG	=> 'V',
			ACT	=> 'H',
			AGT	=> 'D',
			CGT	=> 'B',
			ACGT=> 'N',
			N	=> 'N'
		}
	}
);

class_has iupac_aa => (
	traits      => ['Hash'],
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
	handles    => {
		'count_iupac_aa'		=> 'count',
		'get_iupac_aa'   	    => 'get'
		},
	default 	=> sub {
		{
			A => qw(A),
			B => qw(DN),
			C => qw(C),
			D => qw(D),
			E => qw(E),
			F => qw(F),
			G => qw(G),
			H => qw(H),
			I => qw(I),
			J => qw(IL),
			K => qw(K),
			L => qw(L),
			M => qw(M),
			N => qw(N),
			O => qw(O),
			P => qw(P),
			Q => qw(Q),
			R => qw(R),
			S => qw(S),
			T => qw(T),
			U => qw(U),
			V => qw(V),
			W => qw(W),
			X => qw(X),
			Y => qw(Y),
			Z => qw(EQ),
			'*' => '*'
		}
	}
);

# convert from 3 to 1 letter code
# attribute name is considered unstable and kinda goofy
class_has map_aa_3_1 => (
	traits      => ['Hash'],
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
	default 	=> sub {
		{
		'Ala' => 'A', 'Asx' => 'B', 'Cys' => 'C', 'Asp' => 'D',
		'Glu' => 'E', 'Phe' => 'F', 'Gly' => 'G', 'His' => 'H',
		'Ile' => 'I', 'Lys' => 'K', 'Leu' => 'L', 'Met' => 'M',
		'Asn' => 'N', 'Pro' => 'P', 'Gln' => 'Q', 'Arg' => 'R',
		'Ser' => 'S', 'Thr' => 'T', 'Val' => 'V', 'Trp' => 'W',
		'Xaa' => 'X', 'Tyr' => 'Y', 'Glx' => 'Z', 'Ter' => '*',
		'Sec' => 'U', 'Pyl' => 'O', 'Xle' => 'J'			
		}
	}
);

# convert from 1 to 3 letter code
# attribute name is considered unstable and kinda goofy
class_has map_aa_1_3 => (
	traits      => ['Hash'],
	isa 		=> 'HashRef',
	is      	=> 'ro',
	init_arg	=> undef,
	lazy		=> 1,
	default 	=> sub {
		{
		'A' => 'Ala', 'B' => 'Asx', 'C' => 'Cys', 'D' => 'Asp',
		'E' => 'Glu', 'F' => 'Phe', 'G' => 'Gly', 'H' => 'His',
		'I' => 'Ile', 'K' => 'Lys', 'L' => 'Leu', 'M' => 'Met',
		'N' => 'Asn', 'P' => 'Pro', 'Q' => 'Gln', 'R' => 'Arg',
		'S' => 'Ser', 'T' => 'Thr', 'V' => 'Val', 'W' => 'Trp',
		'Y' => 'Tyr', 'Z' => 'Glx', 'X' => 'Xaa', '*' => 'Ter',
		'U' => 'Sec', 'O' => 'Pyl', 'J' => 'Xle'
		}
	}
);

no MooseX::ClassAttribute;
no Biome;

1;

__END__

# $Id: IUPAC.pm 15549 2009-02-21 00:48:48Z maj $
#
# BioPerl module for IUPAC
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Aaron Mackey <amackey@virginia.edu>
#
# Copyright Aaron Mackey
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Tools::IUPAC - Generates unique Seq objects from an ambiguous Seq object

=head1 SYNOPSIS

 use Bio::Seq;
 use Bio::Tools::IUPAC;

 my $ambiseq = Bio::Seq->new(-seq => 'ARTCGUTGR', -alphabet => 'dna');
 my $stream  = Bio::Tools::IUPAC->new(-seq => $ambiseq);

 while ($uniqueseq = $stream->next_seq()) {
     # process the unique Seq object.
 }

=head1 DESCRIPTION

IUPAC is a tool that produces a stream of unique, "strict"-satisfying Seq
objects from an ambiquous Seq object (containing non-standard characters given
the meaning shown below)

        Extended DNA / RNA alphabet :
        (includes symbols for nucleotide ambiguity)
        ------------------------------------------
        Symbol       Meaning      Nucleic Acid
        ------------------------------------------
         A            A           Adenine
         C            C           Cytosine
         G            G           Guanine
         T            T           Thymine
         U            U           Uracil
         M          A or C
         R          A or G
         W          A or T
         S          C or G
         Y          C or T
         K          G or T
         V        A or C or G
         H        A or C or T
         D        A or G or T
         B        C or G or T
         X      G or A or T or C
         N      G or A or T or C

        IUPAC-IUB SYMBOLS FOR NUCLEOTIDE NOMENCLATURE:
          Cornish-Bowden (1985) Nucl. Acids Res. 13: 3021-3030.

-----------------------------------

       Amino Acid alphabet:
        ------------------------------------------
        Symbol           Meaning
        ------------------------------------------
        A        Alanine
        B        Aspartic Acid, Asparagine
        C        Cystine
        D        Aspartic Acid
        E        Glutamic Acid
        F        Phenylalanine
        G        Glycine
        H        Histidine
        I        Isoleucine
        J        Isoleucine/Leucine
        K        Lysine
        L        Leucine
        M        Methionine
        N        Asparagine
        O        Pyrrolysine
        P        Proline
        Q        Glutamine
        R        Arginine
        S        Serine
        T        Threonine
        U        Selenocysteine
        V        Valine
        W        Tryptophan
        X        Unknown
        Y        Tyrosine
        Z        Glutamic Acid, Glutamine
        *        Terminator

        IUPAC-IUP AMINO ACID SYMBOLS:
          Biochem J. 1984 Apr 15; 219(2): 345-373
          Eur J Biochem. 1993 Apr 1; 213(1): 2

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

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

=head1 AUTHOR - Aaron Mackey

Email amackey-at-virginia.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


