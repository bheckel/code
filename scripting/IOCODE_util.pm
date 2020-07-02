##############################################################################
#     Name: IOCODE_util.pm
#
#  Summary: Utility functions common to all query_mysql_db.*
#
#  Created: Mon 16 Sep 2002 10:12:01 (Bob Heckel)
##############################################################################
package IOCODE_util;

require Exporter;
@ISA = qw(Exporter);
# Export by default.
@EXPORT = qw($connect_str $user $pw %rerr %perr);

$connect_str = "DBI:mysql:database=indocc;host=localhost";
$user = undef;
$pw = undef;
%rerr = (RaiseError => 1, PrintError => 0);   # most common
%perr = (RaiseError => 0, PrintError => 1); 


# Common results listing.
sub DispResult {
  my $starttime = shift;
  my $nummatch = shift;
  my $nummiss = shift;
  my $numtot = shift;

  print "Time Elapsed: ", time-$starttime, " seconds\n";
  print "Examined: $numtot\tMatched: $nummatch\tMissed: $nummiss\n";
  printf "Match percentage: %.2f%%\n\n", ($nummatch / $numtot) * 100;

  return 0;
}


# Customize for the final pass, fuzzy.
sub DispFuzzResult {
  my $starttime = shift;
  my $nummatch = shift;
  my $nummiss = shift;
  my $numtot = shift;
  my $nomatchf = shift;
  my $startload = shift;

  my $endload = AvgLoad();

  printf "Avg. Load: %.2f\n", (($startload + $endload) / 2);
  printf "Speed: %.2f seconds per line\n", (time-$starttime) / $numtot;
  DispResult($starttime, $nummatch, $nummiss, $numtot);
  print "See file $nomatchf for final misses.\n";
  print "Run howdo.sh to build final matches file.\n";

  return 0;
}


# Get the current Unix load.
sub AvgLoad {
  # Sample line:
  # " 12:56pm  up 73 days, 31 min,  4 users,  load average: 0.11, 0.14, 0.16"
  my @foo = split /\s+/, `uptime`;
  my $numeric = $foo[11];
  $numeric =~ s/,//g;

  return $numeric;
}


1;
