#!/usr/bin/perl -w

use LWP::Simple;

$_ =
get("http://www.oanda.com/converter/classic?value=$ARGV[0]&exch=$ARGV[1]&expr=$ARGV[2]");
s/^.*<!-- conversion result starts//s;
s/<!-- conversion result ends.*$//s;
s/<[^>]+>//g;
s/[ \n]+/ /gs;
print $_, "\n";

