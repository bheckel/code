#!/usr/bin/perl -w
##############################################################################
# Program Name: du.pl
#
#      Summary: Demo of how to accept input from an external program.
#               Good for customizing GNU utilities.
#               From Univ of Missouri tutorial.
#
#      Adapted: Created: Fri, 19 Nov 1999 14:32:39 (Bob Heckel)
##############################################################################

$files = join(' ', @ARGV);

# Trailing pipe directs command output into this pgm.
if (! open (DUPIPE, "du -s $files |")) {
  die "Can't run du. $!\n";
}

printf ("%-7s %-15s\n", 'Kb', 'File');
printf ("%-7s %-15s\n", '--', '----');

while (<DUPIPE>) {
  # Parse the du info:
  ($kbytes, $filename) = split;
  print;
  print "\n". $kbytes . " and " . $filename . "\n";
}

