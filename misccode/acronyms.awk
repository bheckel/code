#!/bin/sh
##############################################################################
#    Name: acronyms.awk
#
# Adapted: Fri, 18 Feb 2000 15:31:02 (Bob Heckel from Sed & Awk oreilly)
#
# Summary: Accept a text file containing acronyms, process so that acronyms
#          are expanded and abbreviation is parenthesized.
##############################################################################

# awk part fails if acronym is at end of sentence (e.g. and NASA.)
# Catch one or more punctuation char on a line if necessary.
#      =================================---------
sed 's/\([^.,:;!][^.,:;!]*\)\([.,:;!]\)/\1 @@@\2/g' $* |
#       |111111111111111111| |22222222|
#            capture          capture

awk '
# Load acronyms from file into the acro array.
# E.g. NASA    National Aeronautics and Space Administration  <--tabdelimited
FILENAME == "acronyms" {
  #         array
  split($0, entry, "\t")
  # First field (e.g. NASA) is the subscript.
  # I.e. the acronym itself is the index to the description.
  acro[entry[1]] = entry[2]
  next
}

# Process any input line that has at least 2 consecutive caps.
/[A-Z][A-Z]+/ {
  for ( i = 1; i<= NF; i++ ) {
    if ( $i in acro ) {
      $i = acro[$i] " (" $i ")"
      # Only expand the acronym once.
      delete acro[acronym]
    }
  }
}

{
print $0
} ' acronyms - |

# Clean out original sed holding pattern.
sed 's/ @@@\([.,:;!]\)/\1/g' -

