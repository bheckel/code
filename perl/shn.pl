#!/usr/bin/perl -w
##############################################################################
#     Name: shn.pl
#
#  Summary: Poor man's cron that retrieves files via Win32 dialup during low 
#           traffic times.
#
#           This file s/b chmod 700
#
#           TODO use commandline parms, especially -h
#
#  Created: Mon, 07 Aug 2000 09:46:47 (Bob Heckel)
# Modified: Fri 23 Jan 2004 22:57:56 (Bob Heckel)
##############################################################################
use strict;

my $DEBUG = 0;
my $run_hr;
# Run immediately in debug mode, otherwise 3 a.m.
$DEBUG ? ($run_hr = (localtime)[2]) : ($run_hr = 3);   # military time
my $lo     = 2;
my $hi     = 2;   # get $lo thru (and including) this number
###my $saveto_dir = '/home/bheckel/music/gd/inprogress';
my $saveto_dir = '/home/bheckel/install';
my $connectoid = 'Wnet 334-4500';
my $uid        = '360149431\@worldnet.att.net';
my $pw         = 'koqapop-wirener';
# TODO set ftp://... path here


print "Download will begin around $run_hr.\n";
print "Tip:  \$ tail /var/log/wgetlog  during transfer to monitor.\n";

while ( 1 ) {
  # Around this time, do one iteration of the following, then exit.
  if ( (localtime())[2] == $run_hr ) {  
    print 'started: ';
    system('date');  # timestamp the start

    if ( chdir $saveto_dir ) {
      system("rasdial \'$connectoid\' $uid $pw") == 0 or die "Cannot connect\n";
    } else {
      die "Cannot cd to $saveto_dir.  Exiting\n";
    }

    for ( my $i=$lo; $i<=$hi; $i++ ) {
      my $j = sprintf("%02d", $i);  # zero pad number
      # wget barfs on ampersand in path so backslash them.
      ###my $f = "ftp://gdlive.com/phish/991230/ph1999-12-30-d5t$j.mp3";
      ###my $f = "http://www.gdlive.com/shn/gd90-03-29.shnf/gd1990-03-29d2t$j.shn";
      my $f = "http://ftp.mozilla.org/pub/mozilla.org/mozilla/releases/mozilla1.6/mozilla-win32-1.6-installer.exe";
      print "retrieving:  $ENV{fg_yellow}$f$ENV{normal}...\n";
      system("wget -c -T 60 -o /var/log/wgetlog -S -nd $f") && 
                                               die "$0: can't wget $f: $!\n";
    }
    system("rasdial 'Worldnet 334-4500' \/d") == 0 or die "Cannot disconnect\n";
    print 'finished: ';
    system('date');  # timestamp the end
    exit 0;
  }

  sleep 1800;       # check every 30 minutes
}

die "$0: shouldn't have reached here\n";
