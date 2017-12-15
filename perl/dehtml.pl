#!/usr/bin/perl -w
##############################################################################
#   Name: dehtm
#
#  Summary: Slurp up lines in a file and de-htmlify the < > space & " '
#           bits to STDOUT
#           Usage: dehtm uglyhtml.html > cleanforviewing.txt
#
#           May be better to use  lynx -dump uglyhtml.html or,
#           in my Vim, :HtM and :HtN 
#
#  Created: Thu Apr 15 1999 09:21:46 (Bob Heckel)
# Modified: Fri Jun 11 1999 11:21:09 (Bob Heckel--comments)
##############################################################################

# TODO how to specify more than one file passed to dehtm on cmdline?
open(FIL, "$ARGV[0]") || die ("Can't open file $ARGV[0] !\n");

while(<FIL>) {
  $_ =~ s/\&gt;/\>/g;
  $_ =~ s/\&lt;/\</g;
  $_ =~ s/\&nbsp;/ /g;
  $_ =~ s/\&amp;/\&/g;
  $_ =~ s/\&apos;/'/g;
  $_ =~ s/\&quot;/"/g;
  print;
}
