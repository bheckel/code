#!/usr/bin/perl
##############################################################################
#     Name: while.pl
#
#  Summary: Read in files from command line or act as a filter.
#
#           Probably better:
#           map { print "$_\n" } @ARGV;
#
#  Adapted: Wed 29 Dec 2004 13:35:27 (Bob Heckel -- Randal Schwartz)
##############################################################################
use strict;
use warnings;
use Coy;

@ARGV = "-" unless @ARGV;       # act as filter if no names specified

while ( @ARGV ) {
  $_ = do { local $/; <> };

  print $_;  # the whole file(s)
}
