#!/usr/bin/perl -w
##############################################################################
#     Name: sumnetworkfiles.pl
#
#  Summary: Sum filesizes by user (using 'dir /Q /S' output).
#
#           See also list_networkfiles.pl
#
#  Created: Wed 10 Dec 2003 16:30:07 (Bob Heckel)
##############################################################################

ByteSum('bhb6', 'Brenda');
ByteSum('bqh0', 'Bob');
ByteSum('ekm2', 'Erica');
ByteSum('tbe2', 'Teresa');
ByteSum('kjk4', 'Kryn');
ByteSum('hdg7', 'Heather');


sub ByteSum {
  $u = shift;
  $uname = shift;

  ###open FH, 'icabinetstsb' or die "Error: $0: $!";
  open FH, '/home/bqh0/tmp/testing/junklst' or die "Error: $0: $!";

  $bytes = 0;

  while ( <FH> ) {
    next if /^\s*$/;
    next if /<DIR>/;
    next unless m/NCHS\\$u/;
    # De-commafy
    s/,*//g;
    # Assuming the size starts somewhere after column 20.
    /^.{20}\s*(\d+)/;
    $bytes += $1;
  }
  # Re-commafy
  $bytes =~ s/(\d{1,3})(?=(?:\d\d\d)+(?!\d))/$1,/g;
  printf "%15s (%s):    %11s bytes\n", $uname, $u, $bytes;

  close FH;

  return 0;
}


# Tot s/b 23,103,039
__END__

I:\CABINETS\TSB
02/07/2001  16:11       <DIR>          NCHS\bhb6              NAPHSIS
02/07/2001  16:17               86,156 NCHS\bhb6              NATD0201.123
02/24/2003  10:19       <DIR>          NCHS\bhb6              User Guides
04/03/2001  17:37               88,064 NCHS\bhb6              CHART2.XLS
04/09/2002  17:41       <DIR>          NCHS\bhb6              PPT
08/07/2000  10:00       <DIR>          NCHS\bhb6              XCELDEV
09/24/2003  07:19            3,866,211 NCHS\bhb6              io2002.txt
09/24/2003  07:42            4,649,889 NCHS\bhb6              io2001.txt
12/04/2003  15:41       <DIR>          NCHS\bhb6              EXCEL

I:\CABINETS\TSB\AS Data Files\AS 2001 & 2002
04/09/2002  14:05              678,550 NCHS\bhb6              ASALL01.TXT

I:\CABINETS\TSB\EXCEL
01/21/2003  09:22       <DIR>          NCHS\bhb6              MIS99
05/21/2002  05:18              159,232 NCHS\bhb6              NHOUSE00.XLS
07/09/2001  15:29               21,184 NCHS\bhb6              VI2000.TXT
07/09/2001  15:31               21,274 NCHS\bhb6              VI2000.CSV
08/15/2002  08:24            8,206,697 NCHS\bhb6              FORCELIA
08/22/2002  17:41            5,294,550 NCHS\bhb6              OCCP
10/01/2001  15:21               31,232 NCHS\bhb6              CAGE50.XLS
11/28/2001  14:22       <DIR>          NCHS\bhb6              GPHMIS02
12/04/2003  00:51       <DIR>          NCHS\bhb6              MIS01
12/04/2003  00:51       <DIR>          NCHS\bhb6              MIS02
12/04/2003  15:26       <DIR>          NCHS\bhb6              DAEBPG
12/14/2000  16:12       <DIR>          NCHS\bhb6              GPHMIS01
