#!/usr/bin/perl -w
##############################################################################
#     Name: dirchanges.pl
#
#  Summary: Detect if changes to a directory have occurred since the last run.
#           If so, email the results.
#
#  Created: Thu 29 Apr 2004 16:45:13 (Bob Heckel)
##############################################################################
use strict;
use 5.005_03;      # developed on tstdev, Dumper uses regular arrays, not refs
use Data::Dumper;  # to save state between runs

my $watchdir = '/home/bhb6/data/data1';

my $savedls;
my $savedtstamp;
my $mailto;
if ( $ARGV[0] eq '--hourly' ) {
  $savedls = '/home/bqh0/dirchg/saved_state_files.hourly.dat';
  $savedtstamp = '/home/bqh0/dirchg/saved_state_time.hourly.dat';
  $mailto = 'bhb6@cdc.gov,bqh0@cdc.gov';
} elsif ( $ARGV[0] eq '--twice' ) {
  $savedls = '/home/bqh0/dirchg/saved_state_files.twicedaily.dat';
  $savedtstamp = '/home/bqh0/dirchg/saved_state_time.twicedaily.dat';
  $mailto = 'bqh0@cdc.gov';
} else {
  $savedls = '/home/bqh0/dirchg/saved_state_files.DEBUG.dat';
  $savedtstamp = '/home/bqh0/dirchg/saved_state_time.DEBUG.dat';
  $mailto = 'bqh0@cdc.gov';
}

my $files;
# Recover the saved files array from disk.
open FH, "$savedls" or die "Error: $0: $!";
{ local $/ = undef; $files = <FH>; }
close FH;
my @oldls = eval $files;

my $ts;
# Recover the last-run timestamp from disk:
open FH2, "$savedtstamp" or die "Error: $0: $!";
{ local $/ = undef; $ts = <FH2>; }
close FH2;

# Get a real-time ls of the dir:
opendir DH, "$watchdir" || die $!;
my @newls = readdir DH;
closedir DH || die $!;

my @newarrivals = ();
# Look for new files:
if ( @newls != @oldls ) {
  my %found = map { $_, 1 } @oldls;

  foreach my $f ( @newls ) {
    if ( not $found{$f} ) {
      push @newarrivals, "$f\n";
    }
  }
}

# Save the timestamp to disk for next run:
open FH3, ">$savedtstamp" or die "Error: $0: $!";
print FH3 scalar localtime;
close FH3;

# Save the current filenames to disk to compare as "oldls" on next run.
open FH4, ">$savedls" or die "Error: $0: $!";
# TODO this can probably be simplified
print FH4 Data::Dumper->Dump( [ \@newls ], [ *newls ]);
close FH4;

if ( @newarrivals ) {
  my ($mail, $singplur, $qty);
  if ( scalar @newarrivals == 1 ) {
    $mail = "mailx -s 'A new reviser file has been created since $ts' $mailto";
    $singplur = 'This file'; 
    $qty = 'It';
  } else {
    $mail = "mailx -s 'New reviser files have been created since $ts' $mailto";
    $singplur = 'These files'; 
    $qty = 'They';
  }

  open MAILHANDLE, "| $mail" || die "$0 can't fork for mailx: $!";

  print MAILHANDLE "$singplur been created in $watchdir\n\n";
  my $fqn;
  my $mtime;
  for ( @newarrivals ) {
    chomp;
    $fqn = $watchdir . "/$_";
    $mtime = scalar localtime((stat($fqn))[9]);
    print MAILHANDLE "$_\t\t$mtime\n";
  }

  print MAILHANDLE <<"EOT";


$qty can be processed via FCAST menus:
6 - REVISER MENU

then

6 - TRANSFER FILE FROM UNIX AND PRODUCE REPORT - MORTALITY
or
7 - TRANSFER FILE FROM UNIX AND PRODUCE REPORT - NATALITY



This is an automated email.  Please contact LMITHELP if you have any questions.
EOT

  close MAILHANDLE;
}
