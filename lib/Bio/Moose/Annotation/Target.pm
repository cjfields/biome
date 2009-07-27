# Let the code begin...

package Bio::Annotation::Target;

use Bio::Moose;

# possibly make this another role, seeing as it's used three times
#extends 'Bio::Annotation::DBLink';

with qw(Bio::Moose::Role::Annotate
        Bio::Moose::Role::DBLink
        Bio::Moose::Role::Identify
        Bio::Moose::Role::Range);

has '+DEFAULT_CB' => (
    default => sub {sub { $_[0]->as_text || ''}},
    lazy    => 1
    );

has target_id => (
    is          => 'rw',
    isa         => 'Str',
    default     => sub {$_->primary_id},
    lazy        => 1
);

sub as_text {
  my ($self) = @_;

  my $target = $self->target_id || '';
  my $start  = $self->start     || '';
  my $end    = $self->end       || '';
  my $strand = $self->strand    || '';

   return "Target=".$target." ".$start." ".$end." ".$strand;
}

sub hash_tree {
    my ($self) = @_;
    
    my $h = {};
    $h->{'database'}   = $self->database;
    $h->{'primary_id'} = $self->primary_id;
    if( defined $self->optional_id ) {
        $h->{'optional_id'} = $self->optional_id;
    }
    if( defined $self->comment ) {
        # we know that comments have hash_tree methods
        $h->{'comment'} = $self->comment;
    }
 
    return $h;
}

no Bio::Moose;

__PACKAGE__->meta->make_immutable();

1;

__END__

# $Id: Target.pm 15549 2009-02-21 00:48:48Z maj $
#
# BioPerl module for Bio::Annotation::Target
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Scott Cain <cain@cshl.org>
#
# Copyright Scott Cain
#
# Based on the Bio::Annotation::DBLink by Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::Annotation::Target - Provides an object which represents a target (ie, a
similarity hit) from one object to something in another database

=head1 SYNOPSIS

   $target1 = Bio::Annotation::Target->new(-target_id  => 'F321966.1',
                                          -start      => 1,
                                          -end        => 200,
                                          -strand     => 1,   # or -1
                                         );

   # or

   $target2 = Bio::Annotation::Target->new();
   $target2->target_id('Q75IM5');
   $target2->start(7);
   # ... etc ...

   # Target is-a Bio::AnnotationI object, can be added to annotation
   # collections, e.g. the one on features or seqs
   $feat->annotation->add_Annotation('Target', $target2);


=head1 DESCRIPTION

Provides an object which represents a target (ie, a similarity hit) from
one object to something in another database without prescribing what is
in the other database

=head1 AUTHOR - Scott Cain

Scott Cain - cain@cshl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

=head1 AnnotationI implementing functions

=cut


=head2 as_text

 Title   : as_text
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

=head2 display_text

 Title   : display_text
 Usage   : my $str = $ann->display_text();
 Function: returns a string. Unlike as_text(), this method returns a string
           formatted as would be expected for te specific implementation.

           One can pass a callback as an argument which allows custom text
           generation; the callback is passed the current instance and any text
           returned
 Example :
 Returns : a string
 Args    : [optional] callback

=cut

=head2 tagname

 Title   : tagname
 Usage   : $obj->tagname($newval)
 Function: Get/set the tagname for this annotation value.

           Setting this is optional. If set, it obviates the need to
           provide a tag to Bio::AnnotationCollectionI when adding
           this object. When obtaining an AnnotationI object from the
           collection, the collection will set the value to the tag
           under which it was stored unless the object has a tag
           stored already.

 Example :
 Returns : value of tagname (a scalar)
 Args    : new value (a scalar, optional)


=cut

=head1 Specific accessors for Targets

=cut

=head2 target_id

=over

=item Usage

  $obj->target_id()        #get existing value
  $obj->target_id($newval) #set new value

=item Function

=item Returns

value of target_id (a scalar)

=item Arguments

new value of target_id (to set)

=back

=cut