#!/usr/bin/perl -w
##############################################################################
#    Name: oop.pl
#
# Summary: Object creation and manipulation.
#          TODO why no new constructor??
#
# Adapted: Tue, 23 Jan 2001 12:58:32 (Bob Heckel -- from Perl of Wisdom, An
#                                     Object Lesson in Perl, Randal Schwartz)
##############################################################################

use strict 'norefs';
###use strict;
# Avoid strict errors (strict will complain b/c @ISA is not a vari containing
# an explicit pkg name, nor is it a lexical "my" vari).
use vars '@ISA';

# Want to factor out the commonality.  E.g. can change 'goes' to 'says' easily
# in the future.
###package Cow;
###sub speak {
###  print "a Cow goes moooo!\n";
###}
###package Horse;
###sub speak {
###  print "a Horse goes neigh!\n";
###}

###########
package Animal;

# Generic, so sub belongs in Animal.
sub name {
  my $self = shift;

  # Expecting a scalar.
  #                    if it's a class, return generic
  ###ref $self ? $$self : "an unnamed $self"; 
  # ref() rets the classname's string when used on a blessed ref, undef
  # when used on a string (like a classname).
  # No longer expecting only a scalar.  Can build more than a scalar sheep.
  ref $self ? $self->{Llamo} : "an unnamed $self";
}

# Generic, so sub belongs in Animal.
# Build new instance.
sub named {
  # E.g. Horse
  my $class = shift;
  # E.g. Mr. Ed
  my $name  = shift;

  # Expecting a scalar.
  ###bless \$name, $class;
  # No longer expecting a scalar.
  my $self = { Llamo => $name, Color => $class->default_color };
  bless $self, $class;
}

sub speak {
  my $class = shift;
  
  # a Horse=SCALAR(0xaca42ac) says neigh!
  #           ______ expecting a class name, not an instance (i.e. a ref)
  ###print "A $class says ", $class->sound, "!\n";
  print $class->name, " says ", $class->sound, "!\n";
}

sub eat {
  my $class = shift;
  my $food  = shift;

  print $class->name, " eats $food\n";
}

# The default default for Cow, Mouse, Horse.
sub default_color { "browndefault" };

sub color { $_[0]->{Color} };

sub set_color { $_[0]->{Color} = $_[1] };
# END package Animal


###########
package Cow;
# Perl looks in @ISA after failing to find Cow->speak() (aka Cow::speak).
@ISA = 'Animal';

# But Perl won't need to look in @ISA when Cow->sound() is called.
sub sound { return 'mooooo' };    # Helper method for speak(), provides
                                  # constant text.


###########
package Mouse;
@ISA = 'Animal';
sub sound { return "squeeeek" };

# OVERRIDE Animal::sound
###sub speak {
###  my $class = shift;
###  print "A $class goes ", $class->sound, "!\n";
###  print "\tbut you can hardly hear it\n";
###}
# Want to share this definition of speak among all animals, only diff between
# animals is the name of the pkg and the specific sound.  So use INHERITANCE.
sub speak {
  my $class = shift;
  # Error -- Can't locate object method "sound" via package "Animal" at...
  ###Animal->speak();
  # Too clunky.  And hardcoded Animal is a maintenance problem.
  ###Animal::speak($class);
  # Better -- Start w/ Animal to find speak() and use all of Animal's
  # inheritance chain if it's not found immediately.  But still maintenance
  # problem (and don't know while animal in @ISA actually defined speak()).
  ###$class->Animal::speak;
  # Best -- Search all superclasses in the inheritance chain.
  # Look in the current package's @ISA for speak, invoking the first one
  # found.
  $class->SUPER::speak;
  print "\tbut you can hardly hear it.\n";
}
# END package Mouse


###########
package Horse;
@ISA = 'Animal';

sub sound {'neigh'}

###sub name {
###   my $self = shift;
###   $$self;
###}

# Better.
###sub name {
###  my $self = shift;
###
###  #                    If it's a class, return generic
###  ref $self ? $$self : "an unnamed $self"; 
###}
###

# Better here than in Main.
###sub named {
###   my $class = shift;
###   my $name = shift;
###   # Return the reference to $name.
###   bless \$name, $class;
###}
# But there's nothing specific to Horses in this method (or sub name), so move
# it (and sub name) to Animal's pkg.

###########
package Sheep;
# Object method "name" can't be located in this pkg, so look in pkg Animal.
@ISA = "Animal";

sub sound { 'baaaah!'};

sub default_color { 'white' };


###########
package Main;

my @pasture = qw(Cow Cow Mouse Sheep Horse Cow);
foreach my $creature ( @pasture ) {
  # Symbolic coderef de-referencing.  Unfortunately, we can't 'use strict
  # refs' or employ a variable package name...
  ###&{$creature . "::speak"};
  # ...but this can.      Gets class name as the 1st param.
  $creature->speak();   # Same as e.g. Cow::speak('Cow');
}
@pasture = undef;
print "=========\n";

# Objects "live" in a class, meaning that they belong to some package.
# They "know" which class they belong to, and how to behave.
# Asking a _class_ to do something for you (e.g. "give me an object") is
# calling a class method.
# Asking an _object_ to do something for you (e.g. "speak") is calling an
# object method.
#
# Specific horse.
###my $name = 'Mr. Ed';
###my $talking = \$name;
# Turn scalar reference into an INSTANCE.  Information about the pkg named
# Horse is stored in the thing pointed at by the reference $talking.
# So, a blessed reference is an instance.
#    -----------------------------------------------------
#    | The only difference between a class method and an |
#    | instance method is that the first parameter will  |
#    | be a class name (a string) or an instance         |
#    | (blessed reference) respectively                  |
#    -----------------------------------------------------
# This s/b performed inside Horse, not out in the open (Main).
# Sole purpose of bless -- enable $talking to be used as an object.
###bless $talking, Horse;
# Voila!  Methods may now be called against $talking.
###print $talking->name, ' says ', $talking->sound, ".\n";
# Better ---
# Create an INSTANCE called $talking.
my $talking = Horse->named("mr ed");
# Since it was blessed earlier, Perl knows to look in the class Horse to find
# the sub to invoke the method sound().  Doesn't need to use inheritance in
# this case.  Effectively, this is what is invoked:  Horse::sound($talking)
print '1 ', $talking->sound(), "\n";
# Does need inheritance in this case.
print '2 ', $talking->name(), "\n";
$talking->speak();
###Animal::eat($talking, "bits");
# Better.
$talking->eat("bits");
$talking->set_color("blakwhit");
print '5 ', $talking->name, " is colored ", $talking->color, "\n";

# A horse with no name again.
print '6 ', Horse->name, "\n";
# A horse with no name, eating.
Horse->eat("grass");
print "\n";

# Specific sheep.  This instance requires more info than just name, as in
# Horse instances.
#               -------member (instance) variables-------
my $bad = bless { Llamo => 'Evilsheep', Color => 'black' }, Sheep;
print '8 ', $bad->name, " is colored ", $bad->color, "\n";
$bad->speak();

# Unnamed sheep.
print '10 ', Sheep->name, "\n";
Animal::eat($bad, "bytes");
# Better.
Sheep->eat("grass");
print "\n";
# END package Main
