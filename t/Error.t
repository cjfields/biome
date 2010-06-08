use strict;
use warnings;

BEGIN {
    use lib '.';
    use Test::More;
    use Test::Moose;
    use Test::Exception;
}

{
    package Foo;
    
    use Biome;
    
    has foo => ( is => 'ro');
    
    main::isa_ok('Foo', 'Biome::Root');
    main::isa_ok(Foo->meta, 'Biome::Meta::Class');
    main::isa_ok(Foo->meta->error_class, 'Biome::Root::Error');
}

# test out simple errors

my $test1 = Foo->new();

isa_ok($test1, 'Biome::Root');
isa_ok($test1->meta, 'Biome::Meta::Class');
isa_ok($test1->meta->error_class, 'Biome::Root::Error');

throws_ok {$test1->throw('Arg!');} qr/MSG: Arg!/, 'simple throw';

{
    # create one's own Biome::Root::Error based exception class
    package Bio::MyError;
    
    use Biome;
    
    extends 'Biome::Root::Error';
    
    has really_bad_stuff => (is => 'rw');
}

throws_ok {$test1->throw(-text  => 'Grr!', -class => 'Bio::MyError');}
    qr/EXCEPTION Bio::MyError/, 'custom Biome-based error class';
    
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
#isa_ok( $e->{error}, "Biome::Root::Error" );
#isa_ok( $e->{error}, "Exception::Class::Base" );
isa_ok( $foo->meta, 'Biome::Meta::Class');
unlike( $e->{error}->message, qr/line $e->{line}/s,
    "no line info, just a message" );
#isa_ok( $e->{error}->metaclass, "Biome::Meta::Class", "metaclass" );
#is( $e->{error}->metaclass, Foo->meta, "metaclass value" );
#isa_ok( $e->{error}->attr, "Moose::Meta::Attribute", "attr" );
#is( $e->{error}->attr, Foo->meta->get_attribute("foo"), "attr value" );
#isa_ok( $e->{error}->method, "Moose::Meta::Method", "method" );
#is( $e->{error}->method, Foo->meta->get_method("foo"), "method value" );
#is( $e->{error}->line,   $e->{line},                   "line attr" );
#is( $e->{error}->file,   $e->{file},                   "file attr" );
#is_deeply( $e->{error}->data, [ $foo, 4 ], "captured args" );
#like( $e->{error}->last_error, qr/Blah/, "last error preserved" );

done_testing();
