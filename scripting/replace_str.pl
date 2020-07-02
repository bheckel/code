#!/usr/bin/perl -w
##############################################################################
#     Name: replace_str.pl
#
#  Summary: Replace all occurances of string1 with string2.
#
#           May be better to use 
#           perl -pi.bak -e 's/\b(p)earl\b/${1}erl/gi' junk.txt
#
#  Adapted: Wed 25 Apr 2001 09:41:39 (Bob Heckel Perl FAQ5)
# Modified: Thu 30 Aug 2001 11:08:48 (Bob Heckel)
##############################################################################

$file = 'junk.txt';

$old = $file;
$new = "$file.tmp.$$";
$bak = "$file.bak";

open(OLD, "< $old")         or die "can't open $old: $!";
open(NEW, "> $new")         or die "can't open $new: $!";

while ( <OLD> ) {
  # Correct typos, preserving case
  s/\b(p)earl\b/${1}erl/gi;
  print NEW $_            or die "can't write to $new: $!";
}

close(OLD)                  or die "can't close $old: $!";
close(NEW)                  or die "can't close $new: $!";

rename($old, $bak)          or die "can't rename $old to $bak: $!";
rename($new, $old)          or die "can't rename $new to $old: $!";

