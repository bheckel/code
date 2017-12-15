#!/usr/bin/perl

# File: find_status.pl
# Adapted: Tue, 20 Jun 2000 09:18:04 (Bob Heckel -- Cool Tricks Lincoln Stein)
# Modified: Thu 10 May 2001 14:42:56 (Bob Heckel)

use Getopt::Std;

# Protect against bad switches, not an empty @ARGV.
unless ( getopts('l:t:H') ) {
  die <<EOT;
Usage: apachelog_status.pl [-LtH] <code1> <code2> <code3>... [path to logfile]
       Either supply no args for defaults 200 and /apache/logs/access_log or
       supply <code1>... and [path to logfile]

       E.g. apachelog
       E.g. apachelog -t10 200 404 /apache/logs/access_log

       Scan Web server log files and list a summary
       of URLs whose requests had the one of the
       indicated status codes.
Options:
       -l <domain>  Ignore local hosts matching this domain
       -t<integer>  Print top integer URLS/HOSTS (default w/o switch is 10)
       -H           Sort by host rather than URL
EOT
}

if ( $opt_l ) {
  $opt_l =~ s/\./\\./g;
  $IGNORE = "(^[^.]+|$opt_l)\$";
}

$TOP = $opt_t || 10;

if ( @ARGV ) {
  while ( @ARGV ) {
    last unless $ARGV[0] =~ /^\d+$/;
    $codes{shift @ARGV}++;
  }
  while ( <> ) {
    ($host,$rfc931,$user,$date,$request,$URL,$status,$bytes) =
                /^(\S+) (\S+) (\S+) \[([^]]+)\] "(\w+) (\S+).*" (\d+) (\S+)/;
    next unless $codes{$status};
    next if $IGNORE && $host=~/$IGNORE/io;
    $info = $opt_H ? $host : $URL;
    $found{$status}->{$info}++;
  }
} else {  # no command line args passed, default to access_log and 200
  open(FILE, '/apache/logs/access_log') || die "$0: can't open file: $!\n";
  $codes{200} = 1;
  # TODO elim duplicated code
  while ( <FILE> ) {
    ($host,$rfc931,$user,$date,$request,$URL,$status,$bytes) =
                /^(\S+) (\S+) (\S+) \[([^]]+)\] "(\w+) (\S+).*" (\d+) (\S+)/;
    next unless $codes{$status};
    next if $IGNORE && $host=~/$IGNORE/io;
    $info = $opt_H ? $host : $URL;
    $found{$status}->{$info}++;
  }
}
 
foreach $status ( sort {$a<=>$b;} sort keys %codes ) {
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
    $TOP,                         $status

    REQUESTS  URL/HOST
    --------  --------
.
format STDOUT=
    @#####    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    $info->{$i},$i
. 
