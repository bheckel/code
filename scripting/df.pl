#!/usr/bin/perl -w
##############################################################################
# Program Name: df.pl
#
#      Summary: Determine if disk is almost full.  Solaris version.
#
#  Adapted: Created: Fri, 19 Nov 1999 14:32:39 (Bob Heckel)
# Modified: Thu 26 Aug 2004 16:55:12 (Bob Heckel)
##############################################################################
use strict;

my $thresh = 90;  # percent full
my $trouble = 0;  # are we over the threshold?
my $mail = "mailx -s 'automated output from $0' bqh0\@cdc.gov";
my @msg = ();

# Trailing pipe directs command output into this pgm.
if ( ! open(DFPIPE, "df -k |") ) {
  die "Can't run df. $!\n";
}

while ( <DFPIPE> ) {
  my @data = split;
  #             0                 1        2      3         4       5
  # E.g. /dev/dsk/c1t1d0s0    17497404  580312 16742118     4%    /home
  (my $pct = $data[4]) =~ s/%//;
  next unless $pct =~ /\d+/;
  if ( $pct > $thresh ) {
    push @msg, "warning: $data[5] is at $data[4]\n";
    $trouble = 1;
  }
}

if ( $trouble ) { 
  open MAILHANDLE, "|$mail" || die "Can't fork for $mail: $!";
  print MAILHANDLE @msg;
  close MAILHANDLE;
}
