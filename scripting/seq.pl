#!/usr/local/bin/perl -w

$|++;

# No native seq on the mf so build it:

# As if you were a C programmer:

for ( $i=$ARGV[0]; $i<=$ARGV[1]; $i++ ){
  print "$i ";
}

# As if you were an idiomatic Perl programmer:

###map {print "$_\n"} $ARGV[0]..$ARGV[1];
