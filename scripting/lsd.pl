#!/usr/bin/perl -w
##############################################################################
# Program Name: lsd.pl
#
#      Summary: Display ls for directories only.
#               TODO use fewer columns if have long filename.  Align the
#               columns the way that ls does.
#
#      Created: Tue Dec 29, 1998 16:57:17 (Bob Heckel)
#     Modified: Wed Apr 28 1999 10:12:36 (Bob Heckel -- tab delim each)
#     Modified: Thu, 19 Aug 1999 14:28:06 (Bob Heckel -- remove tabs,
#                                          alphabetize)
#
# OBSOLETED BY ls -F | egrep \/    IN BASHRC
##############################################################################

opendir(DIR, ".");
@files = readdir(DIR);
foreach(sort(@files)) {
  print("$_/  ") if -d;
}
print "\n";
closedir(DIR);

