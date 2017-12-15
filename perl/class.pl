#!/usr/bin/perl -w
##############################################################################
#    Name: class.pl
#
# Summary: Simple demo of creating and using a class.
#
#           Class  -- package that provides methods.
#           Object -- a reference
#           Method -- subroutine w/ the first arg as the name of the class
#
# Created: Thu 01 Mar 2001 13:10:30 (Bob Heckel)
# Modified: Fri 07 May 2004 17:16:23 (Bob Heckel -- Steve's Place Perl tut
#                                     lesson 8)
##############################################################################

use Demo;
use Data::Dumper;

%h = (name=>'bob', phone=>'555-1212', fax=>'none', email=>'emailcom');

$object = Demo->new(%h);

# Use big shiny buttons to control the opaque object.  Arrow is NOT for
# dereferencing:
# $thing->{key};                <---hashref dereference, note the {}
# $thing->[index];              <---arrayref dereference, note the []
# $thing->(args);               <---coderef dereference, note the ()
# $thing->method(optionalargs); <---method call on object $thing
$object->printme();

$object->set_fax('sux');
$object->set_phone(555-1334);
$object->printme();

print "\n", Dumper($object);


__END__
Assumes ~/perllib/Demo.pm exists.

##############################################################################
#    Name: Demo.pm
#
# Summary: Simple demo of creating and using a class.
#
# Created: Thu 01 Mar 2001 13:10:30 (Bob Heckel)
# Modified: Fri 07 May 2004 17:06:21 (Bob Heckel)
##############################################################################
package Demo;

sub new {
  my ($class, %init) = @_;

  # Could have put this anon hashref into $self.
  bless	{
          name	=> $init{name},
          phone	=> $init{phone},
          fax	=> $init{fax},
        }, $class;
}

sub get_name { $_[0]->{name} }

sub get_phone { $_[0]->{phone} }
sub set_phone { $_[0]->{phone} = $_[1] }

sub get_fax	{ $_[0]->{fax} }
sub set_fax { $_[0]->{fax} = $_[1] }

sub printme {
  my ($self) = @_;

  print $self->get_name(), ":\n";
  print "\tPhone:  ", $self->get_phone(), "\n";
  print "\tFax:    ", $self->get_fax(), "\n";
}


1;
