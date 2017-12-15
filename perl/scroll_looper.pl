#!/usr/bin/perl -w

open FH, 'junk' or die "Error: $0: $!";

@line=<FH>;

while ( 1 ){
  $r = int(rand(51)) + 25;  # integer from 25 to 75
print "DEBUG!!!!!!!!!!!!!!!!!!!!!$r!!!!!!!!!!!!!!!!!!!!!DEBUG\n";

 if ( $r eq 42 ) {
  # Fake a hard part
  sleep 3;
 } else {
  # Normal
  print $line[int rand @line]; 
  if ( $r eq 50 or $r eq 51 ) {
    print "\n\n\n\n";
    # Fake a fast part
    for ( 1..175 ) {
      print $line[int rand @line]; 
    }
  } elsif ( $r eq 75 ) {
  # Fake a harder part
    sleep 4;
  }
 }
}
