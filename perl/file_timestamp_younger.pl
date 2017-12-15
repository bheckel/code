#!/usr/bin/perl
##############################################################################
#     Name: file_timestamp_younger.pl
#
#  Summary: Determine if a file is younger than 90 days old.
#
#  Created: Fri 18 Sep 2009 12:00:04 (Bob Heckel)
##############################################################################
###use strict;
use warnings;

$then = time()-(90*86800);
###($x) = (stat("fax_coversheet.doc"))[9];
($x) = (stat("junk2"))[9];
print "file is younger than 90 days" if $x > $then;
