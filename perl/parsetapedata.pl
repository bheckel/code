#!/usr/bin/perl
##############################################################################
#     Name: parsetapedata.pl
#
#  Summary: Parse new tape data and append to a cumulative CSV file.
#
#  Created: Sun 16 Mar 2008 19:15:42 (Bob Heckel)
##############################################################################
###use strict;
use warnings;
use POSIX qw(strftime);

use constant USAGEMSG => <<'USAGE';
Usage: parsetapedata.pl NEWCSVFILE HISTORYCSVFILE

       e.g.
       append new to existing history file: 
       $ parsetapedata.pl new.csv hist.csv

       Combines current day's NEWCSVFILE with existing HISTORYCSVFILE 
USAGE

die USAGEMSG unless @ARGV == 2;

open NEWF, "$ARGV[0]" or die "Error: $0: $!";
open HIST, "$ARGV[1]" or die "Error: $0: $!";


while ( <NEWF> ) {
  next unless m/(.*)\s*:(.*)$/;
  $newday{$1} = $2;
}
close NEWF;


while ( <HIST> ) {
  # info, 03/26/08, 03/27/08
  if ( $. == 1 ) {
    chomp;
    $hdr = $_;
    next;
  };
  #          $1                    $2
  # __________________________ _________
  # How many tapes got vaulted:9,123,9,9
  next unless m/([^:]*):(.*)$/;
  $hist{$1} = $2;
}
close HIST;


open UPDATED, ">tmp.csv" or die "Error: $0: $!";

for ( keys %hist ) {
  $hist{$_} .= ",$newday{$_}";
}

$fmtdt = strftime("%m/%d/%y", localtime);

print UPDATED "$hdr,$fmtdt\n";
while ( (my $k, my $v) = each %hist ) { 
  $v =~ s/ *//g;
  print UPDATED "$k:$v\n"; 
}
close UPDATED;

rename 'tmp.csv', 'hist.csv'; 



__END__
hist.csv:
info, 03/26/08, 03/27/08, 03/28/08,03/29/08
Total available LTO2 tapes inside the robot:89,123,89nw,89nwx
Total available LTO3 tapes:29,123,29nw,29nwx
Total Number of catalog tapes:34,123,34nw,34nwx
Total LTO2 tapes for use outside of the robot:72,123,72nw,72nwx
How many tapes are coming back from vault:8,123,8nw,8nwx
Total LTO2 tapes:706,123,706nw,706nwx
Which catalog tape was sent offsite:FS0129,F123,FS0129nw,FS0129nwx
Total number of LTO3 tapes set to infinity:0,123,0nw,0nwx
Total number of LTO3 tapes frozen:0,123,0nw,0nwx
Total available empty slots in the robot:79,123,79nw,79nwx
Total number of Max Mounted LTO3 tapes:5,123,5nw,5nwx
Total number of LTO2 tapes written to in the past 24hrs:21,123,21nw,21nwx
Total number of LTO2 tapes frozen:12,123,12nw,12nwx
How many tapes got vaulted:9,123,9nw,9nwx
Total number of expired LTO3 tapes within the past 24hrs:0,123,0nw,0nwx
Total number of LTO3 tapes written to in the past 24hrs:2,123,2nw,2nwx
Total LTO3 tapes:35,123,35nw,35nwx
How many tapes are in vault:469,123,469nw,469nwx
Total number of FULL LTO2 tapes:238,123,238nw,238nwx
Total LTO3 tapes for use outside of the robot:0,123,0nw,0nwx
Total number of expired LTO2 tapes within the past 24hrs:8,123,8nw,8nwx
Total number of LTO2 tapes set to infinity:183,123,183nw,183nwx
Total available LTO2 tapes:161,123,161nw,161nwx
Total number of Max Mounted LTO2 tapes:1,123,1nw,1nwx
Total number of FULL LTO3 tapes:0,123,0nw,0nwx
Total available LTO3 tapes inside the robot:29,123,29nw,29nwx
SID used for this past vault:925,123,925nw,925nwx

new.csv:
Total LTO2 tapes:  706
Total LTO3 tapes:  35
Total available LTO2 tapes:  161
Total available LTO3 tapes:  29
Total available LTO2 tapes inside the robot:  89
Total available LTO3 tapes inside the robot:  29
Total LTO2 tapes for use outside of the robot:  72
Total LTO3 tapes for use outside of the robot:  0
Total number of LTO2 tapes set to infinity:  183
Total number of LTO3 tapes set to infinity:  0
Total number of FULL LTO2 tapes:  238
Total number of FULL LTO3 tapes:  0
Total Number of catalog tapes:  34
Total number of expired LTO2 tapes within the past 24hrs:  8
Total number of expired LTO3 tapes within the past 24hrs:  0
Total number of LTO2 tapes frozen:  12
Total number of LTO3 tapes frozen:  0
Total number of Max Mounted LTO2 tapes:  1
Total number of Max Mounted LTO3 tapes:  5
Total number of LTO2 tapes written to in the past 24hrs:  21
Total number of LTO3 tapes written to in the past 24hrs:  2
Total available empty slots in the robot:  79
SID used for this past vault:  925
How many tapes got vaulted:  9
How many tapes are in vault:  469
How many tapes are coming back from vault:  8
Which catalog tape was sent offsite:  FS0129
