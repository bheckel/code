#!/usr/bin/perl -w
##############################################################################
#     Name: random.pl
#
#  Summary: Print a random array value.
#
#  Created: Fri, 17 Dec 1999 08:39:46 (Bob Heckel)
# Modified: Thu 06 May 2004 14:19:14 (Bob Heckel)
##############################################################################

srand;  # TODO do I need this?

@files = ("randomlygen1.gif", "randomlygen2.gif", "randomlygen3.gif");

$surprise = $files[rand @files];

print $surprise, "\n";

