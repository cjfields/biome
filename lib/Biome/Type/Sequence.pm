# This is a simple package with proposed subtypes; these may end up
# being split into various packages based on use, namespace, etc.

# TODO:
# I have tried MooseX::Types and I find it a bit slower that vanilla
# Moose::Util::TypeParameters, so may revert to the latter if speed becomes an
# issue

package Biome::Type::Sequence;

use MooseX::Types -declare => [qw(
							   Sequence_Strand
							   Sequence_Strand_Int
							   Sequence_Strand_Symbol
							   Sequence_Alphabet
							   )];

use MooseX::Types::Moose qw(Int Str Object CodeRef Any);

subtype Sequence_Strand,
	as Int,
	where {$_ >= -1 && $_ <= 1},
	message { "Strand can be -1, 0, or 1, not $_"};

subtype Sequence_Strand_Symbol,
	as Str,
	where { /^(?:[\+\-\.])$/},
	message { "Strand symbol can be one of [-.+], not $_"};
    
    
my %STRAND_SYMBOL = (
    '+'     => 1,
    '.'     => 0,
    '-'     => -1
);

coerce Sequence_Strand,
    from Sequence_Strand_Symbol,
    via {$STRAND_SYMBOL{$_}};

subtype Sequence_Alphabet,
	as Str,
	where { /^(?:dna|rna|protein)$/xism }, # do we want more?
	message { "Strand must be 'dna', 'rna', or 'protein'"};

no MooseX::Types;
no MooseX::Types::Moose;

1;

__END__

