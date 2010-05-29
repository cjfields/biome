package Biome::Role::Analysis;

use Biome::Role;

=head2 analysis_name

 Usage   : $tool->analysis_name;
 Returns : a name of this analysis
 Args    : none

=cut

requires 'analysis_name';

=head2 analysis_spec

 Usage   : $tool->analysis_spec;
 Returns : a hash reference describing this analysis
 Args    : none

The returned hash reference uses the following keys (not all of them always
present, perhaps others present as well): C<name>, C<type>, C<version>,
C<supplier>, C<installation>, C<description>.

Here is an example output:

  Analysis 'edit.seqret':
        installation => EMBL-EBI
        description => Reads and writes (returns) sequences
        supplier => EMBOSS
        version => 2.6.0
        type => edit
        name => seqret

=cut

requires 'analysis_spec';

=head2 describe

 Usage   : $tool->analysis_spec;
 Returns : an XML detailed description of this analysis
 Args    : none

The returned XML string contains metadata describing this analysis
service. It includes also metadata returned (and easier used) by
method C<analysis_spec>, C<input_spec> and C<result_spec>.

The DTD used for returned metadata is based on the adopted standard
(BSA specification for analysis engine):

  <!ELEMENT DsLSRAnalysis (analysis)+>

  <!ELEMENT analysis (description?, input*, output*, extension?)>

  <!ATTLIST analysis
      type          CDATA #REQUIRED
      name          CDATA #IMPLIED
      version       CDATA #IMPLIED
      supplier      CDATA #IMPLIED
      installation  CDATA #IMPLIED>

  <!ELEMENT description ANY>
  <!ELEMENT extension ANY>

  <!ELEMENT input (default?, allowed*, extension?)>

  <!ATTLIST input
      type          CDATA #REQUIRED
      name          CDATA #REQUIRED
      mandatory     (true|false) "false">

  <!ELEMENT default (#PCDATA)>
  <!ELEMENT allowed (#PCDATA)>

  <!ELEMENT output (extension?)>

  <!ATTLIST output
      type          CDATA #REQUIRED
      name          CDATA #REQUIRED>

But the DTD may be extended by provider-specific metadata. For
example, the EBI experimental SOAP-based service on top of EMBOSS uses
DTD explained at C<http://www.ebi.ac.uk/~senger/applab>.

=cut

requires 'describe';

=head2 input_spec

 Usage   : $tool->input_spec;
 Returns : an array reference with hashes as elements
 Args    : none

The analysis input data are named, and can be also associated with a
default value, with allowed values and with few other attributes. The
names are important for feeding the service with the input data (the
inputs are given to methods C<create_job>, C<run>, and/or C<wait_for>
as name/value pairs).

Here is a (slightly shortened) example of an input specification:

 $input_spec = [
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'sequence_usa'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'sequence_direct_data'
          },
          {
            'mandatory' => 'false',
            'allowed_values' => [
                                  'gcg',
                                  'gcg8',
                                  ...
                                  'raw'
                                ],
            'type' => 'String',
            'name' => 'sformat'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'sbegin'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'send'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'sprotein'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'snucleotide'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'sreverse'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'slower'
          },
          {
            'mandatory' => 'false',
            'type' => 'String',
            'name' => 'supper'
          },
          {
            'mandatory' => 'false',
            'default' => 'false',
            'type' => 'String',
            'name' => 'firstonly'
          },
          {
            'mandatory' => 'false',
            'default' => 'fasta',
            'allowed_values' => [
                                  'gcg',
                                  'gcg8',
                                  'embl',
                                  ...
                                  'raw'
                                ],
            'type' => 'String',
            'name' => 'osformat'
          }
        ];

=cut

requires 'input_spec';

=head2 result_spec

 Usage   : $tool->result_spec;
 Returns : a hash reference with result names as keys
           and result types as values
 Args    : none

The analysis results are named and can be retrieved using their names
by methods C<results> and C<result>.

Here is an example of the result specification (again for the service
I<edit.seqret>):

  $result_spec = {
          'outseq' => 'String',
          'report' => 'String',
          'detailed_status' => 'String'
        };

=cut

requires 'result_spec';

=head2 create_job

 Usage   : $tool->create_job ( {'sequence'=>'tatat'} )
 Returns : Bio::Tools::Run::Analysis::Job
 Args    : data and parameters for this execution
           (in various formats)

Create an object representing a single execution of this analysis
tool.

Call this method if you wish to "stage the scene" - to create a job
with all input data but without actually running it. This method is
called automatically from other methods (C<run> and C<wait_for>) so
usually you do not need to call it directly.

The input data and prameters for this execution can be specified in
various ways:

=over

=item array reference

The array has scalar elements of the form

   name = [[@]value]

where C<name> is the name of an input data or input parameter (see
method C<input_spec> for finding what names are recognized by this
analysis) and C<value> is a value for this data/parameter. If C<value>
is missing a 1 is assumed (which is convenient for the boolean
options). If C<value> starts with C<@> it is treated as a local
filename, and its contents is used as the data/parameter value.

=item hash reference

The same as with the array reference but now there is no need to use
an equal sign. The hash keys are input names and hash values their
data. The values can again start with a C<@> sign indicating a local
filename.

=item scalar

In this case, the parameter represents a job ID obtained in some
previous invocation - such job already exists on the server side, and
we are just re-creating it here using the same job ID.

I<TBD: here we should allow the same by using a reference to the
Bio::Tools::Run::Analysis::Job object.>

=item undef

Finally, if the parameter is undefined, ask server to create an empty
job. The input data may be added later using C<set_data...>
method(s) - see scripts/papplmaker.PLS for details.

=back

=cut

requies 'create_job';

=head2 run

 Usage   : $tool->run ( ['sequence=@my.seq', 'osformat=embl'] )
 Returns : Bio::Tools::Run::Analysis::Job,
           representing started job (an execution)
 Args    : the same as for create_job

Create a job and start it, but do not wait for its completion.

=cut

requires 'run';

=head2 wait_for

 Usage   : $tool->wait_for ( { 'sequence' => '@my,file' } )
 Returns : Bio::Tools::Run::Analysis::Job,
           representing finished job
 Args    : the same as for create_job

Create a job, start it and wait for its completion.

Note that this is a blocking method. It returns only after the
executed job finishes, either normally or by an error.

Usually, after this call, you ask for results of the finished job:

    $analysis->wait_for (...)->results;

=cut

requires 'wait_for';

no Biome::Role;


package BioMe::Role::Analysis::Job;

use Biome::Role;


=head2 id

 Usage   : $job->id;
 Returns : this job ID
 Args    : none

Each job (an execution) is identifiable by this unique ID which can be
used later to re-create the same job (in other words: to re-connect to
the same job). It is useful in cases when a job takes long time to
finish and your client program does not want to wait for it within the
same session.

=cut

requires 'id';

=head2 run

 Usage   : $job->run
 Returns : itself
 Args    : none

It starts previously created job.  The job already must have all input
data filled-in. This differs from the method of the same name of the
C<Bio::Tools::Run::Analysis> object where the C<run> method creates
also a new job allowing to set input data.

=cut

requires 'run';

=head2 wait_for

 Usage   : $job->wait_for
 Returns : itself
 Args    : none

It waits until a previously started execution of this job finishes.

=cut

requires 'wait_for';

=head2 terminate

 Usage   : $job->terminate
 Returns : itself
 Args    : none

Stop the currently running job (represented by this object). This is a
definitive stop, there is no way to resume it later.

=cut


requires 'terminate';

=head2 last_event

 Usage   : $job->last_event
 Returns : an XML string
 Args    : none

It returns a short XML document showing what happened last with this
job. This is the used DTD:

   <!-- place for extensions -->
   <!ENTITY % event_body_template "(state_changed | heartbeat_progress | percent_progress | time_progress | step_progress)">

   <!ELEMENT analysis_event (message?, (%event_body_template;)?)>

   <!ATTLIST analysis_event
       timestamp  CDATA #IMPLIED>

   <!ELEMENT message (#PCDATA)>

   <!ELEMENT state_changed EMPTY>
   <!ENTITY % analysis_state "created | running | completed | terminated_by_request | terminated_by_error">
   <!ATTLIST state_changed
       previous_state  (%analysis_state;) "created"
       new_state       (%analysis_state;) "created">

   <!ELEMENT heartbeat_progress EMPTY>

   <!ELEMENT percent_progress EMPTY>
   <!ATTLIST percent_progress
       percentage CDATA #REQUIRED>

   <!ELEMENT time_progress EMPTY>
   <!ATTLIST time_progress
       remaining CDATA #REQUIRED>

   <!ELEMENT step_progress EMPTY>
   <!ATTLIST step_progress
       total_steps      CDATA #IMPLIED
       steps_completed CDATA #REQUIRED>

Here is an example what is returned after a job was created and
started, but before it finishes (note that the example uses an
analysis 'showdb' which does not need any input data):

   use Bio::Tools::Run::Analysis;
   print new Bio::Tools::Run::Analysis (-name => 'display.showdb')
             ->run
	     ->last_event;

It prints:

   <?xml version = "1.0"?>
   <analysis_event>
     <message>Mar 3, 2003 5:14:46 PM (Europe/London)</message>
     <state_changed previous_state="created" new_state="running"/>
   </analysis_event>

The same example but now after it finishes:

   use Bio::Tools::Run::Analysis;
   print new Bio::Tools::Run::Analysis (-name => 'display.showdb')
             ->wait_for
	     ->last_event;

   <?xml version = "1.0"?>
   <analysis_event>
     <message>Mar 3, 2003 5:17:14 PM (Europe/London)</message>
     <state_changed previous_state="running" new_state="completed"/>
   </analysis_event>

=cut

reqiures 'last_event';

=head2 status

 Usage   : $job->status
 Returns : string describing the job status
 Args    : none

It returns one of the following strings (and perhaps more if a server
implementation extended possible job states):

   CREATED
   RUNNING
   COMPLETED
   TERMINATED_BY_REQUEST
   TERMINATED_BY_ERROR

=cut

requires 'status';

=head2 created

 Usage   : $job->created (1)
 Returns : time when this job was created
 Args    : optional

Without any argument it returns a time of creation of this job in
seconds, counting from the beginning of the UNIX epoch
(1.1.1970). With a true argument it returns a formatted time, using
rules described in C<Bio::Tools::Run::Analysis::Utils::format_time>.

=cut

requires 'created';

=head2 started

 Usage   : $job->started (1)
 Returns : time when this job was started
 Args    : optional

See C<created>.

=cut

requires 'started';

=head2 ended

 Usage   : $job->ended (1)
 Returns : time when this job was terminated
 Args    : optional

See C<created>.

=cut

requries 'ended';

=head2 elapsed

 Usage   : $job->elapsed
 Returns : elapsed time of the execution of the given job
           (in milliseconds), or 0 of job was not yet started
 Args    : none

Note that some server implementations cannot count in millisecond - so
the returned time may be rounded to seconds.

=cut

requries 'elapsed';

=head2 times

 Usage   : $job->times ('formatted')
 Returns : a hash refrence with all time characteristics
 Args    : optional

It is a convenient method returning a hash reference with the folowing
keys:

   created
   started
   ended
   elapsed

See C<create> for remarks on time formating.

An example - both for unformatted and formatted times:

   use Data::Dumper;
   use Bio::Tools::Run::Analysis;
   my $rh = Bio::Tools::Run::Analysis->new(-name => 'nucleic_cpg_islands.cpgplot')
             ->wait_for ( { 'sequence_usa' => 'embl:hsu52852' } )
	     ->times (1);
   print Data::Dumper->Dump ( [$rh], ['Times']);
   $rh = Bio::Tools::Run::Analysis->new(-name => 'nucleic_cpg_islands.cpgplot')
             ->wait_for ( { 'sequence_usa' => 'embl:AL499624' } )
	     ->times;
   print Data::Dumper->Dump ( [$rh], ['Times']);

   $Times = {
           'ended'   => 'Mon Mar  3 17:52:06 2003',
           'started' => 'Mon Mar  3 17:52:05 2003',
           'elapsed' => '1000',
           'created' => 'Mon Mar  3 17:52:05 2003'
         };
   $Times = {
           'ended'   => '1046713961',
           'started' => '1046713926',
           'elapsed' => '35000',
           'created' => '1046713926'
         };

=cut

requires 'times';

=head2 results

 Usage   : $job->results (...)
 Returns : one or more results created by this job
 Args    : various, see belou

This is a complex method trying to make sense for all kinds of
results. Especially it tries to help to put binary results (such as
images) into local files. Generally it deals with fhe following facts:

=over

=item *

Each analysis tool may produce more results.

=item *

Some results may contain binary data not suitable for printing into a
terminal window.

=item *

Some results may be split into variable number of parts (this is
mainly true for the image results that can consist of more *.png
files).

=back

Note also that results have names to distinguish if there are more of
them. The names can be obtained by method C<result_spec>.

Here are the rules how the method works:

    Retrieving NAMED results:
    -------------------------
     results ('name1', ...)   => return results as they are, no storing into files

     results ( { 'name1' => 'filename', ... } )  => store into 'filename', return 'filename'
     results ( 'name1=filename', ...)            => ditto

     results ( { 'name1' => '-', ... } )         => send result to the STDOUT, do not return anything
     results ( 'name1=-', ...)                   => ditto

     results ( { 'name1' => '@', ... } )  => store into file whose name is invented by
                                             this method, perhaps using RESULT_NAME_TEMPLATE env
     results ( 'name1=@', ...)            => ditto

     results ( { 'name1' => '?', ... } )  => find of what type is this result and then use
                                             {'name1'=>'@' for binary files, and a regular
                                             return for non-binary files
     results ( 'name=?', ...)             => ditto

    Retrieving ALL results:
    -----------------------
     results()     => return all results as they are, no storing into files

     results ('@') => return all results, as if each of them given
                      as {'name' => '@'} (see above)

     results ('?') => return all results, as if each of them given
                      as {'name' => '?'} (see above)

    Misc:
    -----
     * any result can be returned as a scalar value, or as an array reference
       (the latter is used for results consisting of more parts, such images);
       this applies regardless whether the returned result is the result itself
       or a filename created for the result

     * look in the documentation of the C<panalysis[.PLS]> script for examples
       (especially how to use various templates for inventing file names)

=cut

requires 'results';

=head2 result

 Usage   : $job->result (...)
 Returns : the first result
 Args    : see 'results'

=cut

requries 'result';

=head2 remove

 Usage   : $job->remove
 Returns : 1
 Args    : none

The job object is not actually removed in this time but it is marked
(setting 1 to C<_destroy_on_exit> attribute) as ready for deletion when
the client program ends (including a request to server to forget the job
mirror object on the server side).

=cut

requires 'remove';

no Biome::Role;
1;

1;
