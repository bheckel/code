#!/usr/bin/perl
use strict;

# Parse a spreadsheet.  Good if you want to diff 2 spreadsheets that you've
# saved into temporary textfiles.
#
# If working on single sheet workbooks, it might be easier to just copy 'n'
# paste into Vim using ;1 and ;2 then:
# vi -d 1 2

# Must install OLE-Storage_Lite-0.14.tar.gz and
# Spreadsheet-ParseExcel-0.2603.tar.gz
use Spreadsheet::ParseExcel;

die "need spreadsheet to parse" unless $ARGV[0];

my $oBook = Spreadsheet::ParseExcel::Workbook->Parse("$ARGV[0]");

my($iR, $iC, $oWkS, $oWkC);

foreach my $oWkS (@{$oBook->{Worksheet}}) {
  print "--------- SHEET:", $oWkS->{Name}, "\n";
  for ( my $iR = $oWkS->{MinRow}; defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ; $iR++ ) {
    for ( my $iC = $oWkS->{MinCol}; defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol}; $iC++ ) {
      $oWkC = $oWkS->{Cells}[$iR][$iC];
      print "( $iR , $iC ) =>", $oWkC->Value, "\n" if ( $oWkC );
    }
  }
}
