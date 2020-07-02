#!/usr/bin/perl -w

$regex = '"(\d+)"';

%seen = ();
while ( <DATA> ) {
 while ( /$regex/go ) {
   # Use each item as the key and increment the value by one.
   $seen{lc $1}++;
 }
}

foreach $num ( sort { $seen{$b} <=> $seen{$a} } keys %seen ) {
 printf "freq: %5d num:%5d\n", $seen{$num}, $num;
}


__DATA__
"1","3","38","18","28"
"32","20","35","33","21"
"31","11","28","22","19"
