#!/usr/bin/perl -w
##############################################################################
#     Name: applyrules.copysheets.pl
#
#  Summary: Copy several workbooks into single workbook's worksheets
#
#           Bounce on EDITs
#
#           See win32excel.pl
#
#  Created: Tue 02 Aug 2005 16:08:48 (Bob Heckel)
##############################################################################
use strict;
use Win32::OLE::Const 'Microsoft Excel';

$Win32::OLE::Warn = 3;   # die on errors

# EDIT 07, AL and Alabama (TODO use variables but backslashes
# are a mess for interpolation)
my $fqfn = 'X:\BPMS\OR\Reports\Summary\Summary Report For Oregon 200509.xls';
my $fqfn2 = 'X:\BPMS\OR\Reports\Summary\Summary Report For Oregon Children Under 5 200509.xls';
my $fqfn3 = 'X:\BPMS\OR\Reports\Summary\Summary Report For Oregon Children Under 18 200509.xls';
my $fqfn4 = 'X:\BPMS\OR\Reports\Summary\Summary Report For Oregon Adults 18 to 64 200509.xls';
my $fqfn5 = 'X:\BPMS\OR\Reports\Summary\Summary Report For Oregon Elderly 65 and Older 200509.xls';
my $fqfn6 = 'X:\BPMS\OR\Reports\Summary\Prescriber Data Report For Oregon All Ages 200509.XLS';
my $fqfn7 = 'X:\BPMS\OR\Reports\Summary\Oregon Patients On Concurrent Drugs All Ages 200509.xls';


my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
                              || Win32::OLE->new('Excel.Application', 'Quit');
$Excel->{Visible} = 1;
###$Excel->{DisplayAlerts}=0; 

my $BookA = $Excel->Workbooks->Open("$fqfn"); 
my $BookB = $Excel->Workbooks->Open("$fqfn2"); 
my $BookC = $Excel->Workbooks->Open("$fqfn3"); 
my $BookD = $Excel->Workbooks->Open("$fqfn4"); 
my $BookE = $Excel->Workbooks->Open("$fqfn5"); 
my $BookF = $Excel->Workbooks->Open("$fqfn6"); 
my $BookG = $Excel->Workbooks->Open("$fqfn7"); 

# Syntax in VB:
# Sheets("bobh").Copy After:=Workbooks("sumspd.xls").Sheets(7)
$BookB->Sheets(1)->Copy({After => $BookA->Sheets(1)});
$BookA->Sheets(2)->{Name} = 'Children under 5';
$BookB->Close;

$BookC->Sheets(1)->Copy({After => $BookA->Sheets(2)});
$BookA->Sheets(3)->{Name} = 'Children under 18';
$BookC->Close;

$BookD->Sheets(1)->Copy({After => $BookA->Sheets(3)});
$BookA->Sheets(4)->{Name} = 'Adults';
$BookD->Close;

$BookE->Sheets(1)->Copy({After => $BookA->Sheets(4)});
$BookA->Sheets(5)->{Name} = 'Elderly';
$BookE->Close;

# EDIT
$BookF->Sheets(1)->Copy({After => $BookA->Sheets(5)});
###$BookA->Sheets(6)->{Name} = 'Prescriber Detail Report';
$BookA->Sheets(6)->{Name} = 'Prescriber Detail Rpt-All Ages';  # id
###$BookA->Sheets(6)->{Name} = 'Prescriber Detail - All Ages';  # mo
###$BookA->Sheets(6)->{Name} = 'Prescriber Detail Rpt';  # mi
###$BookA->Sheets(6)->{Name} = 'Prescriber Detail Rpt - All Age';  # al
$BookF->Close;

# EDIT
$BookG->Sheets(1)->Copy({After => $BookA->Sheets(6)});
###$BookA->Sheets(7)->{Name} = 'Concurrent Drug Use';
###$BookA->Sheets(7)->{Name} = 'Concurrent Drugs-All Ages';
###$BookA->Sheets(7)->{Name} = 'Concurrent Drugs - All Ages';  # mo
###$BookA->Sheets(7)->{Name} = 'Concurrent Drug - All Ages';  # wi
###$BookA->Sheets(7)->{Name} = 'Michigan Patients on Concurrent';  # mi
###$BookA->Sheets(7)->{Name} = 'Concurrent Drug Use - All Ages';  # al
$BookA->Sheets(7)->{Name} = 'Concurrent Drug Use-All Ages';  # de
###$BookA->Sheets(7)->{Name} = 'Idaho Patients On Concurrent';  # id
$BookG->Close;


# DEBUG toggle
###$Book->SaveAs('c:\install\Book3.xls');
###$BookA->Save;
