#!/usr/bin/perl
##############################################################################
#    Name: bcp 1.01
#
# Summary: Perl bc - like calculator.
#          TODO add switch to allow multiline entry (evaluate after user
#          enters blank line).
#
# Adapted: Tue, 07 Mar 2000 09:13:02 (Bob Heckel -- Advanced Perl Programming)
# Modified: Sat, 10 Jun 2000 13:15:11 (Bob Heckel)
##############################################################################

print '$x is equivalent to . in bc ', "\n";
print "Ctrl+d to exit\n";

while ( defined($str = <>) ) {          # Read a line into $s
  $x = eval($str);                # Evaluate that line
  if ( $@ ) {                       # Check for compile or run-time errors.
      print "Invalid string:\n $str";
  } else {
      print $x, "\n";
  }
}
