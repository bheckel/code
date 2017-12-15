#!/usr/bin/perl -w
##############################################################################
# Program Name: ole_excel.pl 
#
#      Summary: Using Learning Perl On Win32 Systems, control Excel.
#               Multiply each number by 2.
#
#      Created: Thu Apr 15 1999 08:40:32 (Bob Heckel)
#     Modified: Tue, 11 Apr 2000 11:15:16 (Bob Heckel)
##############################################################################

use OLE;

@nums = (3,5,7,9);

$xl = CreateObject OLE "Excel.Application" || die "CreateObject: $!";
$xl->{Visible} = 1;
$xl->Workbooks->Add();
$col = "A"; 
$row = 1;

foreach $num (@nums) {
  $cell = sprintf("%s%d", $col, $row++);
  $cell2 = sprintf("%s%d", $col++, $row--);
  $xl->Range($cell)->{Value} = $num * 2;
  $xl->Range($cell2)->{Value} = $num * 2;
}

