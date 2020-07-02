#!/usr/bin/perl;
#-----------------------------------------------------------------------------
# PACKAGE : Emoticon.pm
# PURPOSE : To encapsulate a emoticon (e.g., :-) and illustrate basic 
#           object-oriented programming with Perl 5.
# AUTHOR  : Steve A. Chervitz (sac@genome.stanford.edu)
# SOURCE  : http://genome-www.stanford.edu/~sac/perlOOP/examples/
# CREATED : 1 July 1997
# MODIFIED: sac --- Mon Dec 15 15:14:15 1997
#  ADAPTED: Wed, 17 May 2000 15:05:34 (Bob Heckel)
#-----------------------------------------------------------------------------

package Emoticon;
####################################
# CLASS CONSTANTS:

my $DEFAULT_FACE  = ':-)';


####################################
# DATA MEMBERS:
# eyes  : single character to represent eyes.
# nose  : single character to represent nose.
# mouth : single character to represent mouth.


####################################
# CONSTRUCTOR:  

sub new {
  my($class,%param) = @_;
  # Create the anonymous hash reference to hold the object's data.
  my $self = {};
  # Initialize the emoticon data members.
  my $face = $param{face} || $DEFAULT_FACE;

  $self->{'eyes'}  = substr($face,0,1);
  $self->{'nose'}  = substr($face,1,1);
  $self->{'mouth'} = substr($face,2,1);

  # Return the hash reference blessed into the current package.
  # Note that this is the single-argument form of bless which does not
  # permit polymorphism.
  return bless $self;  
}


###################################
# ACCESSORS:

# Here we are using combined set/get accessors for all
# data members, since these data are simple.
# The "set" portions of these accessors could do some
# data validation, to prevent bogus emoticons.

sub eyes { 
  my $self = shift; 

  if ( @_ ) {
    $self->{'eyes'} = shift;
  }
  $self->{'eyes'}; 
} 

sub nose { 
  my $self = shift; 

  if(  @_ ) {
   $self->{'nose'} = shift;
  }
  $self->{'nose'}; 
} 

sub mouth { 
  my $self = shift; 

  if ( @_ ) {
   $self->{'mouth'} = shift;
  }
  $self->{'mouth'}; 
} 

# Get the whole emoticon:
sub emote { 
  my($self) = @_;  # we may want to add optional arguments later.
  my $face = "$self->{eyes}$self->{nose}$self->{mouth}"; 

  return $face;
}


###################################
# INSTANCE METHODS:

sub frown {
  my $self = shift;

  $self->{'mouth'} = '(';

  # Return the object reference to permit method chaining as in: 
  # $obj->frown->emote
  return $self;   
}

sub smile {
  my $self = shift;

  $self->{'mouth'} = ')';

  # Return the object reference to permit method chaining as in: 
  # $obj->frown->emote
  return $self;   
}

sub printface { 
  my $self = shift; 
  print $self->emote(@_); # pass any extra arguments to emote().
} 

##########################################
# End of class
# The terminal 1 ensures this package evaluates true by the Perl interpreter.

1;
