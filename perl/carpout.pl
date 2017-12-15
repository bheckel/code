#!/usr/bin/perl

# Print Perl error messages to the browser.

use CGI::Carp qw(fatalsToBrowser set_message);

BEGIN {
  sub ErrHandler { 
    my $msg = shift;
    print "<H1>Don't Panic.</H1>";
    print "Omigosh, somebody email bqh0\@cdc.gov if this thing gets any ";
    print "worse.<BR>";
    print "Here's a description of the twisty passage in which you find ";
    print "yourself wedged:<BR><BR><I>$msg</I><BR>";
  }
  set_message(\&ErrHandler);
}

# ------------------ Begin HTTP/1.0 Standard Header -------------------------
print "Content-type: text/html\n\n";
#...
