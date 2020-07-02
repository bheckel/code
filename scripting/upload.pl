#!/usr/bin/perl -w
##############################################################################
#    Name: upload.pl
#
# Summary: Sample code to demo uploading of files.
#          Works in conjunction with upload.html
#
# Adapted: Fri, 21 Jul 2000 08:51:19 (Coke Harrington usenet post -- Bob
#                                     Heckel)
##############################################################################

use strict;
use CGI qw(:standard);

print header, '<HTML><BODY><PRE>';

my $file = upload('filename_fromPC');
 if ( $file ) {
   # The filename returned by upload()...
   print "File Name: $file\n\n";
   
   # ...is also a filehandle.
   print while <$file>;
}

print '</PRE></BODY></HTML>';
