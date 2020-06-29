#!/bin/sh
##############################################################################
#     Name: wildcard_using_case.sh
#
#  Summary: Get around shell limitation of not being able to use wildcards 
#           in an if statement.
#
#  Created: Sun 23 Mar 2003 09:01:17 (Bob Heckel)
##############################################################################
  
###TYPE=CYGWINa
TYPE=CYGWINbob

# Can't use if [ $TYPE = CYGWIN* ]; then ...
# So use this for a simple pattern match:
###case "$TYPE" in CYGWIN*)
# Or this for more complexity:
case "$TYPE" in CYGWIN[ab]*)
  echo matched on wildcard
  echo $TYPE
esac
