#!/usr/bin/perl
##############################################################################
#     Name: oscheck.pl
#
#  Summary: Check operating system version
#
#  Adapted: Sat 16 Apr 2005 00:02:52 (Bob Heckel --
#                 http://www.perl.com/lpt/a/2005/04/14/cpan_guidelines.html)
##############################################################################
use strict;
use warnings;

use Config;

print $Config{osname};

if ( $Config{osname} ne 'solaris' || $Config{osver} < 2.9 ) {
  die <<EOT;
  This module needs Solaris 2.9 or higher to run 
  (not $Config{osname} $Config{osver})
EOT
}
