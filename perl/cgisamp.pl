#!/usr/bin/perl -w

use strict;
use CGI;

my $q = new CGI;
print $q->header;
print $q->start_html("test");
print "This is a test";
print $q->end_html;
