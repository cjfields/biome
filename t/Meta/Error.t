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
    qr/Biome::Exception::CustomError/, 'custom Biome-based error class';

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
isa_ok( $e->{error}, "Biome::Meta::Error" );
#isa_ok( $e->{error}, "Exception::Class::Base" );
isa_ok( $foo->meta, 'Biome::Meta::Class');
unlike( $e->{error}->message, qr/line $e->{line}/s,
    "no line info, just a message" );
isa_ok( $e->{error}->metaclass, "Biome::Meta::Class", "metaclass" );
is( $e->{error}->metaclass, Foo->meta, "metaclass value" );
isa_ok( $e->{error}->attr, "Moose::Meta::Attribute", "attr" );
is( $e->{error}->attr, Foo->meta->get_attribute("foo"), "attr value" );
isa_ok( $e->{error}->method, "Moose::Meta::Method", "method" );
is( $e->{error}->method, Foo->meta->get_method("foo"), "method value" );
is( $e->{error}->line,   $e->{line},                   "line attr" );
is( $e->{error}->file,   $e->{file},                   "file attr" );
is_deeply( $e->{error}->data, [ $foo, 4 ], "captured args" );
like( $e->{error}->last_error, qr/Blah/, "last error preserved" );

#SKIP: {
#    skip('Exception::Class not found, skipping', 10) unless $EXCEPTION_CLASS;
#    {
#        package Foo_EC;
#
#        use Biome;
#        use lib 't/lib';
#
#        sub unimplemented {
#            shift->throw(
#                -class => 'MyExceptions::VirtualMethod',
#                -text => 'Abstract method'
#            );
#        }
#
#        sub bad_param {
#            my ($self, $param) = @_;
#            $self->throw(
#                -class => 'MyExceptions::Params',
#                -text => 'Bad Param "'.$param.'"'
#            );
#        }
#
#        sub bad_state {
#            shift->throw(
#                -class => 'MyExceptions::ObjectState',
#                -text => 'Bad State'
#            );
#        }
#    }
#
#    my $inst = Foo_EC->new();
#    throws_ok {$inst->bad_state} qr/Bad\sState/, 'Simple error message';
#    isa_ok($@, 'MyExceptions::ObjectState', 'special exception class');
#    isa_ok($@, 'Exception::Class::Base', 'can use Exception::Class');
#    is($@->description, 'Method called on an object which its current state does not allow');
#    throws_ok {$inst->unimplemented} qr/Abstract\smethod/, 'Simple error message';
#    isa_ok($@, 'MyExceptions::VirtualMethod',);
#    is($@->description, 'Method called must be subclassed in the appropriate class');
#    throws_ok {$inst->bad_param('urg')} qr/Bad\sParam\s"urg"/, 'Simple error message';
#    isa_ok($@, 'MyExceptions::Params');
#    is($@->description, 'An error in the parameters passed in a method of function call');
#}

done_testing();
