#!/usr/bin/perl
##############################################################################
#     Name: duplicate_words.pl
#
#  Summary: Find consecutive words in paragraphs, potentially spanning word
#           boundaries.
#
#           $ ./duplicate_words.pl $c/Bookshelf_Perl/ch05_02.htm
#
#  Adapted: Mon 21 Sep 2009 10:31:16 (Bob Heckel -- The Camel Book)
##############################################################################
use strict;
use warnings;


$/ = "";        # "paragrep" mode

while (<>) {
  while ( m{
              \b        # start at a word boundary
              (\w\S+)   # find a wordish chunk
              (
                  \s+   # separated by some whitespace
                  \1    # and that chunk again
              ) +       # repeat ad lib
              \b        # until another word boundary
           }xig         # /x for space and comments, /i to match both `is' in "Is is this ok?", /g to  find all dups
       )
  {
      print "dup word '$1' at paragraph $.\n";
  }
}
