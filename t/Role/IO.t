#!/usr/bin/perl -w
use strict;
use warnings;

BEGIN {
    use Test::More;
    use Test::Moose;
    use Test::Exception;
}

{
    package Foo;
    use Biome;
    with 'Biome::Role::IO';
    no Biome;
}

my $io;

lives_ok {$io = Foo->new()} 'IO Role consumed';

does_ok($io,'Biome::Role::IO');

#eval { $obj->throw('Testing throw') };
#like $@, qr/Testing throw/, 'throw()'; # 'throw failed';
#
#$obj->verbose(-1);
#eval { $obj->throw('Testing throw') };
#like $@, qr/Testing throw/, 'throw() verbose(-1)'; # 'verbose(-1) throw did not work properly' . $@;
#
#eval { $obj->warn('Testing warn') };
#ok !$@, 'warn()';
#
#$obj->verbose(1);
#eval { $obj->throw('Testing throw') };
#like $@, qr/Testing throw/, 'throw() verbose(1)'; # 'verbose(1) throw did not work properly' . $@;
#
#my @stack = $obj->stack_trace();
#is scalar @stack, 2, 'stack_trace()';
#
#my $verbobj = Bio::Root::IO->new(-verbose=>1,-strict=>1);
#is $verbobj->verbose(), 1, 'set verbosity to 1';
#
#ok $obj->verbose(-1);

#############################################
# tests for finding executables
#############################################
# An executable file
my $test_file = 'test_file.txt';
open my $FILE, '>', $test_file || die "Could not write file '$test_file': $!\n";
print $FILE 'test';
close $FILE;
chmod 0777, $test_file || die "Could not change permission of file '$test_file': $!\n";
ok ($io->exists_exe($test_file), 'executable file');

# A non-executable file
chmod 0444, $test_file || die "Could not change permission of file '$test_file': $!\n";
ok (! $io->exists_exe($test_file), 'non-executable file');
unlink $test_file || die "Could not delete file '$test_file': $!\n";

# An executable dir
my $test_dir = 'test_dir';
mkdir $test_dir or die "Could not write dir '$test_dir': $!\n";
chmod 0777, $test_dir or die "Could not change permission of dir '$test_dir': $!\n";
ok (! $io->exists_exe($test_dir), 'executable dir');
rmdir $test_dir or die "Could not delete dir '$test_dir': $!\n";

#############################################
# tests for handle read and write abilities
#############################################

#my ($handle,$file) = $io->tempfile;
#ok $handle;
#ok $file;

done_testing;

##test with files
#
#ok my $rio = Bio::Root::IO->new(-file=>$TESTINFILE);
#is $rio->mode, 'r', 'filename, read';
#
#ok my $wio = Bio::Root::IO->new(-file=>">$file");
#is $wio->mode, 'w', 'filename, write';
#
## test with handles
#
#ok open(my $I, $TESTINFILE);
#ok open(my $O, '>', $file);
#
#ok $rio = Bio::Root::IO->new(-fh=>$I);
#is $rio->mode, 'r', 'handle, read';
#
#ok $wio = Bio::Root::IO->new(-fh=>$O);
#is $wio->mode, 'w', 'handle, write';
#
###############################################
## tests _pushback for multi-line buffering
###############################################
#
#my $line1 = $rio->_readline;
#my $line2 = $rio->_readline;
#
#ok $rio->_pushback($line1);
#ok $rio->_pushback($line2);
#
#my $line3 = $rio->_readline;
#my $line4 = $rio->_readline;
#my $line5 = $rio->_readline;
#
#is $line1, $line3;
#is $line2, $line4;
#isnt $line5, $line4;
#
#ok close($I);
#ok close($O);
#
#
##############################################
# tests http retrieval
##############################################

#SKIP: {
 # test_skip(-tests => 2, -requires_networking => 1);

    #my $TESTURL = 'http://www.google.com/index.html';
    #
    #ok(my $rio = Foo->new(-url=>$TESTURL), 'default -url method');
    
#}
