package Biome::SeqFeature::Simple;

use Biome;
use namespace::clean -except => qw(meta);

with 'Biome::Role::Location::Range';
with 'Biome::Role::Location::Locatable';

# note: due to a bug in Moose, abstract roles have to be consumed here instead
# of in the implementing role when attributes are required.

with 'Biome::Role::SeqFeature';

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Biome::SeqFeature::Simple - simple sequence feature class

=head1 VERSION

This documentation refers to Biome::SeqFeature::Simple version 0.01.

=head1 SYNOPSIS

   use Biome::SeqFeature::Simple;
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

Biome::SeqFeature::Simple is a simplified lightweight implementation of the
Biome::Role::SeqFeature interface. This class has a simple tag/value system for
storing data (no official typing system or ontology specified), and uses simple
start/end/strand for the location information (via the
L<Biome::Role::Location::SimpleRange> interface). This implementation resembles
most in spirit the L<Bio::DB::SeqFeature> in simplicity and differs
significantly from the BioPerl L<Bio::SeqFeature::Generic>
implementation, in that locations cannot be split and must be represented via
subFeatures.

=head1 SUBROUTINES/METHODS

<TODO>

=head1 DIAGNOSTICS

None

=head1 CONFIGURATION AND ENVIRONMENT

None

=head1 DEPENDENCIES

None outside the distribution.

=head1 INCOMPATIBILITIES

None known

=head1 BUGS AND LIMITATIONS

None known

User feedback is an integral part of the evolution of this and other Biome and
BioPerl modules. Send your comments and suggestions preferably to one of the
BioPerl mailing lists. Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

Patches are always welcome.

=head2 Support

Please direct usage questions or support issues to the mailing list:

L<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and reponsive
experts will be able look at the problem and quickly address it. Please include
a thorough description of the problem with code and data examples if at all
possible.

=head2 Reporting Bugs

Preferrably, Biome bug reports should be reported to the GitHub Issues bug
tracking system:

  http://github.com/cjfields/biome/issues

Bugs can also be reported using the BioPerl bug tracking system, submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 EXAMPLES

=head1 FREQUENTLY ASKED QUESTIONS

=head1 COMMON USAGE MISTAKES

<TODO>

=head1 SEE ALSO

<TODO>

=head1 (DISCLAIMER OF) WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

The original BioPerl developers and authors for the various BioPerl SeqFeature
implementations.

=head1 AUTHOR

Chris Fields  (cjfields at bioperl dot org)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Chris Fields (cjfields at bioperl dot org). All rights
reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
