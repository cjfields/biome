use strict;
use warnings;

my $EXCEPTION_CLASS;

BEGIN {
    use lib qw(. t/lib);
    use Test::More;
    use Test::Moose;
    use Test::Exception;
    eval { require MyExceptions; 1 };
    if ($@) {
        $EXCEPTION_CLASS = 0;
    } else {
        $EXCEPTION_CLASS = 1;
    }
}

{
    package Foo;
    
    use Biome;
    
    has foo => ( is => 'ro');
    
    main::does_ok('Foo', 'Biome::Role::Root');
    main::isa_ok(Foo->meta, 'Moose::Meta::Class');
    #main::isa_ok(Foo->meta->error_class, 'Biome::Meta::Error');
}

# test out simple errors

my $test1 = Foo->new();

does_ok($test1, 'Biome::Role::Root');
isa_ok($test1->meta, 'Moose::Meta::Class');
#isa_ok($test1->meta->error_class, 'Biome::Meta::Error');

throws_ok {$test1->throw('Arg!');} qr/Arg!/, 'simple throw';

{
    # create one's own Biome::Exception-based exception class
    # this is a lightweight subclass of Moose::Exception
    package Biome::Exception::CustomError;
    
    use Biome;
    
    extends 'Biome::Exception';
    
    has really_bad_stuff => (is => 'rw', default => 'really bad stuff');
}

throws_ok {$test1->throw('Grr!', 'CustomError');}
    qr/Grr!/, 'custom Biome-based error class';

isa_ok($@, 'Biome::Exception::CustomError', 'custom error metaclass');
isa_ok($@, 'Biome::Exception', 'inherited');
isa_ok($@, 'Moose::Exception', 'inherited');

# small repeat of Moose exception tests, geared towards Biome
my $line;
sub blah { $line = __LINE__; shift->foo(4) }

sub create_error {
    eval {
        eval { die "Blah" };
        blah(shift);
    };
    ok( my $e = $@, "got some error" );
    return {
        file  => __FILE__,
        line  => $line,
        error => $e,
    };
}
    
my $e = create_error( my $foo = Foo->new );
isa_ok( $e->{error}, "Moose::Exception" );
unlike( $e->{error}->message, qr/line $e->{line}/s,
    "no line info, just a message" );

done_testing();
