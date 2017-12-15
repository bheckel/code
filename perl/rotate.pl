#!/usr/bin/perl
##############################################################################
#    Name: rotate.pl
#
# Summary: Take logfile foo, rename as foo.1, take old foo.1, rename as foo.2,
#          etc. then gzip the old foo.4 into a foo.gz for archiving.  
#          No data is discarded.
#
# Adapted: Aug 1, 2000 (Bob Heckel-From "Tricks with Perl and Apache" 
#                       Lincoln Stein)
# Modified: Tue 11 May 2004 10:53:19 (Bob Heckel)
##############################################################################

# Logfile name must be passed:
if ( $#ARGV || $ARGV[0] =~ /-+h.*/ ) {
  print STDERR "Usage: $0 FILE_TO_ROTATE\n";
  exit(-1);
}

$MAXCYCLE = 3;   # gzip after this many backups have been made
###$GZIP = '/bin/gzip';
$GZIP = "`which gzip`";
%ARCHIVE = ($ARGV[0] => 1);

foreach $logfile ( keys %ARCHIVE ) {
  system "$GZIP -c $logfile.$MAXCYCLE >> $logfile.gz" 
                            if -e "$logfile.$MAXCYCLE" and $ARCHIVE{$logfile};

  for ( my $s=$MAXCYCLE; $s--; $s>= 0 ) {
    $oldname = $s ? "$logfile.$s" : $logfile;
    $newname = join(".", $logfile, $s+1);
    rename($oldname, $newname) if -e $oldname;
  }

}

# Prepare the zeroeth logfile.
open EMPTY, ">$ARGV[0]" || die "Can't create new, empty $ARGV[0]: $!\n";
