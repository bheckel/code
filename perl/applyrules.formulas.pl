#!/usr/bin/perl -w
##############################################################################
#     Name: applyrules.formulas.pl
#
#  Summary: Populate cell formulas.
#
#           See win32excel.pl
#
#  Created: Tue 02 Aug 2005 16:08:48 (Bob Heckel)
##############################################################################
use strict;
use Win32::OLE::Const 'Microsoft Excel';

$Win32::OLE::Warn = 3;   # die on errors

###my $fqfn = 'c:/temp/sumspd.xls';
# TODO handle spaces in fname
# EDIT VA Virginia 07  this is the only edit
my $fqfn = 'X:/BPMS/SD/Reports/Summary/Summary Report For South Dakota 200509.xls';
###my $basefn = $1 if $fqfn =~ m|[/\\:]+([^/\\:]+)$|;
###my $rc = `cp -v $fqfn $ENV{HOME}/tmp/${basefn}.bak`;
###print "backup to $ENV{HOME}/tmp/ complete\n" if $rc;

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
                              || Win32::OLE->new('Excel.Application', 'Quit');  
# DEBUG toggle
$Excel->{Visible} = 1;

my $Book = $Excel->Workbooks->Open("$fqfn"); 
# TODO not working, guess it need FQ path
###my $Book = $Excel->Workbooks->Open($ARGV[0]); 

my $Sheet = $Book->Worksheets(1);

for ( 8..16 ) {
  #           row  col
  $Sheet->Cells($_, 12)->{'Formula'} = "=('Children Under 18'!B$_+Adults!B$_+Elderly!B$_)-B$_";
  $Sheet->Cells($_, 13)->{'Formula'} = "=('Children Under 18'!D$_+Adults!D$_+Elderly!D$_)-D$_";
  $Sheet->Cells($_, 14)->{'Formula'} = "=('Children Under 18'!E$_+Adults!E$_+Elderly!E$_)-E$_";
}

for ( 24..75 ) {
  $Sheet->Cells($_, 12)->{'Formula'} = "=('Children Under 18'!B$_+Adults!B$_+Elderly!B$_)-B$_";
  $Sheet->Cells($_, 13)->{'Formula'} = "=('Children Under 18'!D$_+Adults!D$_+Elderly!D$_)-D$_";
  $Sheet->Cells($_, 14)->{'Formula'} = "=('Children Under 18'!E$_+Adults!E$_+Elderly!E$_)-E$_";
  $Sheet->Cells($_, 15)->{'Formula'} = "=('Children Under 18'!H$_+Adults!H$_+Elderly!H$_)-H$_";
  $Sheet->Cells($_, 16)->{'Formula'} = "=('Children Under 18'!I$_+Adults!I$_+Elderly!I$_)-I$_";
}

