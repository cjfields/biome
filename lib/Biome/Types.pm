# This is a simple package with proposed subtypes; these may end up
# being split into various packages based on use, namespace, etc.

# TODO:
# I have tried MooseX::Types and I find it a bit slower that vanilla
# Moose::Util::TypeParameters, so may revert to the latter if speed becomes an
# issue

package Biome::Types;

use MooseX::Types -declare => [qw(
							   Sequence_Strand
							   Sequence_Strand_Int
							   Sequence_Strand_Symbol
							   Sequence_Alphabet
                               
                               Segment_Pos_Symbol
                               Segment_Pos_Type
                               Segment_Symbol
                               Segment_Type
                               Split_Segment_Type
                               
                               SplitLocationType
                               FuzzyPosition
                               
                               PositionType
                               
                               CoordinatePolicy
                               SimpleLocationType
                               StartPosition
                               EndPosition
                               SplitType
                               Location
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

my %VALID_SEGMENT_SYMBOL = (
    '.'          => 'WITHIN',
    '..'         => 'EXACT',
    '^'          => 'IN-BETWEEN',
);

my %VALID_SEGMENT_POS_SYMBOL = (
    '..'         => 'EXACT',
    '<'          => 'BEFORE',
    '>'          => 'AFTER',
    '.'          => 'WITHIN',
    '?'          => 'UNCERTAIN'
);

my %SYMBOL_TYPE = (
    'EXACT'     => '..',
    'BEFORE'    => '<',
    'AFTER'     => '>',
    'WITHIN'    => '.',
    'IN-BETWEEN'   => '^',
    'UNCERTAIN' => '?'
);

my %TYPE_SYMBOL = map {$SYMBOL_TYPE{$_} => $_} keys %SYMBOL_TYPE;

# WITHIN here is very rare but does occur, ex (122.144)
my %VALID_SEGMENT_TYPE = map {$_ => 1}
    qw(EXACT IN-BETWEEN WITHIN);

my %VALID_SEGMENT_POS_TYPE = map {$_ => 1}
    qw(EXACT BEFORE AFTER WITHIN UNCERTAIN);

# TODO: some of these could probably be redef. as enums, but it makes coercion
# easier, needs checking

subtype Segment_Symbol,
    as Str,
    where {exists $VALID_SEGMENT_SYMBOL{$_}},
    message {"Unknown Segment symbol $_"};

subtype Segment_Type,
    as Str,
    where {exists $VALID_SEGMENT_TYPE{$_}},
    message {"Unknown Segment type $_"};

subtype Segment_Pos_Symbol,
    as Str,
    where {exists $VALID_SEGMENT_POS_SYMBOL{$_}},
    message {"Unknown Segment positional symbol $_"};
    
subtype Segment_Pos_Type,
    as Str,
    where {exists $VALID_SEGMENT_POS_TYPE{$_}},
    message {"Unknown Segment positional type $_"};

coerce Segment_Pos_Type,
    from Segment_Pos_Symbol,
    via {$TYPE_SYMBOL{$_}};
    
coerce Segment_Pos_Symbol,
    from Segment_Pos_Type,
    via {$SYMBOL_TYPE{$_}};

coerce Segment_Symbol,
    from Segment_Type,
    via {$SYMBOL_TYPE{$_}};

coerce Segment_Type,
    from Segment_Symbol,
    via {$TYPE_SYMBOL{$_}};
    
my %VALID_SPLIT_TYPE = map {$_ => 1}
    qw(JOIN ORDER BOND);
    
subtype Split_Segment_Type,
    as Str,
    where {exists $VALID_SPLIT_TYPE{uc $_}},
    message {"Unknown Split Location type $_"};

subtype FuzzyPosition,
    as Str,
    where { /^[\?<]?\d+(?:[\.\^]\d+)?/ },
    message {"Not a fuzzy position type : $_"};
    
subtype SplitLocationType,
    as Str,
    where {exists $VALID_SPLIT_TYPE{$_}},
    message {"Unknown Split Location type $_"};

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

