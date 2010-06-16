package Biome::Role::Location::Does_SplitLocation;

use Biome::Role;
use namespace::clean -except => 'meta';

with 'Biome::Role::Location::Does_Location';

requires qw(
    add_sub_Location
    remove_sub_Locations
    sub_Locations
    get_sub_Location
    num_sub_Locations
    
    location_type
    resolve_Locations
    
    sub_Location_strand
);

1;

__END__

