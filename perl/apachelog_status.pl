#!/usr/local/bin/perl

# File: find_status.pl
# Adapted: Tue, 20 Jun 2000 09:18:04 (Bob Heckel -- Cool Tricks Lincoln Stein)
# Modified: Tue, 20 Feb 2001 11:21:25 (Bob Heckel)

###require "getopts.pl";
use Getopt::Std;

getopts('L:t:h') && @ARGV > 1 || die <<USAGE;
Usage: apachelog_status.pl [-Lth] <code1> <code2> <code3> ...
       Scan Web server log files and list a summary
       of URLs whose requests had the one of the
       indicated status codes.
Options:
       -L <domain>  Ignore local hosts matching this domain
       -t <integer> Print top integer URLS/HOSTS [10]
       -h           Sort by host rather than URL
USAGE

if ($opt_L) {
    $opt_L=~s/\./\\./g;
    $IGNORE = "(^[^.]+|$opt_L)\$";
}

$TOP=$opt_t || 10;

while ( @ARGV ) {
  last unless $ARGV[0]=~/^\d+$/;
  $CODES{shift @ARGV}++;
}
 
while ( <> ) {
  ($host,$rfc931,$user,$date,$request,$URL,$status,$bytes) =
                 /^(\S+) (\S+) (\S+) \[([^]]+)\] "(\w+) (\S+).*" (\d+) (\S+)/;
  next unless $CODES{$status};
  next if $IGNORE && $host=~/$IGNORE/io;
  $info = $opt_h ? $host : $URL;
  $found{$status}->{$info}++;
}
 
foreach $status ( sort {$a<=>$b;} sort keys %CODES ) {
  $info = $found{$status};
  $count = $TOP;
  foreach $i ( sort {$info->{$b} <=> $info->{$a};} keys %{$info} ) {
      write;
      last unless --$count;
}
     $- = 0;  # force a new top-of-report
 }
 
format STDOUT_TOP=

TOP @## URLS/HOSTS WITH STATUS CODE @##:
    $TOP,                      $status

    REQUESTS  URL/HOST
    --------  --------
.
format STDOUT=
    @#####    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    $info->{$i},$i
. 
