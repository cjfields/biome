# -*-Perl-*- Test Harness script for Biome

use strict;

BEGIN { 
    use lib '.';
    use Test::More tests => 98;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::Range');
}

=head1 Ranges

Test out simple ranges.  Locations will expand on these...

 r0 |--------->
 r1 |---------|
 r2 <---------|
 
 r3    |-->
 r4    |--|
 r5    <--|
 
 r6       |-------->
 r7       |--------|
 r8       <--------|

 r9            |-------->
 r10           |--------|
 r11           <--------|

Logic table for overlaps, contains, equals

m = method, o = overlaps()  c = contains()  e = equals
st = strand tests,  i = ignore, w = weak, s = strong

    r0       r1       r2       r3       r4       r5       r6       r7       r8       r9       r10      r11      
    o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  o  c  e  
    iwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiwsiws
r0  111111111110110110100100100111111000110110000100100000111000000110000000100000000000000000000000000000000000
r1  xxxxxxxxx110110110110110110110110000110110000110110000110000000110000000110000000000000000000000000000000000
r2  xxxxxxxxxxxxxxxxxx111111111100100000110110000111111000100000000110000000111000000000000000000000000000000000
r3  xxxxxxxxxxxxxxxxxxxxxxxxxxx111111111110110110100100100111000000110000000100000000000000000000000000000000000
r4  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx110110110110110110110000000110000000110000000000000000000000000000000000
r5  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111100000000110000000111000000000000000000000000000000000
r6  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111110110110100100100111000000110000000100000000
r7  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx110110110110110110110000000110000000110000000
r8  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111100000000110000000111000000
r9  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111110110110100100100
r10 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx110110110110110110
r11 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111

=cut 

my @spans = (
    [1, 100],
    [25,75],
    [75,125],
    [101,150]
);

my @ranges;

for my $s (@spans) {
    for my $strand (reverse (-1..1)) {
        push @ranges, Biome::Range->new(start  => $s->[0],
                                   end    => $s->[1],
                                   strand => $strand);
    }
}

does_ok($ranges[0],'Biome::Role::Rangeable', 'Range role');
isa_ok($ranges[0],'Biome::Range', 'Biome::Range class');
ok(!$ranges[0]->isa('Biome::Role::Rangeable'), 'Role consumed by class');
is($ranges[0]->start, 1);
is($ranges[0]->end, 100);
is($ranges[0]->strand, 1);
is($ranges[0]->length, 100);
is($ranges[1]->strand, 0);
is($ranges[2]->strand, -1);
is($ranges[11]->start, 101);
is($ranges[11]->end, 150);
is($ranges[11]->strand, -1);
is($ranges[11]->length, 50);

# see above for logic table 
my %map = (
r0  => '111111111111111000111000000110110110110110000110000000100100100100100000100000000000000000000000000000000000',
r1  => 'xxxxxxxxx111111000111111000110110000110110000110110000100100000100100000100100000000000000000000000000000000',
r2  => 'xxxxxxxxxxxxxxxxxx111111111110000000110110000110110110100000000100100000100100100000000000000000000000000000',
r3  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxx111111111111111000111000000100100100100100000100000000000000000000000000000000000',
r4  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111000111111000100100000100100000100100000000000000000000000000000000',
r5  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111100000000100100000100100100000000000000000000000000000',
r6  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111111111000111000000100100100100100000100000000',
r7  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111000111111000100100000100100000100100000',
r8  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111100000000100100000100100100',
r9  => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111111111000111000000',
r10 => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111000111111000',
r11 => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx111111111',  
);

# cover all variations

# logic table; uncomment code below for output

for my $i (0..$#ranges) {
    my $string = '';
    my $istring = '';
    for my $j ($i..$#ranges) {
        for my $test (qw(ignore weak strong)) {
            for my $method (qw(overlaps contains equals)) {
                $string .= $ranges[$i]->$method($ranges[$j], $test);
            }
        }
    }
    ok(exists $map{'r'.$i});
    is(sprintf("%s%s",'x' x ($i*9), $string), $map{'r'.$i}, "logic tests for ranges $i..$#ranges");
}

=head1 Geometric tests

With these ranges:

 r0 |--------->
 r1 |---------|
 r2 <---------|
 
 r3    |-->
 r4    |--|
 r5    <--|
 
 r6       |-------->
 r7       |--------|
 r8       <--------|

 r9            |-------->
 r10           |--------|
 r11           <--------|

 intersection of r0, r3, r6 => [75,75,1] for all st
 intersection of r6, r9     => [101, 125, 1] for all st
 intersection of r6, r10    => [101, 125, 0] for ignore, weak, undef for strong
 intersection of r6, r11    => [101, 125, 0] for ignore, undef for weak & strong
 intersection of r0, r6, r9 => undef for all
 
 union of r0, r3, r6        => [1,125,1] for all st
 union of r6, r9            => [75, 150, 1] for all st
 union of r6, r10           => [75, 150, 0] for all st
 union of r6, r11           => [75, 150, 0] for all st
 union of r0, r6, r9        => [1,150,1] for all st

=cut 

# geometric tests

my %geo_tests =
('0,3,6' => {     #  intersection             union
    'strong' => ['(75, 75) strand=1',   '(1, 125) strand=1'],
    'weak'   => ['(75, 75) strand=1',   '(1, 125) strand=1'],
    'ignore' => ['(75, 75) strand=1',   '(1, 125) strand=1'],
            },
 '6,9'   => {
    'strong' => ['(101, 125) strand=1', '(75, 150) strand=1'],
    'weak'   => ['(101, 125) strand=1', '(75, 150) strand=1'],
    'ignore' => ['(101, 125) strand=1', '(75, 150) strand=1'],
            },
 '6,10'   => {
    'strong' => ['',                    '(75, 150) strand=0'],
    'weak'   => ['(101, 125) strand=0', '(75, 150) strand=0'],
    'ignore' => ['(101, 125) strand=0', '(75, 150) strand=0'],
            },
 '6,11'   => {
    'strong' => ['',                    '(75, 150) strand=0'],
    'weak'   => ['',                    '(75, 150) strand=0'],
    'ignore' => ['(101, 125) strand=0', '(75, 150) strand=0'],
            },
 '0,6,9'   => {
    'strong' => ['',                    '(1, 150) strand=1'],
    'weak'   => ['',                    '(1, 150) strand=1'],
    'ignore' => ['',                    '(1, 150) strand=1'],
            },
);

for my $set (sort keys %geo_tests) {
    my @ind = split(',',$set);
    my ($primary, @rest) = @ranges[@ind];
    for my $method (qw(intersection union)) {
        for my $st (qw(ignore weak strong)) {
            my $ind = $method eq 'intersection' ? 0 : 1;
            #print ."\n";
            my $test = $primary->$method(\@rest, $st);
            my $string = (defined $test) ? $test->to_string : '';
            is($string, $geo_tests{$set}->{$st}->[$ind],"$method on $set, strand test = $st");
        }
    }
}

=head1 Subtraction

 As Ranges can be empty (length = 0), and just like any subtraction operator,
 this method always gives a Range implementor back (unlike
 Bio::RangeI::subtract()).  May change based on comments.

 r0 |--------->
 r1 |---------|
 r2 <---------|
 
 r3    |-->
 r4    |--|
 r5    <--|
 
 r6       |-------->
 r7       |--------|
 r8       <--------|

 r9            |-------->
 r10           |--------|
 r11           <--------|

 subtraction of r3 from r0  => two Ranges [1, 24, 1] and [76, 100, 1]
 subtraction of r0 from r3  => one Range [0,0,1] - empty
 subtraction of r6 from r0  => one Range [1, 74, 1] 
 subtraction of r0 from r6  => one Range [101,125,1]
 subtraction of r9 from r6  => one Range [75,100,1]
 subtraction of r6 from r9  => one Range [126,150,1]
 subtraction of r9 from r0  => original (or clone?) r0 Range [1, 100, 1] 
 subtraction of r0 from r9  => original (or clone?) r9 Range [101,150,1]

=cut

my %subtract_tests = ( # rx->subtract(ry)               ry->subtract(rx)
 '0,3' =>   {   
    'strong' =>  ['(1, 24) strand=1,(76, 100) strand=1','(0, 0) strand=0'],
    'weak'   =>  ['(1, 24) strand=1,(76, 100) strand=1','(0, 0) strand=0'],
    'ignore' =>  ['(1, 24) strand=1,(76, 100) strand=1','(0, 0) strand=0'],
            },
 '0,4' =>   {   
    'strong' =>  ['(1, 100) strand=1',                  '(25, 75) strand=0'],
    'weak'   =>  ['(1, 24) strand=1,(76, 100) strand=1','(0, 0) strand=0'],
    'ignore' =>  ['(1, 24) strand=1,(76, 100) strand=1','(0, 0) strand=0'],
            },
 '0,6' =>   {   
    'strong' =>  ['(1, 74) strand=1',                   '(101, 125) strand=1'],
    'weak'   =>  ['(1, 74) strand=1',                   '(101, 125) strand=1'],
    'ignore' =>  ['(1, 74) strand=1',                   '(101, 125) strand=1'],
            },
 '6,9' =>   {   
    'strong' =>  ['(75, 100) strand=1',                 '(126, 150) strand=1'],
    'weak'   =>  ['(75, 100) strand=1',                 '(126, 150) strand=1'],
    'ignore' =>  ['(75, 100) strand=1',                 '(126, 150) strand=1'],
            },
 '0,9' =>   {   
    'strong' =>  ['(1, 100) strand=1',                  '(101, 150) strand=1'],
    'weak'   =>  ['(1, 100) strand=1',                  '(101, 150) strand=1'],
    'ignore' =>  ['(1, 100) strand=1',                  '(101, 150) strand=1'],
            },
);

for my $set (sort keys %subtract_tests) {
    my @ind = split(',',$set);
    my ($r1, $r2) = @ranges[@ind];
    for my $st (qw(ignore weak strong)) {
        my @sub1 = $r1->subtract($r2, $st);
        my $string = join(',',map {$_->to_string} @sub1);
        is($string, $subtract_tests{$set}->{$st}->[0], "Subtract ".join(' from ',@ind).", strand test = $st");
        my @sub2 = $r2->subtract($r1, $st);
        $string = join(',',map {$_->to_string} @sub2);
        is($string, $subtract_tests{$set}->{$st}->[1], "Subtract ".join(' from ',reverse @ind).", strand test = $st");        
    }
}

# test implemention of offsetStranded:
#$r = Bio::Range->new(-start => 30, -end => 40, -strand => -1);
#isa_ok($r, 'Bio::Range', 'Bio::Range object') ;
#is ($r->offsetStranded(-5,10)->toString, '(20, 45) strand=-1');
#is ($r->offsetStranded(+5,-10)->toString, '(30, 40) strand=-1');
#$r->strand(1);
#is ($r->offsetStranded(-5,10)->toString, '(25, 50) strand=1');
#is ($r->offsetStranded(+5,-10)->toString, '(30, 40) strand=1');

#my @funcs = qw(start end length strand overlaps contains
#    equals intersection union overlap_extent disconnected_ranges
#    offsetStranded subtract);
#
#my $i = 1;
#while (my $func = shift @funcs ) {
#    $i++;
#
#    # test for presence of method
#    ok exists $Bio::RangeI::{$func};
#    
#    # union get caught in an infinite loop w/o parameters; skip invoke test.
#    next if $func eq 'union';
#    
#    # call to strand complains without a value; skip invoke test.
#    next if $func eq 'disconnected_ranges';
#    
#    # test invocation of method
#    eval { $Bio::RangeI::{$func}->(); };
#    ok($@);
#}
