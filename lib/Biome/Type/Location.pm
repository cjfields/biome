# This is a simple package with proposed subtypes; these may end up
# being split into various packages based on use, namespace, etc.

# TODO:
# I have tried MooseX::Types and I find it a bit slower that vanilla
# Moose::Util::TypeParameters, so may revert to the latter if speed becomes an
# issue

package Biome::Type::Location;

use MooseX::Types -declare => [qw(
                               Location_Pos_Symbol
                               Location_Pos_Type
                               Location_Symbol
                               Location_Type
                               Split_Location_Type
                               
                               Does_Range
                               ArrayRef_of_Ranges
							   )];

use MooseX::Types::Moose qw(Int Str Object CodeRef Any ArrayRef);

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

subtype Location_Symbol,
    as Str,
    where {exists $VALID_SEGMENT_SYMBOL{$_}},
    message {"Unknown Location symbol $_"};

subtype Location_Type,
    as Str,
    where {exists $VALID_SEGMENT_TYPE{$_}},
    message {"Unknown Location type $_"};

subtype Location_Pos_Symbol,
    as Str,
    where {exists $VALID_SEGMENT_POS_SYMBOL{$_}},
    message {"Unknown Location positional symbol $_"};
    
subtype Location_Pos_Type,
    as Str,
    where {exists $VALID_SEGMENT_POS_TYPE{$_}},
    message {"Unknown Location positional type $_"};

coerce Location_Pos_Type,
    from Location_Pos_Symbol,
    via {$TYPE_SYMBOL{$_}};
    
coerce Location_Pos_Symbol,
    from Location_Pos_Type,
    via {$SYMBOL_TYPE{$_}};

coerce Location_Symbol,
    from Location_Type,
    via {$SYMBOL_TYPE{$_}};

coerce Location_Type,
    from Location_Symbol,
    via {$TYPE_SYMBOL{$_}};
    
my %VALID_SPLIT_TYPE = map {$_ => 1}
    qw(JOIN ORDER BOND);
    
subtype Split_Location_Type,
    as Str,
    where {exists $VALID_SPLIT_TYPE{uc $_}},
    message {"Unknown Split Location type $_"};

role_type Does_Range, { role => 'Biome::Role::Location::Does_Range' };

subtype ArrayRef_of_Ranges,
    as ArrayRef[Does_Range],
    message {"Non-Range added to Split Location"};

no MooseX::Types;
no MooseX::Types::Moose;

1;

__END__

