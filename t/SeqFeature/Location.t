# -*-Perl-*- Test Harness script for Bioperl
# $Id: Location.t 15112 2008-12-08 18:12:38Z sendu $

use strict;

BEGIN {
    
    use Test::More qw/no_plan/;	
    use Test::Moose;
    use_ok('Biome::Location::Simple');
}

my $simple = Biome::Location::Simple->new('-start' => 10, '-end' => 20,
				       '-strand' => 1, -seq_id => 'my1');
isa_ok($simple, 'Biome::Location::Simple');
does_ok($simple, 'Biome::Role::Location',  'has a location  role');

is($simple->start, 10, 'has a start location');
is($simple->end, 20,  'has an end location');
is($simple->seq_id, 'my1',  'has an identifier');
is($simple->location_type, 'EXACT',  'has a default location type');

my ($loc) = $simple->each_Location();
ok($loc);
is("$loc", "$simple",  'is a Bio::Location::Simple object');

# test that even when end < start that length is always positive
my $f = Biome::Location::Simple->new(-verbose => 1,
			       -start   => 100, 
			       -end     => 20, 
			       -strand  => 1);

is($f->length, 81, 'Positive length');
is($f->strand,-1);

# Test Bio::Location::Exact
my $exact = Biome::Location::Simple->new(-start    => 10, 
					 -end      => 20,
					 -strand   => 1, 
					 -seq_id   => 'my1');
isa_ok($exact, 'Biome::Location::Simple');

is( $exact->start, 10, 'has a exact start location');
is( $exact->end, 20);
is( $exact->seq_id, 'my1');
is( $exact->length, 11);
is( $exact->location_type, 'EXACT');

ok ($exact = Biome::Location::Simple->new(-start         => 10, 
				      -end           => 11,
				      -location_type => 'IN-BETWEEN',
				      -strand        => 1, 
				      -seq_id        => 'my2'));

is($exact->start, 10, 'Bio::Location::Simple IN-BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->location_type, 'IN-BETWEEN');

eval {
    $exact = Biome::Location::Simple->new(-start         => 10, 
				       -end           => 12,
				       -location_type => 'IN-BETWEEN');
};
ok( $@, 'Testing error handling' );


# testing coodinate policy modules

use_ok('Biome::Location::WidestCoordPolicy');

