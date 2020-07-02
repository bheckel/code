#!/usr/bin/perl -w
##############################################################################
#     Name: oldnew
#
#  Summary: Gives percent change from an old value to a new one.
#
#           Mnemonic to remember formula "neew oooh oooh"
#
#           TODO use printf
#
#  Created: Tue Apr 13 1999 12:37:45 (Bob Heckel)
# Modified: Wed 24 Aug 2005 10:34:35 (Bob Heckel)
##############################################################################

# Must have received old value and new value.
if ( @ARGV < 2 ) { 
  print "usage: $0: OLD_NUM NEW_NUM\n";
  print "       formula (new-old)/old\n";
  exit(__LINE__);
}

$old = $ARGV[0];
$new = $ARGV[1];
$result = (($new - $old)/$old) * 100;

if ( $result >= 0 ) {
  print "$result percent increase\n";
} else {
  $result *= -1;
  print "$result percent decrease\n";
}
