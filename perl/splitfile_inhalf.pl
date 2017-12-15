#!/usr/bin/perl -w
##############################################################################
#     Name: splitfile_inhalf.pl
#
#  Summary: Split a file in half.
#
#  Created: Fri 15 Nov 2002 11:43:11 (Bob Heckel)
##############################################################################
use strict;

SplitFile('junk1.txt');


# Split a file in half to allow the 2 processes to each work on half.
sub SplitFile {
  my $f = shift;

  use Fcntl;             # for tmpnam
  use POSIX qw(tmpnam);  # for tmpnam
  my $tmp1 = undef;
  my $tmp2 = undef;

  do { $tmp1 = tmpnam() } until sysopen(FH, $tmp1, O_RDWR|O_CREAT|O_EXCL);
  do { $tmp2 = tmpnam() } until sysopen(FH, $tmp2, O_RDWR|O_CREAT|O_EXCL);
  print "DEBUG: $tmp1\n";
  print "DEBU2G: $tmp2\n";

  open TOSPLIT, $f or die "Error: $0: $!";
  open HALF1, ">$tmp1" or die "Error: $0: $!";
  open HALF2, ">$tmp2" or die "Error: $0: $!";

  while ( <TOSPLIT> ) {
    if ( $. % 2 ) {
      print HALF1 $_;
    } else {
      print HALF2 $_;
    }

  }

  close HALF1;
  close HALF2;

  # Remove temp files at end of program's (not sub's) run.
  END {
    if ( -f $tmp1 && -f $tmp2 ) {
      unlink $tmp1 or die "Couldn't unlink $tmp1 : $!";
      unlink $tmp2 or die "Couldn't unlink $tmp2 : $!";
    }
  }

  return $tmp1, $tmp2;
}
