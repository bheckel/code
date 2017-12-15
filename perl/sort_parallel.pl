#!/usr/bin/perl -w

# Adapted: Sun, 11 Jun 2000 01:02:30 (Joseph Hall Effective Perl Programming)

# You have two "parallel" arrays or lists. You want to sort one according to
# the contents of another. For example, suppose @page contains page numbers
# and @note contains notes, such that $note[$i] is the note for $page[$i]. You
# would like to print out both arrays sorted by page number.

# You need to sort a list of indices when dealing with parallel arrays.
# Here, we sort the list of indices 0 .. $# page in order of the contents of
# the array @page. A sorted list of indices can be used to iterate of the
# contents of one or more arrays, as in the foreach (spelled "for") loop. It
# can also be used inside a slice to reorder an array, as at the bottom of the
# example.
 
@page = qw(24 75 41 9);
@text = qw(p.24-text p.75-text p.41-text p.9-text);

for (sort { $page[$a] <=> $page[$b] } 0..$#page) {
  print "$page[$_]  ----->  $text[$_]\n";
} 
         
# Or, to reorder @text, use a slice:
print "\n", @text_sorted = @text[sort { $page[$a] <=> $page[$b] } 0..$#page];
 
