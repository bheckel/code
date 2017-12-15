#!/usr/bin/perl

# simple hello world cgi script
print "Content-type: text/html\n\n";
print "<html>print <body>\n";
print "<hr>Hello, world!<br><hr>\n";
print "user is is: ", `whoami` , "<br>\n";


print "</body></html>\n";

