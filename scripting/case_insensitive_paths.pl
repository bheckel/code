#!/usr/bin/perl -w

# Case of path nor filename doesn't matter on Windows.
$guess='\\\\us8n05\\exports\\EXPORT-{0A2FB35F-95B5-4CCC-A614-6AF87D62BBF6}-b.avi';

if (-e $guess) {
  print 'found';
} else {
  print 'not';
}
