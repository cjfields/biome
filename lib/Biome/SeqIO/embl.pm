package Biome::SeqIO::embl;

use Biome::Role;

with 'Biome::Role::Stream::Seq';

sub next_seq {
    $_[0]->throw_not_implemented;
}

sub next_dataset {
    $_[0]->throw_not_implemented;
}

sub write_seq {
    $_[0]->throw_not_implemented;
}

no Biome::Role;

1;

__END__
