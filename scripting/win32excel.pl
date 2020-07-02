#!/usr/bin/perl -w
##############################################################################
#     Name: win32excel.pl
#
#  Summary: Use perl to control Excel workbooks.
#
# Adapted: Thu 04 Oct 2001 10:06:27 (Bob Heckel --
#             http://www-106.ibm.com/developerworks/linux/library/l-pexcel/)
# Modified: Tue 02 Aug 2005 15:47:35 (Bob Heckel)
##############################################################################
use strict;
use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';

$Win32::OLE::Warn = 3;   # die on errors

# Get already active Excel application or open new.
# But in this demo, the spreadsheet must exist prior to running.
my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
                              || Win32::OLE->new('Excel.Application', 'Quit');  

my $Book = $Excel->Workbooks->Open('c:\install\Book1.xls'); 

# You can dynamically obtain the number of worksheets, rows, and columns
# through the Excel OLE interface.  Excel's Visual Basic Editor has more
# information on the Excel OLE interface.  Here we just use the first
# worksheet, rows 1 through 4 and columns 1 through 3.

# Select worksheet number 1 (you can also select a worksheet by name).
my $Sheet = $Book->Worksheets(1);

$Sheet->Cells(2, 1)->{'Value'} = "Freshly added by $0";
$Sheet->Cells(3, 1)->{'Value'} = "=40+2";
# Excel will prompt you to Save unless this line is used.
$Book->SaveAs('c:\install\Book2.xls');

# ...finished with modifying the spreadsheet, now extract data from it...

foreach my $row ( 1..4 ) {
 foreach my $col ( 1..3 ) {
   # Skip empty cells.
   next unless defined $Sheet->Cells($row,$col)->{'Value'};
   # Print out the contents of a cell.
   printf "At ($row, $col) value is %s and formula is %s\n",
   $Sheet->Cells($row, $col)->{'Value'},
   $Sheet->Cells($row, $col)->{'Formula'};        
 }
}

$Book->Close;
