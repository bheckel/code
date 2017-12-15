#!/usr/bin/perl -w
##############################################################################
#     Name: runsascon.pl
#
#  Summary: Run SAS Connect without the GUI.  For LMIT coworkers.
#
#  Created: Fri 19 Sep 2003 09:10:32 (Bob Heckel)
##############################################################################
use strict;
$|++;

# To hold SAS Connect script text:
my $conn;
my $discon;

die "Usage: $0 sascode.sas [num lines JCL to omit]\n" unless $ARGV[0];


open SASCODE, "$ARGV[0]" or die "Error: $0: $!";
open TMPF, '>tmp.sas' or die "Error: $0: $!";
open CONNECT, '<connect.sas' or die "Error: $0: $!";
open DISCONNECT, '<disconnect.sas' or die "Error: $0: $!";


{ local $/ = undef;
  $conn = <CONNECT>;
}
close CONNECT;

{ local $/ = undef;
  $discon = <DISCONNECT>;
}
close DISCONNECT;


print TMPF $conn;

while ( <SASCODE> ) {
  if ( $ARGV[1] ) {
    next if $. < $ARGV[1];
  }
  print TMPF;
}

print TMPF $discon;

close SASCODE;
close TMPF;

system "c:/PROGRA~1/SASINS~1/SAS/V8/sas.exe -sysin tmp.sas -altlog tmp.log -print tmp.lst";

open LST, 'tmp.lst' or die "Error: $0: $!";
my $lst;
{ local $/ = undef;
  $lst = <LST>;
}
close LST;

open LOG, '>>tmp.log' or die "Error: $0: $!";
print LOG $lst;
close LOG;

system "notepad tmp.log";

