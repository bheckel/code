#!/usr/bin/perl -w
##############################################################################
#     Name: parse_using_refs.pl
#
#  Summary: Using references to hold read-in data at runtime.  We take one
#           serial format (our __DATA__ section), convert it into an internal
#           Thingy, then dump the Thingy in our own chosen format.
#
#  Adapted: Tue 04 May 2004 12:14:14 (Bob Heckel -- Steve's Place Perl tut 
#                                     Lesson 7)
##############################################################################
use strict;

my $recref;
my @people;
while ( <DATA> ) {
  chomp;
  if ( /\*\*\*/ ) {
    # Start of record marker (see below)
    $recref = {}; # create an empty hashref
  } elsif ( my ($field, $data) = m/ (\w+) \s* = \s* (.*) /x ) {
    if ( $field eq "pets" ) {
      # Create an anonymous arrayref.
      # You can wrap things that return lists in []
      # and create arrayrefs as simply as this.
      $data = [ split /\s*,\s*/, $data ];
    }
    # Add key/value pair to the anonymous hashref $recref
    $recref->{ $field } = $data;
  }
  # End of record marker (see below)
  elsif ( /---/ ) {
    push @people, $recref; # add the hashref to the @people array
  } else {
    next;
  }
}

# We have now created a tree in memory, looking something like...
# @people = (
#    { name=>'andy', age=>37, pets=>[ ] }, 
#    { name=>'alex', age=>23, pets=>[ 'dog' ] },
#    { name=>'steve',age=>26, pets=>[ 'millipede', 'snake' ] },
# );
# I.e. a normal array of anonymous hashes using normal scalars as their keys
# and anonymous arrays as their values.

for my $person ( @people ) {
  print ucfirst "$person->{name} is $person->{age} years old ";
  # Assignment is neatest here, as we use @pets in a minute.
  if ( my @tmppets = @{ $person->{pets} } ) {
    # $" is a special perl variable, containing the thing used to separate
    # array elements in quoted strings.  Usually it's a space, but we make it
    # a comma and space for our output here.
    local $" = ', ';
    print "and has the following pets: @tmppets.\n";
  } else {
    print "and has no pets.\n";
  }
}

# Everything after the __DATA__ token is available to a perl script and
# can be read automagically via the DATA filehandle
__DATA__
***
name = andy
age = 37
pets =
---
***
name = alex
age = 23
pets = dog
---
***
name = steve
age = 26
pets = millipede, snake
---
