package Biome::Role::CollectTags;

use Biome::Role;

use MooseX::AttributeHelpers;

has tag_map => (
    is          => 'rw',
    metaclass   => 'Collection::Hash',
    isa         => 'HashRef[ArrayRef[Str]]',
    default     => sub { { } },
    provides    => {
        delete  => 'remove_tag',
        get     => 'get_tag_values',
        keys    => 'get_all_tags',
        exists  => 'has_tag',
        clear   => 'remove_all_tags'
        }
);

sub set_tag_values {
    my ($self, @args) = @_;
    my $map = $self->tag_map;
    my ($tag, $value) = $self->rearrange([qw(TAG VALUES)], @args);
    $map->{$value} = (ref($value) eq 'ARRAY') ? $value : [ $value ];
}

sub add_tag_values {
    my ($self, @args) = @_;
    my $map = $self->tag_map;
    my ($tag, $value) = $self->rearrange([qw(TAG VALUES)], @args);
    push @{$map->{$value}}, (ref($value) eq 'ARRAY') ? @$value : $value;
}
    
no Biome::Role;

__END__

# this is a simple abstract role to hold tagged values; 
