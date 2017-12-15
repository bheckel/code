#!/usr/bin/perl
##############################################################################
#     Name: excel2csv.pl
#
#  Summary: Convert worksheet tabs to comma separated .csv files.
#
# Adapted: Mon 03 Mar 2008 10:36:53 (Bob Heckel -
#                                    http://www.perlmonks.org/?node=153486)
# Modified: Tue 10 Jun 2008 12:43:29 (Bob Heckel)
# TODO update executable 2008-06-10 
##############################################################################
use strict;
use warnings;

use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';
use constant USAGEMSG => <<USAGE;
Usage: excel2csv inpath excelfile sheetname [outpath]
       e.g. '\\\\rtpsawn321\\d\\unit_Test_Files' Valtrex_500mg_Fielder_DIVI_BDdata.xls Granulation c:\\temp

       Replaces spaces in input spreadsheet name with underscores.
       Replaces spaces in worksheet tab names with underscores.
       Returns 1 on success.
USAGE

$Win32::OLE::Warn = 3;   # die on errors

die USAGEMSG unless @ARGV;

my $inpath = shift;
my $excelfile = shift;
my $sheetnm = shift;
my $outpath = shift;

my $newfilenm;
($newfilenm = $excelfile) =~ s/ /_/g;

my $newsheetnm;
($newsheetnm = $sheetnm) =~ s/ /_/g;

my $fqexcelIn = $inpath . '\\' . $excelfile;
my $fqexcelOut = $inpath . '\\' . $newfilenm;

my $fqcsv;

if ( $outpath ) {
    $fqcsv = $outpath . '\\' . $newfilenm . '_' . $newsheetnm . '.csv';
  } else {
    $fqcsv = $fqexcelOut . '_' . $newsheetnm . '.csv';
}



my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
                              || Win32::OLE->new('Excel.Application', 'Quit');
$Excel->{Visible} = 0;

$Excel->{DisplayAlerts} = 0; 

my $Book = $Excel->Workbooks->Open($fqexcelIn); 

my $Sheet = $Book->Worksheets("$sheetnm");

$Sheet->Activate();

$Sheet->SaveAs({Filename=>"$fqcsv", FileFormat=>xlCSV});

# Only close what we're working on, not xls that may already be open
my $rc = $Book->Close();

$Excel->{Visible} = 1;

exit $rc;
