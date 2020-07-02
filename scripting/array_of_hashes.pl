#!/usr/bin/perl -w
##############################################################################
#     Name: array_of_hashes.pl
#
#  Summary: Demo using an array of hashes data structure.
#
#  Adapted: Thu 11 Dec 2003 11:02:48 (Bob Heckel --
#                            file:///C:/Perl/html/lib/Pod/perldsc.html)
##############################################################################
use Data::Dumper;


########################################
# Load from variable:
#              anonymous hash constructor 
#        _                                     _
@AoH = ( { Lead => 'fred', Friend => 'barney', },
         { Lead => 'george', Wife => 'jane', Son => 'elroy', },
         { Lead => 'homer', Wife => 'marge', Son => 'bart', },
       );
###print Dumper(@AoH);

# Add to it.
$AoH[0]{Pet} = 'dino';
$AoH[2]{Pet} = 'santa helper';

# Pretty useless.
for $href ( @AoH ) {
  for $role ( keys %$href ) {
    print $role, "\n";
  }
}

print "\n";

# Iterate the array of hashes.
for $href ( @AoH ) {
  for $role ( keys %$href ) {
    print $role, ' is named ', $href->{$role}, "\n";
  }
}

print "\n";

########################################
# Load from file:
while ( <DATA> ) {
  # Create an empty (temp) anon hash for each iteration.
  $recref = {};
  for $field ( split ) {
    ($key, $val) = split '=', $field;
    $recref->{$key} = $val;
  }
  push @AoH, $recref;
}

# Iterate the array of hashes.
for $href ( @AoH ) {
  for $role ( keys %$href ) {
    print $role, ' is named ', $href->{$role}, "\n";
  }
}

print "\n";

########################################
# TODO not sure this section is useful
# Load from a function call:
%fields = RetHash();
push @AoH, { %fields };

# Iterate the array of hashes.
for $href ( @AoH ) {
  for $role ( keys %$href ) {
    print $role, ' is named ', $href->{$role}, "\n";
  }
}

sub RetHash {
  return 'bob','heck';
}


__DATA__
LEAD=fred FRIEND=barney
LEAD=george FRIEND=jane SON=elroy
