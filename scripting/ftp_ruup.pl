#!/usr/bin/perl -w
##############################################################################
#     Name: ftp_ruup.pl
#
#  Summary: Test the f'ing mainframe to see when its ftp daemon responds.
#
#  Created: Fri 23 Jan 2004 10:32:23 (Bob Heckel)
# Modified: Tue 31 Aug 2004 12:43:03 (Bob Heckel)
##############################################################################
use strict;

use Net::FTP;

$ARGV[0] ||= '158.111.2.21';

if ( my $ftp = Net::FTP->new("$ARGV[0]") ) {
  $ftp->quit;
  system "beep";
  print "$ARGV[0] ftp is ok as of ", scalar localtime, "\n";
  exit 0;
} else {
  exit 1;
}
