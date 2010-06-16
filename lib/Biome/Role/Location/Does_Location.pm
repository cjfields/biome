package Biome::Role::Location::Does_Location;

use Biome::Role;
use namespace::clean -except => 'meta';

with 'Biome::Role::Location::Does_Range';

# some of these may be attributes, some methods
requires qw(
    start_pos_type
    end_pos_type
    start_offset
    end_offset
    
    min_start
    max_start
    min_end
    max_end
    
    is_remote
    is_fuzzy
    
    valid_Location
);

1;

__END__
