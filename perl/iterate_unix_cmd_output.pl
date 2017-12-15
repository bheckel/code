#!/usr/bin/perl 

open(F, "ls -l |");
while ( <F> ) { ## read F, line by line
  print "wtf $_\n";
}
