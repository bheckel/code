#!/usr/bin/perl -w

open FH, "$ENV{HOME}/bladerun_crawl" or die "Error: $0: $!";

$x=tell(FH);
print "$x\n";

$y=seek(FH, -18, 2);
print "$y\n";

$z=read(FH, $foo, 8);
print "$z and pick out only the word NOVEMBER: $foo";
