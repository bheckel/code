#!/usr/bin/perl -w

while ( ($var,$value) = each %ENV ) {
  # Avoid messy fg_red, etc.
  next if $var =~ /^[f|b]g_/;
  print "      \n$var is\n$value\n";
}
