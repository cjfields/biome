#!/usr/bin/perl -w
use strict;
use warnings;

BEGIN {
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    use File::Spec;
    use File::Temp;
}

##############################################
# test -fh (filehandles)
##############################################

{
    package Foo_Handle;
    use Biome;
    with 'Biome::Role::IO::Handle';
    no Biome;
}

my $TESTINFILE = File::Spec->catfile(qw(t data lorem.txt));
my $testfile = 'testfile.txt';

{

# test with handles

ok open(my $I, $TESTINFILE);
ok open(my $O, '>', $testfile);

ok my $rio = Foo_Handle->new(-fh => $I );
is $rio->mode, 'r', 'handle, read';
isa_ok($rio->fh, 'GLOB');

ok my $wio = Foo_Handle->new(-fh => $O);
is $wio->mode, 'w', 'handle, write';
isa_ok($wio->fh, 'GLOB');

my $warn;
local $SIG{__WARN__} = sub { $warn = shift };
my $tempfile = File::Temp->new;
my $temp_io;
ok $temp_io = Foo_Handle->new( -fh => $tempfile );
is $temp_io->mode, 'w', 'is a write handle';
ok($temp_io->close);
ok !$warn, 'no warnings';

}

##############################################
# test -file (file names)
##############################################

{
    package Foo_File;
    use Biome;
    with 'Biome::Role::IO::Handle';
    with 'Biome::Role::IO::File';
    with 'Biome::Role::IO::Buffer';
    no Biome;
}

{
#test with files

my $obj = File::Temp->new();
my $fn = $obj->filename;

ok my $rio = Foo_File->new(-file => $TESTINFILE);
is $rio->mode, 'r', 'filename, read';

ok my $wio = Foo_File->new(-file => "> $fn");
is $wio->mode, 'w', 'filename, write';
}

###############################################
## tests readline, pushback for multi-line buffering
###############################################

{

my $rio = Foo_File->new(-file => $TESTINFILE );

my $line1 = $rio->readline;
my $line2 = $rio->readline;

ok $rio->pushback($line1);
ok $rio->pushback($line2);

my $line3 = $rio->readline;
my $line4 = $rio->readline;
my $line5 = $rio->readline;

is $line1, $line3;
is $line2, $line4;
isnt $line5, $line4;

# now test to see if buffer carries over (should be localized to the
ok $rio->pushback($line2);
ok $rio->pushback($line5);

ok($rio->close);
my $rio2 = Foo_File->new(-file => $TESTINFILE );

my $newline1 = $rio2->readline;
my $newline2 = $rio2->readline;

is($newline1, $line1);
is($newline2, $line2);

ok($rio2->close);

}

##############################################
# test -scalar
##############################################

{
    package Foo_String;
    use Biome;
    with 'Biome::Role::IO::Handle';
    with 'Biome::Role::IO::Buffer_Unread';
    with 'Biome::Role::IO::Scalar';
    no Biome;
}

{
    my $teststring = "Foo\nBar\nBaz";
    ok my $rio = Foo_String->new(-scalar => \$teststring), 'default -scalar method';
    is $rio->mode, 'r', 'scalar, read';

    my $line1 = $rio->readline;
    is($line1, "Foo\n");

    my $line2 = $rio->readline;
    is($line2, "Bar\n");
    $rio->pushback($line2);

    chomp($line1); # modify data
    throws_ok {$rio->pushback($line1)}
        qr/Pushing back data with modified line ending/,
        'pushing back data modified from $/ dies';

    my $line3 = $rio->readline;
    is($line3, "Bar\n");
    $line3 = $rio->readline;
    is($line3, "Baz");

    # does pushing back last line trigger error?
    lives_ok {$rio->pushback($line3)} 'pushing back last line works';
}

##############################################
# test tempfile role (wraps some File::Temp methods)
##############################################

{
    package Foo_Tempfile;
    use Biome;
    with 'Biome::Role::IO::Handle';
    with 'Biome::Role::IO::File';
    with 'Biome::Role::IO::Tempfile';
    no Biome;
}

{

my $tmp_obj = Foo_Tempfile->new();

my ($tfh, $fn) = $tmp_obj->tempfile();

is($tmp_obj->file, $fn);

}

##############################################
# test Unread role
##############################################

SKIP: {
    eval {
        package Foo_Unread;
        use Biome;
        with 'Biome::Role::IO::Handle';
        with 'Biome::Role::IO::File';
        with 'Biome::Role::IO::Buffer_Unread';
        no Biome;
    };

    skip("Tests require IO::Unread", 9) if ($@);

    {
    # IO::Unread has a buffering layer built in, but the order is different;
    # (stack instead of queue).

    my $rio = Foo_Unread->new(-file => $TESTINFILE );

    my $line1 = $rio->readline; # Lorem ...
    my $line2 = $rio->readline; # pulvinar ...

    # Note order
    ok $rio->pushback($line2); # pulvinar ...
    ok $rio->pushback($line1); # Lorem ...

    my $line3 = $rio->readline; # Lorem ...
    my $line4 = $rio->readline; # pulvinar ...
    my $line5 = $rio->readline;

    is $line1, $line3;
    is $line2, $line4;
    isnt $line5, $line4;

    # now test to see if buffer carries over (should be localized to the
    # instance)

    ok $rio->pushback($line2);
    ok $rio->pushback($line5);

    my $rio2 = Foo_Unread->new(-file => $TESTINFILE );

    my $newline1 = $rio2->readline;
    my $newline2 = $rio2->readline;

    is($newline1, $line1);
    is($newline2, $line2);

    }
}

#############################################
# tests for finding executables
#############################################
# An executable file
#my $test_file = 'test_file.txt';
#open my $FILE, '>', $test_file || die "Could not write file '$test_file': $!\n";
#print $FILE 'test';
#close $FILE;
#chmod 0777, $test_file || die "Could not change permission of file '$test_file': $!\n";
#ok ($io->exists_exe($test_file), 'executable file');
#
## A non-executable file
#chmod 0444, $test_file || die "Could not change permission of file '$test_file': $!\n";
#ok (! $io->exists_exe($test_file), 'non-executable file');
#unlink $test_file || die "Could not delete file '$test_file': $!\n";
#
## An executable dir
#my $test_dir = 'test_dir';
#mkdir $test_dir or die "Could not write dir '$test_dir': $!\n";
#chmod 0777, $test_dir or die "Could not change permission of dir '$test_dir': $!\n";
#ok (! $io->exists_exe($test_dir), 'executable dir');
#rmdir $test_dir or die "Could not delete dir '$test_dir': $!\n";

##############################################
# tests http retrieval
##############################################

#SKIP: {
 # test_skip(-tests => 2, -requires_networking => 1);

    #my $TESTURL = 'http://www.google.com/index.html';
    #
    #ok(my $rio = Foo->new(-url=>$TESTURL), 'default -url method');

#}

##############################################
# tests all-in-one class (if you really want everything)
##############################################

# this uses IO::Unread, which may become a req. module
SKIP: {
    eval {
        package Foo_All;

        use Biome;

        extends 'Biome::Root::IO';

        no Biome;
    };

    skip("IO::Unread not installed, skipping", 5) if $@;

    {

    ok my $rio = Foo_All->new(-file => $TESTINFILE);

    does_ok($rio, 'Biome::Role::IO::Handle');
    does_ok($rio, 'Biome::Role::IO::File');
    does_ok($rio, 'Biome::Role::IO::Tempfile');
    does_ok($rio, 'Biome::Role::IO::Buffer_Unread');
    does_ok($rio, 'Biome::Role::IO::Scalar');

    }
}

##############################################
# cleanup
##############################################

for my $f ($testfile) {
    unlink $f if -e $f;
}

done_testing;
