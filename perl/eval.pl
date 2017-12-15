#!/usr/bin/perl -w
##############################################################################
#     Name: eval.pl
#
#  Summary: Demo of a simple eval.
#
#  Adapted: Wed 24 Sep 2003 13:07:47 (Bob Heckel --
#                             file:///C:/bookshelf_perl/advprog/ch05_01.htm)
##############################################################################

$str = '$a++; $a + $b';   # contains two expressions
$a = 10; $b = 20;
$c = eval $str;

print $c;                 # 31
