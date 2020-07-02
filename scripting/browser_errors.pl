#!/usr/bin/perl -w

# This has better diagnostics...
BEGIN {
  # Print out a content-type for HTTP/1.0 compatibility.
  print "Content-type: text/html\n\n";
  print "<HTML><HEAD><TITLE>$TITLE</TITLE></HEAD><BODY>";
  open(STDERR, ">&" . STDOUT) or die "Cannot Redirect STDERR: $!";
}

# ...than this.
use CGI::Carp qw(fatalsToBrowser);
