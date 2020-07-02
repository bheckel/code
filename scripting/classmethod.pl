#!/usr/bin/perl -w
##############################################################################
#     Name: classmethod.pl
#
#  Summary: Demo of class methods.
#
#  Adapted: Fri 18 May 2001 16:33:33 (Bob Heckel -- Programming Perl v3 p.344)
##############################################################################

##############
package Roach;

our $Population = 0;

sub pop_count { return $Population; }  # capitalize globals

sub DESTROY { $Population-- }

# a.k.a new
sub spawn {
  # a.k.a self
  my $invocant = shift;

  my $class = ref($invocant) || $invocant;
  $Population++;
  print "***population explosion in spawn()***\n";
  sleep 2;

  return bless { name => shift || "anon" }, $class;
}

sub name {
  my $self = shift;

  $self->{name} = shift if @_;

  return $self->{name};
}

#############
package Main;

$foo = spawn Roach;
$one = $foo->name();
print "There's $one\n";

$foo2 = spawn Roach('Clinton');
$two = $foo2->name();
print "and there goes $two\n";

# Class method.
$n = Roach->pop_count();
print "We've got $n roaches.\n";

sleep 2;

$foo->DESTROY();
print "Squash.\n";
$n = Roach->pop_count();
print "Now just $n.\n";

