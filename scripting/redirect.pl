#!/usr/bin/perl -w
##############################################################################
#     Name: redirect.pl
#
#  Summary: Redirect STDIN STDOUT
#
#  Adapted: Mon 07 May 2001 16:59:20 (Bob Heckel www.informit.com Lincoln
#                                     Stein)
##############################################################################

print "Redirecting STDOUT\n";

open (SAVEOUT, ">&STDOUT");

open (STDOUT, ">junk") or die "Can't open test.txt: $!";

# Notice how the second print() statement and the output of the date system
# command went to the file rather than to the screen because we had reopened
# STDOUT at that point. When we restored STDOUT from the copy saved in
# SAVEOUT, our ability to print to the terminal was restored.
print "STDOUT is redirected\n";

system "date";

open (STDOUT, ">&SAVEOUT");

print "STDOUT restored\n";
