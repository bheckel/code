#!/bin/sh
##############################################################################
#     Name: hash-like.sh
#
#  Summary: Demo of using hash-like constructions to parse parameters from the
#           command line.
#
#           Each list element may contain multiple parameters. This is useful
#           when processing parameters in groups. In such cases, use the set
#           command to force parsing of each list element and assignment 
#           of each component to the positional parameters.
#
#           Perl or pseudohash.sh might be a better solution.
#
#  Adapted: Mon 10 Sep 2001 13:47:40 (Bob Heckel)
# Modified: Thu 22 Sep 2005 14:57:57 (Bob Heckel)
##############################################################################

# Associate the name of each planet with its distance from the sun.

for planet in "Mercury 36 1" "Venus 67 2" "Earth 93 3"  "Mars 142 4" \
              "Jupiter 483 5"
do
  # parses variable "planet" and sets positional parameters (the "--" prevents
  # nasty surprises if $planet is null or begins with a dash).
  set -- $planet

  # May need to save original positional parameters, since they get overwritten.
  # One way of doing this is to use an array,
  #   original_params=("$@")

  echo "$1		$2,000,000 miles from the sun $3"
done

exit 0
