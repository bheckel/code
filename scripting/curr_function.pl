#!/usr/bin/perl -w
##############################################################################
#    Name: curr_function.pl
#
# Summary: Determine exactly where you are in a Perl program.
#
# Adapted: Mon 26 Feb 2001 13:15:31 (Bob Heckel -- Perl Cookbook p. 341)
##############################################################################

Go();

sub Go {
  print "I'm in file: ",  __FILE__;
  print "\nI'm in package: ",  __PACKAGE__;
  $subname = (caller(0))[3];
  print "\nI'm in sub: $subname";
  # __LINE___ is good as a return value on failure e.g. exit(__LINE__); then
  # echo $? in shell to determine where it bombed.
  print "\nI'm at line: ",  __LINE__, "\n";
}
