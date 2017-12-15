#!/usr/bin/perl
##############################################################################
#     Name: \\rtpsawn445\DataPost\bat_files\del_old.pl
#
#  Summary: Remove old files.  Rotate out to make disk space.
#
#  Created: Thu 29 Jan 2009 11:27:22 (Bob Heckel)
##############################################################################
use strict;

my $dir = 'E:\DataPost\zip_files';
my $olderthandays = 23;
my $ext = 'zip';
my @files;

opendir D, "$dir" or die "$!"; @files=grep { !/^..?$/ && !-d } map "$dir/$_", readdir D;

for ( @files ) {
  next unless $_ =~ /\.${ext}$/;
  next unless -M $_ > $olderthandays;
  print "deleting $_\r\n";
  unlink $_;
}
