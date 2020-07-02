#!/usr/pkg/bin/perl -w
##############################################################################
#    Name: up.pl
#
# Summary: Upload a file.
#
#          Works in conjunction with upload.html
#
#  Created: Sat 08 Jul 2006 17:10:40 (Bob Heckel)
# Modified: Fri 11 May 2007 20:27:07 (Bob Heckel)
##############################################################################
use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser set_message);
BEGIN {
  sub handle_errors {                             
    my $msg = shift;
    print "<h1>Don't Panic.</h1>";
    print "Omigosh: $msg<BR>";
  }
  set_message(\&handle_errors);
}


print header, '<HTML><BODY><PRE>';

my $file = upload('filename_fromPC');

# Don't allow self or dotfile replacement mischief
if ( $file =~ /up.pl/ or $file =~ /^\./ ) {
  print 'sorry';
	exit 1;
}

if ( $file ) {
  print "File Name: $file\n\n";
	open FH, ">./$file" or die "Error: $0: $!";
   
  print FH while <$file>;
}
close FH;

print '</PRE></BODY></HTML>';
