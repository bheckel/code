#!/usr/bin/perl -w
##############################################################################
#     Name: unbalanced_quotes.eval.pl
#
#  Summary: Demo of using eval() to catch unbalanced quotes.
#
#  Adapted: Wed 08 Oct 2003 14:27:13 (Bob Heckel -- Advanced Perl Programming
#                           file:///C:/bookshelf_perl/advprog/ch05_04.htm)
##############################################################################

# Feed it these:
# ok
# 'He said, "come on over"' 
# not ok
# 'There are times when "Peter" doesn't work at all'

while ( defined($s = <>) ) {
  $result = eval $s;                # evaluate that line
  if ( $@ ) {                       # check for compile or run-time errors.
      print "Invalid string:\n $s";
  } else {
      print "Valid string: $result\n";
  }
}
