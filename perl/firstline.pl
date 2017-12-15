#!/usr/bin/perl -w
##############################################################################
#     Name: firstline.pl
#
#  Summary: Print first line of a file without using $.
#
#  Created: Tue, 05 Sep 2000 08:48:01 (Bob Heckel)
##############################################################################

open(FILE, "junk") || die "$0--Can't open file: $!\n";

# Force scalar context.
my ($firstline) = scalar(<FILE>);
# Print only the first line of the file.
print $firstline;
