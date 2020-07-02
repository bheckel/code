#!/usr/bin/perl -w
##############################################################################
#     Name: timestamp.pl (s/b symlinked as lastupdated.pl)
#
#  Summary: Automate the timestamp process.
#
#  Created: Wed 28 Jan 2004 11:26:47 (Bob Heckel)
# Modified: Wed 15 Aug 2007 16:14:06 (Bob Heckel)
##############################################################################
###use strict;

# Time stamp the last modified date.
my $mtime = (stat($0))[9];
my $t = localtime $mtime;

print <<"EOT";
  <HTML>Please contact Bob Heckel at 
  <A HREF=mailto:bheckel\@cdc.gov?Subject=ioquery.pl>bheckel\@cdc.gov</A> 
  <BR>Last updated: $t
  </HTML>
EOT


# Unrelated example:

open FH, '>foo' or die "Error: $0: $!";
print FH scalar localtime;

print 'doing stuff';
sleep 5;

open FH2, '>foo2' or die "Error: $0: $!";
print FH2 scalar localtime;



# Unrelated example:

# In case box loses power, we can tell how long it ran using this and the 
# stamp below
($mon, $day, $year) = (localtime())[4,3,5];
$year += 1900;
$now = $mon . '-' . $day . '-' . $year;
open TS, ">tstamp.start.$now.txt" or die "Error: $0: $!";
print TS scalar localtime;
print TS "\n";
# ...leave it open til code finishes and print to it when done, then close TS
