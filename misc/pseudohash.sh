#! /bin/bash -x
##############################################################################
#     Name: pseudohash.sh
#
#  Summary: Demo of how to create and use pseudo hashes in shell.
#
#           Usage:
#           $ pseudohash.sh DimGrey
#
#  Adapted: Fri 03 Aug 2001 09:27:56 (Bob Heckel -- UGU tips)
# Modified: Thu 02 Apr 2009 09:28:18 (Bob Heckel)
##############################################################################

DarkSlateGrey="#2f4f4f"
DimGrey="#696969"
Wheat="#706969"

#                Evaluates to DimGrey 
#                    ___________
BGColor=`eval echo "$"$(echo $1)""`
# Then `eval echo "$DimGrey"` evaluates to #696969

echo "$BGColor is the value of key $1"



# Loop the hash:
DarkSlateGrey="#2f4f4f"
DimGrey="#696969"
Wheat="#706969"

for x in DarkSlateGrey Wheat; do
  BGColor=`eval echo "$"$(echo $x)""`
  echo "$BGColor is the value of key $x"
done;
