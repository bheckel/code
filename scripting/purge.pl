#!/usr/bin/perl -w
##############################################################################
#     Name: purge.pl
#
#  Summary: Delete specific files in a directory, based on file
#           extension, older than X days.
#
#  Created: Thu 22 Jan 2004 17:07:17 (Bob Heckel)
# Modified: Mon 18 Apr 2005 14:46:02 (Bob Heckel)
##############################################################################
use strict;

########################### User configurable: #############################
use constant DEBUG      => 1;        # 1 for no deletions, 0 for production
use constant PATHTOP    => '/home/bhb6/data';    # no trailing slash
use constant PATHSUB    => 'data1';  # only del from this subdir
use constant DAYSTOLIVE => 180;      # per dwj2
use constant EXTENSION  => 'mer';    # case insensitive, exclude leading dot
use constant DELLOG     => '/home/bqh0/deletions.log';
############################################################################

Usage() if $#ARGV != -1; print 'purge? '; die unless <STDIN> =~ /^y|^yes|^ok/i;

my $expired = UnixDtPast(DAYSTOLIVE);

foreach my $f ( GetFnames(PATHTOP) ) {
  my ($mtime) = (stat($f))[9];
  my $mtime_fmt = localtime($mtime);
  # Leave the 2003 in place, the ones that exist are the final ones for the yr.
  next if $f =~ /.*@{[PATHSUB]}\w\w03/;
  Purge($f) if $mtime < $expired;
}

print "confirmed (s/b blank):\n";
# find(1) days needs to be adjusted to match ours.
my $daysminus1 = DAYSTOLIVE - 1;
system "find @{[PATHTOP]}/@{[PATHSUB]} -name '*.@{[EXTENSION]}' -mtime +$daysminus1";

exit 0;



sub Purge {
  my $f = shift;
  # Only kill files matching our dir and file extension.
  return unless ( $f =~ /.*@{[PATHSUB]}.*\.@{[EXTENSION]}$/i );
  # Don't delete if this file is the current one in the DBM.
  return if FileIsLatest($f);

  unlink($f) || die "Cannot unlink $f: $?\n"; 
  print "deleted: $f\n\n";
  LogDeletion($f);

  return 0;
}


# Are we preparing to delete the file that is considered the most recent by
# the DBM database (we will break reviser-file-ck3.pl if deleted)?  Returns
# boolean.
sub FileIsLatest {
  my $f = shift;

  # E.g. /home/bhb6/data/data1/ny04034a.nat.mer
  $f =~ /.*\/(\w\w)(\w\w)[^.]*\.(\w\w\w)/;
  # Build to be able to select correct row in DBM.
  my $stateyr = $1 . 'X' . $2 . $3;
  ###print "DEBUG: \$stateyr $stateyr\n";

  my $dump = `/home/bqh0/bin/dbmdump.pl /home/bqh0/dirchgDBM/dir_database | sort | grep $stateyr`;
  chomp $dump;
  print "DEBUG: \$dump $dump\n";

  # E.g. miX04dem = 1113415952 58856661 mi04027a.dem.mer 1113416100 5754509
  $dump =~ /\S+ = \d+ \d+ (\S+)/;
  ###print "DEBUG: \$1 $1\n";

  if ( $f eq $1 ) {
    print "!!!SHOULD NOT DELETE THIS ONE!!!\n";
    return 1;
   } else {
    print 'ok to delete... ';
    return 0;
   }
}


# Keep record of deletions.
sub LogDeletion {
  my $f = shift;

  open FH, ">>@{[DELLOG]}" or die "Error: $0: $!";

  print FH localtime, " $f\n";

  close FH;

  return 0;
}


# Gather all directory tree file and dir names recursively.
sub GetFnames {
  no strict 'refs';
  no strict 'vars';
  my $dir = shift;

  opendir $dir, $dir || die "Cannot open $dir: $!";
  
  while ( my $dirent = readdir $dir ) {
    # Throw out '.' and '..'
    next if ( ($dirent eq ".") || ($dirent eq "..") );

    my $path = $dir."/".$dirent;
    push @path, $path;
    
    # Recurse for directories.
    GetFnames($path) if ( -d $path );
  }
  closedir($dir);
  
  return @path;
}


# Calc Unix date $days in the past
sub UnixDtPast {
  my $days       = shift;
  my $multiplier = shift;

  $multiplier ||= $multiplier = 1;
  my $unixseconds = time() - ($days * 60 * 60 * 24 * $multiplier);

  return $unixseconds;
}


sub Usage {
  my $f = $1 if $0 =~ m|[/\\:]+([^/\\:]+)$|;
  print <<"EOT";
Usage: $f
 Purges files (currently .@{[EXTENSION]} files in @{[PATHTOP]}/@{[PATHSUB]}/ ) 
 based on their age (currently @{[DAYSTOLIVE]} days)
EOT

  exit -1;
}

