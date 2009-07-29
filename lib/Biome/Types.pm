# This is a simple package with proposed subtypes; these may end up
# being split into various packages based on use, namespace, etc.

# TODO:
# I have tried MooseX::Types and I find it a bit slower that vanilla
# Moose::Util::TypeParameters, so may revert to the latter if speed becomes an
# issue

package Bio::Moose::Types;

use MooseX::Types -declare => [qw(
							   SequenceStrand
							   SequenceStrandInt
							   SequenceStrandChar
							   SequenceAlphabet
							   )];

use MooseX::Types::Moose qw(Int Str);

subtype SequenceStrandInt,
	as Int,
	where {$_ >= -1 && $_ <= 1},
	message { "Strand must be -1 <= strand <= 1, not $_"};

subtype SequenceStrandChar,
	as Str,
	where { /^(?:[\+\-\.])$/},
	message { "Strand must be -1 <= strand <= 1, not $_"};

# allow either Int or Str-based
subtype SequenceStrand,
	as SequenceStrandInt|SequenceStrandChar;

subtype SequenceAlphabet,
	as Str,
	where { /^(?:dna|rna|protein)$/xism }, # do we want more?
	message { "Strand must be 'dna', 'rna', or 'protein'"};
	
no MooseX::Types;
no MooseX::Types::Moose;

1;

__END__

