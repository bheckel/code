#!/usr/bin/perl
##############################################################################
#     Name: applyrules.pagesetup.pl
#
#  Summary: Format for printing
#
#           TODO not applying, use VBA for now (applyrules.pagesetup.bas)
#
#  Adapted: Tue 09 Aug 2005 16:55:25 (Bob Heckel --
#  http://www.perlmonks.org/?node=153486)
##############################################################################
use strict;
use warnings;

use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';
use Win32::OLE::Variant;

$Win32::OLE::Warn = 3;   # die on errors

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
                              || Win32::OLE->new('Excel.Application', 'Quit');
$Excel->{Visible} = 1;

my $vtfalse =  Variant(VT_BOOL, 0);
my $vttrue =  Variant(VT_BOOL, 1);
my $BookA = $Excel->Workbooks->Open('X:\BPMS\UT\Reports\Summary\Summary Report For Utah 200506.xls');

with ($BookA->Sheets(1)->PageSetup,
      'LeftHeader' => "",
      'CenterHeader' => "",
      'RightHeader' => "",
      'LeftFooter' => "",
      'CenterFooter' => "",
      'RightFooter' => "",
      'PrintHeadings' => $vtfalse,
      'PrintGridlines' => $vtfalse,
      'PrintComments' => xlPrintNoComments,
      'PrintQuality' => 600,
      'CenterHorizontally' => $vttrue,
      'CenterVertically' => $vtfalse,
      'Orientation' => xlLandscape,
      'Draft' => 'False',
      'PaperSize' => xlPaperLetter,
      'FirstPageNumber' => xlAutomatic,
      'Order' => xlDownThenOver,
      'BlackAndWhite' => $vtfalse,
      'Zoom' => $vtfalse,
      'FitToPagesWide' => 1,
      'FitToPagesTall' => 2,
      'PrintErrors' => xlPrintErrorsDisplayed),
      ; 
