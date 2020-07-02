##############################################################################
#     Name: ParamFile.pm
#
#  Summary: Object class (a.k.a. package) for simple parameter file 
#           maintenance.
#
#  Adapted: Sat 26 Jan 2002 12:17:32 (Bob Heckel -- Mark Hewett lecture)
##############################################################################
package ParamFile;   # create a private namespace
use strict;


# Constructor.  Create new object and load parameter file into memory.
sub new
{
  # E.g. ParamFile is passed implicitly.
  my $type = shift;
  my ($fn) = @_;

  # Create an anonymous hash to store all the properties of this object.  A
  # new anon hash is created each time new() is called.
  my $self = {};

  #        ------>
  bless $self, $type;  # allows you to say $pf->get('ONBOOT')

  # Initialize the object's properties.
  $self->{filename}   = $fn;  # save the original filename.
  $self->{parameters} = {};   # hash that will later store params/values

  # Parse and load file into memory.
  $self->_load or return undef;

  # Return a reference to this instance of the object class.
  return $self;
}


###########
# private:
###########

# Parse and load input file.
sub _load
{
  my $self = shift;
  
  open(PARAMFILE, $self->{filename}) or return undef;

  while ( <PARAMFILE> ) {
    s/#.*$//;   # remove comments
    if ( /(\w+)\s*=\s*(\S*)/ ) {
      # E.g. $self->{parameters}{BOOTPRO}='NO'
      $self->{parameters}{$1} = $2;
      #^^^^^^^^^^^^^^^^^^
      #  ref to a hash
    }
  }

  close(PARAMFILE);

  # Ret num of params found.
  scalar keys %{$self->{parameters}};
}
# So %$self looks like this:
#  %$self
#  |
#  |_filename = ifcfg-eth0
#  |
#  |_parameters = HASH(0x2c81f58)
#    |
#    |_BOOTPRO = static
#    |
#    |_DEVICE = eth0
#    |
#    |_...


##########
# public:
##########

# Modify a parameter value.
sub set
{
  my $self = shift;
  my ($param, $value) = @_;

  $self->{parameters}{$param} = $value;
}
# So $self->{parameters} looks like this:
#  $self->{parameters} = HASH(0x2c81f58)
#  |
#  |_BOOTPRO = static
#  |
#  |_DEVICE = eth0
#  |
#  |_...


# Get the value of a parameter.
sub get
{
  # The object to use is placed into variable $self (it's a reference to a
  # data structure as defined in new()).
  my $self = shift;  
  my ($param) = @_;

  return $self->{parameters}{$param};
}
  

# Get a list of known parameters.
sub paramList
{
  # The object to use is placed into variable $self (it's a reference to a
  # data structure as defined in new()).
  my $self = shift;  

  # Dereference, then ret an array of parameter names.
  return sort keys %{$self->{parameters}};
}
  

# Save modified data back to output file (from memory).
sub save
{
  # The object to use is placed into variable $self (it's a reference to a
  # data structure as defined in new()).
  my $self = shift;  
  my ($fname) = @_;

  # Originally stored during new().
  $fname ||= $self->{filename};
  #                  ^^^^^^^^
  open(PARAMFILE, ">$fname") || die "$0: can't open $fname: $!\n";

  my $rc = 0;
  foreach my $param ( $self->paramList() ) {
    printf PARAMFILE ("%s=%s\n", $param, $self->{parameters}{$param});
    $rc++;
  }

  close(PARAMFILE);

  return $rc;
}
  

=head1 NAME

ParamFile - an object class for simple parameter file maintenance.


=head1 SYNOPSIS

use ParamFile;

 $pf         = ParamFile->new($filename);
 @all_params = $pf->paramList();
 $old_value  = $pf->get($param_name);
 $pf->set($param_name, $new_value);
 $pf->save();


=head1 DESCRIPTION

This module implements an object class that allows for manipulation of data
files such as those usd by RedHat for boot-up parameters.  These files contain
name/value pairs in the following format:

 # comment
 PARAM1 = VALUE1
 PARAM2 = VALUE2
 ...


=head1 METHODS

=head2 new($filename)

Instantiates a ParamFile object based on the contents of B<$filename>.

=head2 paramList

Returns an array of all the parameter names found in the file.

=head2 get($param_name)

Returns the value of the parameter specified by B<$param_name> or undef if no
such parameter exists.

=head2 set($param_name, $new_value)

Changes the value of the parameter specified by B<$param_name> to the value
B<$new_value>.

=head2 save($output_filename)

Writes all parameters and their values back to the file specified by
B<$output_filename>.  If B<$output_filename> is omitted, the original file is
modified.  Note that comments that may have been in the original file are
B<not> preserved.  Returns the number of parameters written or undef on error.


=head1 TODO

Preserve comments during save().

=cut


1;
