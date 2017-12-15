#!/usr/bin/perl -w
##############################################################################
#     Name: is_windows.pl
#
#  Summary: Is this script running on a Windows box?
#
#  Adapted: Mon 03 May 2004 16:32:08 (Bob Heckel -- Steve's Place perl tut)
##############################################################################
use strict;

if ( ($^O eq "MSWin32") || ($^O eq 'cygwin') ) { 
  print 'yes';
} else { 
  print 'no';
}
