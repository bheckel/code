#!/usr/bin/perl
##############################################################################
#     Name: parse_complex_textfile.pl
#
#  Summary: Summarize login data where the record spans multiple lines of text
#
#  $ while true; do echo; date; ssh rtsph005 ps -ef | grep lms_client*| perl -ne 'print if $_=~/\d?\d:\d\d:\d\d/'; sleep 135; done >> limslogins.txt
#
#  Created: Fri 27 Sep 2013 15:15:16 (Bob Heckel)
##############################################################################
###use strict;
use warnings;

use Time::Local;

###open FH, 'junk' or die "Error: $0: $!";
open FH, 'limslogins.txt' or die "Error: $0: $!";

my @line=<FH>;

my %h = ();

for my $line ( @line ) {
  next if $line =~ /^$/;

  if ( $line =~ /^\w/ ) {  # e.g. Fri, Sep 27, 2013 11:03:38
    ($day, $month, $date, $yr, $time) = split ' ', $line;
    $date =~ s/,//g;
    @months{qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)} = (0..11);
    $mon  = exists($months{$month}) ? $months{$month} : die "Bad month";
    ($hour, $minute, $second) = split ':', $time;
    $epoch_seconds = timelocal($second, $minute, $hour, $date, $mon, $yr);
  } else {  # e.g.  chemlms 17995  1344  0 11:04:05 ?         0:15 lms_client_USPRD259
    ($uid, $pid) = split ' ', $line;
    # Multiple pids can exist at same time so disambiguate
    $epoch_seconds_pid = $epoch_seconds . $pid;
    # TODO avoid this hack
    $epoch_seconds_pid .= " ~ $pid, $date-$month-$yr\n";
    # Push into hash keyed on epoch_seconds_pid (for sorting the hash):
###    %h = map /^(.*) - (.*)$/gm, $x;  # WRONG
    $h{ $_->[0] } = $_->[1] for [ split /~/, $epoch_seconds_pid ];
  }
}

###while ( (my $k, my $v) = each %h ) { print "$k=$v"; }

my @sorted;

foreach my $k ( sort keys %h ) { 
  push @sorted, $h{$k} ;
}

###require Data::Dumper; print STDERR "The hash is ", Data::Dumper::Dumper( %h ), "\n";

%seen = ();
@uniq = ();
for my $item ( @sorted ){
  unless ( $seen{$item} ) {
    $seen{$item} = 1;
    push @uniq, $item;
  }
}

open FH2, '>limslogins.parsed.txt' or die "Error: $0: $!";
print FH2 "@uniq\n";

print "debug @uniq\n";


__END__

# Graph it in R:

$ startxwin

$ R

f <-function() {
  lims <-read.table('limslogins.parsed.txt', header=F, sep=',')
  ts <-strptime(lims$V2, format='%d-%b-%Y')
  lims2 <-data.frame(lims, ts)
  d <-lims2$ts
  d.freq <-table(d)
  barplot(d.freq, main='ChemLMS Logins', ylab='Login Count', col='#FFA500', border='gray', cex.axis=0.8, cex=0.8, col.lab=gray(.8), density=50)
}



__DATA__
Fri, Nov 01, 2013 07:25:48
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:28:06
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:30:23
    root  4726  1344  0 07:29:15 ?         0:00 lms_client 600000000 chemlms
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:32:41
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:34:58
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:37:16
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:39:33
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:41:51
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:44:08
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:46:26
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:48:43
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:51:01
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:53:18
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:55:35
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 07:57:53
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 08:00:10
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 08:02:28
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259

Fri, Nov 01, 2013 08:04:45
 chemlms  4726  1344  0 07:29:15 ?         0:15 lms_client_USPRD259
 chemlms  3602  1344  0 15:40:38 ?         0:15 lms_client_USPRD259


output:

  3602, 01-Nov-2013
  4726, 01-Nov-2013
