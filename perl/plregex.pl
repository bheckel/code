#!/usr/bin/perl
##############################################################################
#     Name: plregex
#
#  Summary: Test regular expressions from the commandline.  Actually a better
#           demo of eval.
#
#           DEPRECATED -- better to just use:
#
#           $ perl -de 0
#           <DEBUG> $x = 'test string'
#           <DEBUG> $x =~ /^(test).*/; $y = $1
#           <DEBUG> $y <---produces 'test'
#
#           or best:  $ perl -e "print 'ok' if 'this' =~ /matchme/"
#
#  Created: Mon, 06 Mar 2000 15:16:02 (Bob Heckel -- with help from 
#                                     Advanced Perl Programming)
# Modified: Sat 07 Aug 2004 08:27:00 (Bob Heckel)
##############################################################################

$string = $ARGV[0];
$regex = $ARGV[1];

# Eval thinks of this as a program to be executed.
$str = 'if ( $string =~ /$regex/ ) {
          print "match\n";
          foreach $expr ( 1..$#- ) {
             print "Match $expr: ${$expr} at position ($-[$expr], $+[$expr])\n"
          }
        }
        else { print "no match\n" }
       ';

eval $str;

if ( $ARGV[0] =~ /-+h.*/ || !@ARGV ) {
  print <<EOT;
Usage: plregex STRING TESTREGEX [--h(elp)]
e.g. plregex foobar '\bfoo(?!bar)\w+'}

Use parenthesis to specify verbose, particular match positions

E.g. plregex 'Mmm...donut, thought Homer' '^(Mmm)\.\.\.(donut)'
Otherwise only get 'match' if succesful.

EOT
  exit;
}

