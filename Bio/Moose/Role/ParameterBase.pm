package Bio::Moose::Root::ParameterBase;

use Bio::Moose::Role;


=head2 set_parameters

 Title   : set_parameters
 Usage   : $pobj->set_parameters(%params);
 Function: sets the parameters listed in the hash or array
 Returns : None
 Args    : [optional] hash or array of parameter/values.  

=cut

requires 'set_parameters';

=head2 reset_parameters

 Title   : reset_parameters
 Usage   : resets values
 Function: resets parameters to either undef or value in passed hash
 Returns : none
 Args    : [optional] hash of parameter-value pairs

=cut

requires 'reset_parameters';

=head2 parameters_changed

 Title   : parameters_changed
 Usage   : if ($pobj->parameters_changed) {...}
 Function: Returns boolean true (1) if parameters have changed
 Returns : Boolean (0 or 1)
 Args    : [optional] Boolean

=cut

requires 'parameters_changed';

=head2 available_parameters

 Title   : available_parameters
 Usage   : @params = $pobj->available_parameters()
 Function: Returns a list of the available parameters
 Returns : Array of parameters
 Args    : [optional, implementation-dependent] string for returning subset of
           parameters

=cut

requires 'available_parameters';

=head2 get_parameters

 Title   : get_parameters
 Usage   : %params = $pobj->get_parameters;
 Function: Returns list of key-value pairs of parameter => value
 Returns : List of key-value pairs
 Args    : [optional] A string is allowed if subsets are wanted or (if a
           parameter subset is default) 'all' to return all parameters

=cut

requires 'get_parameters';

no Bio::Moose::Role;
1;
