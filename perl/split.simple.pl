#!/usr/bin/perl

###while ( <DATA> ){
  ###$field =  (split /;/, $_)[1];
  ###print "$field\n";
###}

while ( <DATA> ) {
  # Only want two chunks split
  ($who, $rest) = split /;/, $_, 2;
  # Then split the 2nd chunk
  @fields = split ';', $rest;
  print @fields;
}



__DATA__
foo;bar;baz;boom
foo2;bar2;baz2;boom2
