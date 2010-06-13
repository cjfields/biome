# Let the code begin...

package Biome::Segment::Simple;

use 5.010;
use Biome;
use Biome::Types qw(Segment_Type Segment_Symbol
    Segment_Pos_Type Segment_Pos_Symbol Sequence_Strand);

sub BUILD {
    my ($self, $params) = @_;
    
    if ($params->{location_string}) {
        $self->throw("Can't use 'location_string' with other parameters")
            if (scalar(keys %$params) > 1);
        $self->from_string($params->{location_string});
    }
    
    if ($params->{start} && $params->{end} && ($params->{end} < $params->{start})) {
        $self->warn('End is greater than start; flipping strands');
        $self->end($params->{start});
        $self->start($params->{end});
        $self->strand($self->strand * -1);
    }
    
    $params->{segment_type} && $self->segment_type($params->{segment_type});
}

has strand  => (
    isa     => Sequence_Strand,
    is      => 'rw',
    default => 0,
    coerce  => 1
);

has 'start' => (
    isa         => 'Int',
    is          => 'rw',
    default     => 0,
    trigger     => sub {
        my ($self, $start) = @_;
        my $end = $self->end;
        return unless $start && $end;
        # could put start<->end reversal here...
        if ($self->segment_type eq 'IN-BETWEEN' &&
            (abs($end - $start) != 1 )) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1; got ".abs($end - $start));
    }
});

has 'end' => (
    isa         => 'Int',
    is          => 'rw',
    default     => 0,
    trigger     => sub {
        my ($self, $end) = @_;
        my $start = $self->start;
        return unless $start && $end;
        # could put start<->end reversal here...
        if ($self->segment_type eq 'IN-BETWEEN' &&
            (abs($end - $start) != 1) ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1; got ".abs($end - $start));
    }
});

has 'start_pos_type'    => (
    isa             => Segment_Pos_Type,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    predicate       => 'has_start_pos_type',
    trigger         => sub {
        my ($self, $v) = @_;
        return unless $self->end && $self->start;
        $self->throw("Start position can't have type $v") if $v eq 'AFTER';
        if ($v eq 'IN-BETWEEN' && $self->valid_Segment && abs($self->end - $self->start) != 1 ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         "cannot be larger than 1");
        }
    }
);

has 'end_pos_type'      => (
    isa             => Segment_Pos_Type,
    is              => 'rw',
    lazy            => 1,
    default         => 'EXACT',
    coerce          => 1,
    predicate       => 'has_end_pos_type',
    trigger         => sub {
        my ($self, $v) = @_;
        return unless $self->end && $self->start;
        $self->throw("End position can't have type $v") if $v eq 'BEFORE';
        if ($v eq 'IN-BETWEEN' && $self->valid_Segment && abs($self->end - $self->start) != 1 ) {
            $self->throw("length of segment with IN-BETWEEN position type ".
                         " cannot be larger than 1");
        }
    }
);

# this is for 'fuzzy' locations like WITHIN, BEFORE, AFTER
has [qw(start_offset end_offset)]  => (
    isa             => 'Int',
    is              => 'rw',
    lazy            => 1,
    default         => 0
);

has 'segment_type'  => (
    isa         => Segment_Type,
    is          => 'rw',
    lazy        => 1,
    default     => 'EXACT',
    coerce      => 1
);

my %IS_FUZZY = map {$_ => 1} qw(BEFORE AFTER WITHIN UNCERTAIN);

# these just delegate to start, end, using the indicated offsets

sub is_remote {
    defined($_[0]->seq_id) ? 1 : 0;
}

sub max_start {
    my ($self) = @_;
    my $start = $self->start;
    return unless $start;
    ($start + $self->start_offset);
}

sub min_start {
    my ($self) = @_;
    my $start = $self->start;
    return if !$start || ($self->start_pos_type eq 'BEFORE');
    $start;
}

sub max_end {
    my ($self) = @_;
    my $end = $self->end;
    return if !$end || ($self->end_pos_type eq 'AFTER');
    return ($end + $self->end_offset);
}

sub min_end {
    my ($self) = @_;
    my $end = $self->end;
    return unless $end;
}

sub is_fuzzy {
    my $self = shift;
    (exists $IS_FUZZY{$self->start_pos_type} ||
        exists $IS_FUZZY{$self->end_pos_type}) ? 1 : 0;
}

sub valid_Segment {
    defined($_[0]->start) && defined($_[0]->end) ? 1 : 0;
}

sub to_string {
    my ($self) = @_;
    
    my %data;
    for (qw(
        start end
        min_start max_start
        min_end max_end
        start_offset end_offset
        start_pos_type end_pos_type
        seq_id
        segment_type)) {
        $data{$_} = $self->$_;
    }
    
    for my $pos (qw(start end)) {
        my $pos_str = $data{$pos} || '';
        if ($pos eq 'end' && $data{start} == $data{end}) {
            $pos_str = '';
        }
        given ($data{"${pos}_pos_type"}) {
            when ('WITHIN') {
                $pos_str = '('.$data{"min_$pos"}.'.'.$data{"max_$pos"}.')';
            }
            when ('BEFORE') {
                $pos_str = '<'.$pos_str;
            }
            when ('AFTER') {
                $pos_str = '>'.$pos_str;
            }
            when ('UNCERTAIN') {
                $pos_str = '?'.$pos_str;
            }
        }
        $data{"${pos}_string"} = $pos_str;
    }
    
    my $str = $data{start_string}. ($data{end_string} ? 
            to_Segment_Symbol($data{segment_type}).
            $data{end_string} : '');
    $str = "$data{seq_id}:$str" if $data{seq_id};
    $str = "($str)" if $data{segment_type} eq 'WITHIN';
    if ($self->strand == -1) {
        $str = sprintf("complement(%s)",$str)
    }
    $str;
}

{
my @STRING_ORDER = qw(start loc_type end);

sub from_string {
    my ($self, $string) = @_;
    return unless $string;
    if ($string =~ /(?:join|order|bond)/) {
        $self->throw("Passing a split segment type: $string");
    }
    my %atts;
    if ($string =~ /^complement\(([^\)]+)\)$/) {
        $atts{strand} = -1;
        $string = $1;
    } else {
        $atts{strand} = 1; # though, this assumes nucleotide sequence...
    }
    my @loc_data = split(/(\.{2}|\^|\:)/, $string);
    
    # SeqID
    if (@loc_data == 5) {
        $atts{seq_id} = shift @loc_data;
        shift @loc_data; # get rid of ':'
    }
    for my $i (0..$#loc_data) {
        my $order = $STRING_ORDER[$i];
        my $str = $loc_data[$i];
        if ($order eq 'start' || $order eq 'end') {
            $str =~ s{[\[\]\(\)]+}{}g;
            if ($str =~ /^([<>\?])?(\d+)?$/) {
                $atts{"${order}_pos_type"} = $1 if $1;
                $atts{$order} = $2;
            } elsif ($str =~ /^(\d+)\.(\d+)$/) {
                $atts{"${order}_pos_type"} = '.';
                $atts{$order} = $1;
                $atts{"${order}_offset"} = $2 - $1;
            } else {
                $self->throw("Can't parse location string: $str");
            }
        } else {
            $atts{segment_type} = $str;
        }
    }
    if ($atts{start_pos_type} && $atts{start_pos_type} eq '.' &&
        (!$atts{end} && !$atts{end_pos_type})
        ) {
        $atts{end} = $atts{start} + $atts{start_offset};
        delete @atts{qw(start_offset start_pos_type end_pos_type)};
        $atts{segment_type} = '.';
    }
    $atts{end} ||= $atts{start} unless $atts{end_pos_type};
    for my $m (sort keys %atts) {
        if (defined $atts{$m}){
            $self->$m($atts{$m}) 
        }
    }
}

}

sub flip_strand {
    my $self= shift;
    $self->strand($self->strand * -1);
}

sub sub_Segments { }

# define abstract role here
with 'Biome::Role::Segment';

no Biome;

__PACKAGE__->meta->make_immutable;

1;

__END__
