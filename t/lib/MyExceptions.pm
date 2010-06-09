package MyExceptions;

use strict;
use warnings;
use Moose::Error::Default;

# based completely on Fey's E::C stuff (Fey::Exceptions)
our %E;

BEGIN {
    %E = ( 'MyExceptions' =>
    { description =>
      'Generic exception.  Should only be used as a base class.',
    },

    'MyExceptions::ObjectState' =>
    { description =>
      'Method called on an object which its current state does not allow',
      isa => 'MyExceptions',
      alias => 'object_state_error',
    },

    'MyExceptions::Params' =>
    { description =>
     'An error in the parameters passed in a method of function call',
      isa => 'MyExceptions',
      alias => 'param_error',
    },

    'MyExceptions::VirtualMethod' =>
    { description =>
      'Method called must be subclassed in the appropriate class',
      isa    => 'MyExceptions',
      alias  => 'virtual_method',
    }
);
}

use Exception::Class (%E);

MyExceptions->Trace(1);

use base 'Exporter';

our @EXPORT_OK = map { $_->{alias} || () } values %E;

1;