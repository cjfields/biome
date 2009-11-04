# This is a simple package with proposed subtypes; these may end up
# being split into various packages based on use, namespace, etc.

# TODO:
# I have tried MooseX::Types and I find it a bit slower that vanilla
# Moose::Util::TypeParameters, so may revert to the latter if speed becomes an
# issue

package Biome::Types;

use MooseX::Types -declare => [qw(
							   SequenceStrand
							   SequenceStrandInt
							   SequenceStrandSymbol
							   SequenceAlphabet
                               
                               LocationSymbol
                               LocationType
                               
                               PositionType
                               
                               CoordinatePolicy
                               SimpleLocationType
                               StartPosition
                               EndPosition
                               SplitType
                               Location
							   )];

use MooseX::Types::Moose qw(Int Str Object Any);

subtype SequenceStrand,
	as Int,
	where {$_ >= -1 && $_ <= 1},
	message { "Strand can be -1, 0, or 1, not $_"};

subtype SequenceStrandSymbol,
	as Str,
	where { /^(?:[\+\-\.])$/},
	message { "Strand symbol can be one of [-.+], not $_"};
    
    
my %STRAND_SYMBOL = (
    '+'     => 1,
    '.'     => 0,
    '-'     => -1
);

coerce SequenceStrand,
    from SequenceStrandSymbol,
    via {$STRAND_SYMBOL{$_}};

subtype SequenceAlphabet,
	as Str,
	where { /^(?:dna|rna|protein)$/xism }, # do we want more?
	message { "Strand must be 'dna', 'rna', or 'protein'"};

my %VALID_LOCATION_SYMBOL = (
    '..'         => 'EXACT',
    '<'          => 'BEFORE',
    '>'          => 'AFTER',
    '.'          => 'WITHIN',
    '^'          => 'BETWEEN',
    '?'          => 'UNCERTAIN'
);

my %VALID_LOCATION_TYPE = map {$_ => 1}
    qw(EXACT BEFORE AFTER WITHIN BETWEEN UNCERTAIN);

subtype LocationSymbol,
    as Str,
    where {exists $VALID_LOCATION_SYMBOL{$_}},
    message {"Unknown Location symbol $_"};
    
subtype LocationType,
    as Str,
    where {exists $VALID_LOCATION_TYPE{$_}},
    message {"Unknown Location type $_"};

coerce LocationType,
    from LocationSymbol,
    via {$VALID_LOCATION_SYMBOL{$_}};

enum PositionType, (qw(INCLUSIVE EXCLUSIVE AVERAGE));

subtype CoordinatePolicy,
	as Object,
	where { $_->meta->does_role('Biome::Role::Location::CoordinatePolicy')}, 
	message { "The object should consume Biome::Role::Location::CoordinatePolicy role"};

subtype Location,
	as Object,
	where { $_->meta->does_role('Biome::Role::Location')}, 
	message { "The object should consume Biome::Role::Location role"};

subtype StartPosition,  as Int;

subtype EndPosition,  as Int;

coerce StartPosition,  
	from Location, 
	 	via {
			my $pos = $_->min_start();
			$pos = $_->max_start() if !$pos;
			return $pos;
		};

coerce EndPosition,  
	from Location, 
	 	via {
			my $pos = $_->max_end();
			$pos = $_->min_end() if !$pos;
			return $pos;
		};

enum SimpleLocationType ,   ('EXACT',  'IN-BETWEEN',  '^',  '..');
	
subtype SplitType,  as Str; 
coerce SplitType, 
	from Str, 
		via { uc $_ };

no MooseX::Types;
no MooseX::Types::Moose;

1;

__END__

