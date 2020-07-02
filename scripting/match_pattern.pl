#!/usr/bin/perl
##############################################################################
#     Name: match_pattern.pl
#
#  Summary: Pattern matching.
#
#  Adapted: Mon 21 Sep 2009 10:20:49 (Bob Heckel -- The Camel Book)
##############################################################################
###use strict;
use warnings;


"hot cross buns" =~ m/cross/;

print "Matched: <$`> $& <$'>\n";    # Matched: <hot > cross < buns>
print "Left:    <$`>\n";            # Left:    <hot >
print "Match:   <$&>\n";            # Match:   <cross>
print "Right:   <$'>\n";            # Right:   < buns>



# Better, more efficient
$_ = "Bilbo Baggins's birthday is September 22";
/(.*)'s birthday is (.*)/;
print "Person: $1\n";
print "Date: $2\n";



# First and last occurrence of a word starting with 're'
open F, "$ENV{HOME}/bladerun_crawl" or die "Can't open : $!\n";
while ( <F> ) {
  # ?...? doesn't have to keep searching file if found
  $first = $1 if ?(re\w+)?;  # replicant
  $last  = $1 if /(re\w+)/;  # retirement
}
print $first,"\n";
print $last,"\n";  



# Arrays
@chapters = ('one Bilbo', 'two', 'three Bilbo');
###for ( @chapters ) { s/Bilbo/Frodo/g }
# Same done Perlishly
###s/Bilbo/Frodo/g for @chapters;
###print "@chapters", "\n";
for ( @newchapters = @chapters ) { s/Bilbo/Frodo/g }
print "@newchapters", "\n"; print "@chapters", "\n";



# Repeated substitute
$string = ' a foo  bar ';
for ( $string ) {
  s/^\s+//;       # discard leading whitespace
  s/\s+$//;       # discard trailing whitespace
  s/\s+/ /g;      # collapse internal whitespace
}
print "X${string}Y", "\n";



# Complex substitute - remove duplicate words (and triplicate (and
# quadruplicate...))
$_ = 'paris in the the the the spring';
1 while s/\b(\w+) \1\b/$1/gi;
print "$_\n";



# Progressive matching use '/c' modifier
# Find characters without reverting to position 0
$burglar = "Bilbo Baggins";
while ($burglar =~ /b/gic) {
  printf "Found a B at %d\n", pos($burglar)-1;
}
while ($burglar =~ /i/gi) {
  printf "Found an I at %d\n", pos($burglar)-1;
}
