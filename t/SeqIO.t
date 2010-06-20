# -*-Perl-*- Test Harness script for Biome

use strict;

BEGIN { 
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use_ok('Biome::SeqIO');
}

ok my $in = Biome::SeqIO->new(-format => 'fasta');

# does the plugin
isa_ok($in, 'Biome::SeqIO::fasta');

# does the IO roles
does_ok($in, 'Biome::Role::IO::Buffer_Unread');
does_ok($in, 'Biome::Role::IO::Scalar');

# isa as well
isa_ok($in, 'Biome::SeqIO');
isa_ok($in, 'Biome::Root::IO');

done_testing;
