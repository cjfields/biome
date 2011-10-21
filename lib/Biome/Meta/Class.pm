package Biome::Meta::Class;

use Moose;

extends 'Moose::Meta::Class';

# overarching stuff like exception handling here

# possibly other meta sugar as well (set_from_args, others?)

# -------------------------------------------------

our $error_level;

sub throw_error {
    my ( $self, @args ) = @_;
    local $error_level = ($error_level || 0) + 1;
    $self->raise_error($self->create_error(@args));
}

sub raise_error {
    my ( $self, @args ) = @_;
    if (($args[0]->isa('Exception::Class::Base') ||
        $args[0]->isa('Error::Base'))) {
        $args[0]->throw(@args);
    } else {
        # this defaults to Moose::Error::Default
        die @args;
    }
}

sub create_error {
    my ( $self, @args ) = @_;

    my $text;
    local $error_level = ($error_level || 0 ) + 1;
    if ( @args % 2 == 1 ) {
        $text = shift @args;
    }

    my %args = (@args );

    $text ||= $args{message} || "Something's wrong!";

    my $class = $args{class} || $self->error_class;

    # we add stack trace and extra stuff only for core Biome ex. class for the
    # time being

    if ($class->isa('Biome::Meta::Error')) {
        @args{qw(metaclass last_error)} = ($self, $@);
        my $std = $self->stack_trace_dump();
        my $title = "------------- EXCEPTION $class -------------";
        my $footer = ('-' x CORE::length($title))."\n";
        my $msg = "\n$title\n". "MSG: $text\n". $std. $footer."\n";

        $args{message} = $msg;
    }
    $args{depth} += $error_level;

    Class::MOP::load_class($class);
    require Carp::Heavy;

    # Exception::Class dies unless you pass specific params, so white-list them
    my $exception = $class->isa('Exception::Class::Base') ?
        $class->new(
            @args{qw(message)}
        ) :
        $class->new(
            Carp::caller_info($args{depth}),
            %args
        ) ;

}

sub stack_trace_dump{
    my ($self) = @_;

    my @stack = $self->stack_trace();

    shift @stack;
    shift @stack;
    shift @stack;

    my $out;
    my ($module,$function,$file,$position);


    foreach my $stack ( @stack) {
        ($module,$file,$position,$function) = @{$stack};
        $out .= "STACK $function $file:$position\n";
    }

    return $out;
}

sub stack_trace{
    my ($self) = @_;

    my $i = 0;
    my @out = ();
    my $prev = [];
    while( my @call = caller($i++)) {
        # major annoyance that caller puts caller context as
        # function name. Hence some monkeying around...
        $prev->[3] = $call[3];
        push(@out,$prev);
        $prev = \@call;
    }
    $prev->[3] = 'toplevel';
    push(@out,$prev);
    return @out;
}

# -------------------------------------------------

no Moose;

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

__END__

ALL POD HERE