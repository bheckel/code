#!/usr/bin/perl -w
##############################################################################
#     Name: get_or_set.pl
#
#  Summary: Accessor methods.
#
#  Adapted: Tue 08 May 2001 12:49:13 (Bob Heckel -- Camel v.3 p 332)
##############################################################################

###############
package Testobj;

# Extremely terse constructor.
sub new { bless({}, shift); }

sub get_name {
  my $self = shift;

  return $self->{name};
}

sub set_name {
  my $self = shift;

  $self->{name} = shift;
}


###############
package TestobjImproved;

sub new { bless({}, shift); }

# All in one.
sub namer {
  my $self = shift;

  $self->{name} = shift if @_;

  return $self->{name};
}


###############
package Main;

$obj = new Testobj;

$obj->set_name('bob');
print $obj->get_name();


$obj2 = new TestobjImproved;

$obj2->namer('heck');
print $obj2->namer();

