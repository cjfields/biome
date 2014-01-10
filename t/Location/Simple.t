use strict;
use warnings;

BEGIN {
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Location::Simple');
}

my $simple = Biome::Location::Simple->new(
    start  => 10,
    end    => 20,
    strand => 1,
    seq_id => 'my1',
    is_remote => 1);
isa_ok($simple, 'Biome::Location::Simple');
does_ok($simple, 'Biome::Role::Location::Simple',  'does Location');
does_ok($simple, 'Biome::Role::Location::Locatable',  'has basic Locatable interface');

is($simple->start, 10, 'has a start location');
is($simple->end, 20,  'has an end location');
is($simple->seq_id, 'my1',  'has an identifier');
is($simple->start_pos_type, 'EXACT', 'pos_type is EXACT for start');
is($simple->end_pos_type, 'EXACT', 'pos_type is EXACT for end');
ok($simple->valid_Location);
is($simple->location_type, 'EXACT',  'has a default location type');
ok(!$simple->is_fuzzy);

is ($simple->to_string, 'my1:10..20', 'full FT string');

my $f;

my $exact = Biome::Location::Simple->new(
                    start         => 10,
                    end           => 11,
                    location_type  => 'IN-BETWEEN',
                    strand        => 1,
                    seq_id        => 'my2');

is($exact->start, 10, 'Biome::Location::Simple IN-BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->location_type, 'IN-BETWEEN');
ok(!$exact->is_fuzzy);

is ($exact->to_string, '10^11','full FT string');

# check coercions with location_type and strand
$exact = Biome::Location::Simple->new(
                    start         => 10,
                    end           => 11,
                    location_type  => '^',
                    strand        => '+');

is($exact->start, 10, 'Bio::Location::Simple IN-BETWEEN');
is($exact->end, 11);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, undef);
is($exact->length, 0);
is($exact->location_type, 'IN-BETWEEN');
is($exact->start_pos_type, 'EXACT');
is($exact->end_pos_type, 'EXACT');

is($exact->to_string, '10^11', 'full FT string');

$exact = Biome::Location::Simple->new(
                    start          => 10,
                    end            => 20,
                    start_pos_type => '<',
                    end_pos_type   => '>', # this should default to 'EXACT'
                    strand         => '+');

is($exact->start, 10);
is($exact->end, 20);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, undef);
is($exact->length, 11);

# this doesn't seem correct, shouldn't it be 'FUZZY' or 'UNCERTAIN'?
is($exact->location_type, 'EXACT');

is($exact->start_pos_type, 'BEFORE');
is($exact->end_pos_type, 'AFTER');
ok($exact->is_fuzzy);

is($exact->to_string, '<10..>20', 'full FT string');

# check coercions with start/end_pos_type, and length determination
$exact = Biome::Location::Simple->new(
                    start          => 10,
                    end            => 20,
                    start_pos_type => '<',
                    strand         => '+');

is($exact->start, 10);
is($exact->end, 20);
is($exact->strand, 1, 'strand coerced');
is($exact->seq_id, undef);
is($exact->length, 11);
is($exact->location_type, 'EXACT');
is($exact->start_pos_type, 'BEFORE');
is($exact->end_pos_type, 'EXACT');

is($exact->to_string, '<10..20', 'full FT string');

# check exception handling

# Locations must have start < end or will throw an exception
throws_ok { $exact = Biome::Location::Simple->new(
                    start          => 100,
                    end            => 10,
                    strand         => '+') }
    qr/Start must be less than end/,
    'Start must be less than end';

throws_ok { $exact = Biome::Location::Simple->new(
                    start          => 10,
                    end            => 12,
                    start_pos_type => '>',
                    strand         => '+') }
    qr/Start position can't have type AFTER/,
    'Check start_pos_type constraint';

throws_ok { $exact = Biome::Location::Simple->new(
                    start          => 10,
                    end            => 12,
                    end_pos_type   => '<',
                    strand         => '+') }
    qr/End position can't have type BEFORE/,
    'Check end_pos_type constraint';


throws_ok {$exact = Biome::Location::Simple->new(start         => 10,
                                   end           => 12,
                                   location_type => 'IN-BETWEEN')}
    qr/length of location with IN-BETWEEN/,
    'IN-BETWEEN must have length of 1';

# fuzzy location tests
my $fuzzy = Biome::Location::Simple->new(
                                     start    => 10,
                                     start_pos_type => '<',
                                     end      => 20,
                                     strand   => 1,
                                     seq_id   =>'my2');

is($fuzzy->strand, 1, 'Biome::Location::Simple tests');
is($fuzzy->start, 10);
is($fuzzy->end,20);
ok(!defined $fuzzy->min_start);
is($fuzzy->max_start, 10);
is($fuzzy->min_end, 20);
is($fuzzy->max_end, 20);
is($fuzzy->location_type, 'EXACT');
is($fuzzy->start_pos_type, 'BEFORE');
is($fuzzy->end_pos_type, 'EXACT');
is($fuzzy->seq_id, 'my2');
is($fuzzy->seq_id('my3'), 'my3');

# Test Biome::Location::Simple

ok($exact = Biome::Location::Simple->new(start    => 10,
                                         end      => 20,
                                         strand   => 1,
                                         seq_id   => 'my1'));
does_ok($exact, 'Biome::Role::Location::Simple');

is( $exact->start, 10, 'Biome::Location::Simple EXACT');
is( $exact->end, 20);
is( $exact->seq_id, 'my1');
is( $exact->length, 11);
is( $exact->location_type, 'EXACT');

ok ($exact = Biome::Location::Simple->new(start         => 10,
                                      end           => 11,
                                      location_type => 'IN-BETWEEN',
                                      strand        => 1,
                                      seq_id        => 'my2'));

is($exact->start, 10, 'Biome::Location::Simple BETWEEN');
is($exact->end, 11);
is($exact->seq_id, 'my2');
is($exact->length, 0);
is($exact->location_type, 'IN-BETWEEN');

# 'fuzzy' locations are combined with simple ones in Biome

my $error = qr/length of location with IN-BETWEEN position type cannot be larger than 1/;

# testing error when assigning 10^12 simple location into fuzzy
throws_ok {
    $fuzzy = Biome::Location::Simple->new(
                                        start         => 10,
                                        end           => 12,
                                        location_type  => '^',
                                        strand        => 1,
                                        seq_id        => 'my2');
} $error, 'Exception:IN-BETWEEN locations should be contiguous';

$fuzzy = Biome::Location::Simple->new(location_type => '^',
                                  strand        => 1,
                                  seq_id        => 'my2');

$fuzzy->start(10);
throws_ok { $fuzzy->end(12) } $error, 'Exception:IN-BETWEEN locations should be contiguous';

$fuzzy = Biome::Location::Simple->new(location_type => '^',
                                  strand        => 1,
                                  seq_id        =>'my2');

$fuzzy->end(12);
throws_ok { $fuzzy->start(10); } $error, 'Exception:IN-BETWEEN locations should be contiguous';


#########################################
# split location tests
#########################################

## note that the location_type for 'split' locations must be specified
my $container = Biome::Location::Simple->new(location_type => 'JOIN');

# most complex Range role
does_ok($container, 'Biome::Role::Location::Simple');
does_ok($container, 'Biome::Role::Location::Locatable');

$f = Biome::Location::Simple->new(start  => 13,
				  end    => 30,
				  strand => 1);
$container->add_sub_Location($f);
is($f->start, 13);
is($f->min_start, 13);
is($f->max_start,13);

$f = Biome::Location::Simple->new(start  =>30,
			       end    =>90,
			       strand =>1);
$container->add_sub_Location($f);

$f = Biome::Location::Simple->new(start  =>18,
			       end    =>22,
			       strand =>1);
$container->add_sub_Location($f);

$f = Biome::Location::Simple->new(start  =>19,
			       end    =>20,
			       strand =>1);

$container->add_sub_Location($f);

$f = Biome::Location::Simple->new(
                  start_pos_type => '<',
                  start  => 50,
			      end    => 61,
			      strand => 1);
is($f->start, 50);
is($f->to_string(), '<50..61');

ok(! defined $f->min_start);
is($f->max_start, 50);

is($container->num_sub_Locations(), 4);

is($container->max_end, 90);
is($container->min_start, 13);
is($container->start, 13);
is($container->end, 90);

$container->add_sub_Location($f);
is($container->num_sub_Locations(), 5);

$simple = Biome::Location::Simple->new(start => 10,
									   end	 => 20);

$fuzzy = Biome::Location::Simple->new( start => 10,
									   start_pos_type => '<',
									   end	 => 20);

#$fuzzy->strand(-1);
#is($fuzzy->to_string(), 'complement(<10..20)');
#
#is($simple->to_string(), '10..20');
#$simple->strand(-1);
#is($simple->to_string(), 'complement(10..20)');
#is( $container->to_string(),
#    'join(13..30,30..90,18..22,19..20,<50..61)');
#
## test for bug #1074
#$f = Biome::Location::Simple->new(start  => 5,
#			       end    => 12,
#			       strand => -1);
#$container->add_sub_Location($f);
#is( $container->to_string(),
#    'join(13..30,30..90,18..22,19..20,<50..61,complement(5..12))',
#	'Bugfix 1074');
#$container->strand(-1);
#
#TODO: {
#    local $TODO = "Check this test, may not be correct with this implementation";
#    is( $container->to_string(),
#    'complement(join(13..30,30..90,18..22,19..20,<50..61,5..12))');
#}
#
## test that can call seq_id() on a split location;
#$container = Biome::Location::Simple->new(seq_id => 'mysplit1');
#is($container->seq_id,'mysplit1', 'seq_id() on Bio::Location::Simple');
#is($container->seq_id('mysplit2'),'mysplit2');

done_testing();

__END__
