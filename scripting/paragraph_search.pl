#!/usr/bin/perl -w

open FH, 'setup.ini' or die "Error: $0: $!";

{           
  local $/ = '';
  @paragraphs = <FH>;
}

foreach $paragraph (@paragraphs) {
  print "ok $paragraph\n\n" if $paragraph =~ /category: Base/;
}

