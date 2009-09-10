package Biome::Role::ManageTypes;

use Biome::Role;
use MooseX::AttributeHelpers;
use List::MoreUtils 'any';

has 'type_map' => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef[Str]',
    # this should be set in the implementation, so using 'required'
    required  => 1,
    provides  => {
        exists    => 'exists_in_typemap',
        keys      => 'types',
        get       => 'type_for_key',
        set       => '_add_type_map',
    }
    );


# is-a
sub is_valid {
    my ($self,$key,$object) = @_;
    return 0 if !$self->exists_in_typemap($key) || !defined $object || !ref $object;
    (!$object->isa($self->type_for_key($key))) ?  0 : 1 ;
}

# does-a
sub does_valid {
    my ($self,$key,$object) = @_;
    return 0 if !$self->exists_in_typemap($key) || !defined $object || !ref $object;
    (!$object->does($self->type_for_key($key))) ?  0 : 1 ;
}

# has-a
sub has_valid {
    my ($self,$key,$object) = @_;
    return 0 if !$self->exists_in_typemap($key) || !defined $object || !ref $object;
    my $type = $self->type_for_key($key);
    return 1 if any {$_->isa($type) || $_->does($type)} $object->meta->get_all_attributes;
}

no MooseX::AttributeHelpers;

1;

__END__

# $Id: ManageTypes.pm 15549 2009-02-21 00:48:48Z maj $
#
# BioPerl module for Biome::Role::ManageTypes
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Biome::Role::ManageTypes - Type manager role

=head1 SYNOPSIS

    # MyTypeManager does ManageTypes

    $tm = MyTypeManager->new(-typemap =>
        {
            'reference'     => "Biome::Annotation::Reference",
            'comment'       => "Biome::Annotation::Comment",
            'dblink'        => "Biome::Annotation::DBLink",
            'simplevalue'   => "Biome::Annotation::SimpleValue",
        }
    );

    # $key is a string or a Biome::Role::OntologyTerm compliant object
    print "The type for $key is ",$tm->type_for_key($key),"\n";

    if( !$tm->is_valid($key,$object) ) {
        $self->throw("Invalid object for key $key");
    }

=head1 DESCRIPTION

Manages types for annotation collections.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
 to one of the Bioperl mailing lists.
Your participation is much appreciated.

  bioperl-l@bioperl.org

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and 
reponsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution.
Bug reports can be submitted via the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut

=head2 new

 Title   : new
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

=head2 type_for_key

 Title   : type_for_key
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut
=head2 is_valid

 Title   : is_valid
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

=head2 does_valid

 Title   : does_valid
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

=head2 has_valid

 Title   : has_valid
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

=head2 _add_type_map

 Title   : _add_type_map
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut
