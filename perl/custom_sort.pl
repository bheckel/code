#!/usr/bin/perl -w
##############################################################################
#     Name: custom_sort.pl
#
#  Summary: Custom sort block.
#
#  Created: Tue 29 Apr 2003 13:40:23 (Bob Heckel)
##############################################################################

my $hr = {
  country => [ 'Country', 'United States' ],
  state   => [ 'State', 'North Carolina' ],
  county  => [ 'County', 'Wake' ],
  place   => [ 'Place', 'Raleigh' ],
};

@x = sort { CustomSort() } (keys %$hr);
print "@x";

# Want:
# Country
# State
# County
# Place
# TODO not working and giving errors
sub CustomSort {
  if ( $a == 'State' and $b == 'Country' ) {
    return $a < $b;
  }
  elsif ( $a == 'State' and $b == 'County' ) {
    return $a < $b;
  } 
  elsif ( $a == 'County' and $b == 'Place' ) {
    return $a < $b;
  } 
  else {
    return $a > $b;
  }
}
