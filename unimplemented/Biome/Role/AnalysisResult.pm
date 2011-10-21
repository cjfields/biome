package Biome::Role::AnalysisResult;

use Biome::Role;



=head2 analysis_query

 Usage     : $query_obj = $result->analysis_query();
 Purpose   : Get a Bio::PrimarySeqI-compatible object representing the entity
             on which the analysis was performed. Lacks sequence information.
 Argument  : n/a
 Returns   : A Bio::PrimarySeqI-compatible object without sequence information.
             The sequence will have display_id, description, moltype, and length data.

=cut

requires 'analysis_query';


=head2 analysis_subject

 Usage     : $obj = $result->analyis_subject();
 Purpose   : Get the subject of the analysis against which it was
             performed. For similarity searches it will probably be a database,
             and for sequence feature predictions (exons, promoters, etc) it
             may be a collection of models or homologous sequences that were
             used, or undefined.
 Returns   : An object of a type the depends on the implementation
             May also return undef for analyses that don\'t involve subjects.
 Argument  : n/a
 Comments  : Implementation of this method is optional.
             AnalysisResultI provides a default behavior of returning undef.

=cut

requires 'analysis_subject';


=head2 analysis_subject_version

 Usage     : $vers = $result->analyis_subject_version();
 Purpose   : Get the version string of the subject of the analysis.
 Returns   : String or undef for analyses that don\'t involve subjects.
 Argument  : n/a
 Comments  : Implementation of this method is optional.
             AnalysisResultI provides a default behavior of returning undef.

=cut

sub analysis_subject_version {
#---------------
    my ($self) = @_;
    return;
}

=head2 analysis_date

 Usage     : $date = $result->analysis_date();
 Purpose   : Get the date on which the analysis was performed.
 Returns   : String
 Argument  : n/a

=cut

sub analysis_date {
#---------------------
    my ($self) = @_;
    $self->throw_not_implemented;
}

=head2 analysis_method

 Usage     : $meth = $result->analysis_method();
 Purpose   : Get the name of the sequence analysis method that was used
             to produce this result (BLASTP, FASTA, etc.). May also be the
             actual name of a program.
 Returns   : String
 Argument  : n/a

=cut

sub analysis_method {
#-------------
    my ($self) = @_;
    $self->throw_not_implemented;
}

=head2 analysis_method_version

 Usage     : $vers = $result->analysis_method_version();
 Purpose   : Get the version string of the analysis program.
           : (e.g., 1.4.9MP, 2.0a19MP-WashU).
 Returns   : String
 Argument  : n/a

=cut

sub analysis_method_version {
#---------------------
    my ($self) = @_;
    $self->throw_not_implemented;
}

=head2 next_feature

 Title   : next_feature
 Usage   : $seqfeature = $obj->next_feature();
 Function: Returns the next feature available in the analysis result, or
           undef if there are no more features.
 Example :
 Returns : A Bio::SeqFeatureI implementing object, or undef if there are no
           more features.
 Args    : none

=cut

sub next_feature {
#---------------------
    my ($self);
    $self->throw_not_implemented;
}

no Biome::Role;
1;
