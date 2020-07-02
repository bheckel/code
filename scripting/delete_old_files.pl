#!/usr/bin/perl
##############################################################################
#     Name: delete_old_files.pl (aka Del_Old.pl)
#
#  Summary: Remove old files.  Rotate out to make disk space.
#
#  Created: Thu 29 Jan 2009 11:27:22 (Bob Heckel)
##############################################################################
use strict;
use warnings;

my $dir = '.';
my $olderthandays = 3;
my $ext = 'zip';
my @files;

opendir D, "$dir" or die "$!"; @files=grep { !/^..?$/ && !-d } map "$dir/$_", readdir D;

for ( @files ) {
  ###next unless $_ =~ /\.${ext}$/;
  next unless /\.${ext}$/;
  next unless -M $_ > $olderthandays;
  print "deleting $_\r\n";
  ###unlink $_;
}
