#!/usr/bin/perl -w

if ( system("ls -l $zipfile") == 0 ) {
  $cmd2 = "mr -rf $basedirx";
  local $| = 1;  # autoflush
  print "ok?\n";
  chomp($answer=<STDIN>);
  if ( $answer eq 'y' ) {
    print $cmd2 . "\n";
  }

