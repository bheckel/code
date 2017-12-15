#!/usr/bin/perl
##############################################################################
#     Name: spreadsheetSQLinserts.pl
#
#  Summary: Parse a tab delim file (or converted-to-text spreadsheet) and 
#           create SQL INSERT INTO statements that can be run by SQL*Plus.  DO
#           NOT USE TOAD!
#
#           Output e.g.:
#           ...
#           INSERT INTO pks_extraction_control (METH_VAR_NM,METH_SPEC_NM,COLUMN_NM,PKS_EXTRACTION_MACRO,PKS_FORMAT,PKS_LAB_TST_DESC,MFG_LOWER_SPEC_LIMIT,MFG_UPPER_SPEC_LIMIT,STABILITY_LOWER_SPEC_LIMIT,STABILITY_UPPER_SPEC_LIMIT,PROD_GRP,PROD_NM,MFG_SPEC_TXT_A,STABILITY_SPEC_TXT_A,PKS_EXTRACTION_CNTRL_NOTES_TXT) VALUES ('Minimum','GENCUBYTPW','Ziagen Tablets','SRNVLIM','1','Individual Minimum Content','95.0','105.0','90.0','110.0','Solid Dose','Ziagen Tablets','Complies with the current USP requirements for content uniformity','Complies with the current USP requirements for content uniformity','Gen - Content Uniformity');
#           ...
#
#
#           $ ./spreadsheetSQLinserts.pl > junk.sql
#
#           but may need to run 
#            :,$:s:"':':gc 
#            :,$:s:'":':gc 
#            :,$:s:"":":gc 
#           on junk.sql to cleanup Excel's doublequoting mess - you'll know
#           when oracle spews errors after this command runs:
#           
#           $ sqlplus pks_user/pksu409@usprd409 @c:/cygwin/home/bheckel/code/perl/junk
#
#           Should see "1 row created." for each successful insert.
#           When you manually exit sqlplus it should autocommit (but you can do a
#           ROLLBACK; if the inserts failed)
#
#           Probably should 1st do a delete query on the meth_spec_nm you're 
#           going to replace.
#
#
#  Created: Fri 17 Nov 2006 11:25:30 (Bob Heckel)
# Modified: Tue 28 Aug 2007 14:09:52 (Bob Heckel)
##############################################################################
use strict;
use warnings;

# EDIT
my $tbl = 'pks_extraction_control';     # database table

my @hdr;                                # static header line (see __DATA__)
my @dat;                                # data line for each record
my $n;                                  # num of fields

while ( <DATA> ) {
  s/[\r\n]+$//;
  my %h = ();

  if ( $. == 1 ) {
    @hdr = split('\t', $_);
    $n = scalar @hdr-1;
    next;
  }

  @dat = split('\t', $_);

  # Hash for this record e.g. $h{METH_SPEC_NM} = 'GENCUBYTPW'
  for ( 0 .. $n ) {
    $h{$hdr[$_]} = $dat[$_];
  }

  print "INSERT INTO $tbl (";
  for ( 0 .. $n ) {
    # Don't INSERT INTO where there is no data to be added
    if ( $h{$hdr[$_]} ne '' ) {
      if ( $_ < $n ) {
       print "$hdr[$_],";
      } else {
       print "$hdr[$_]";
      }
    }
  }
  print ') VALUES (';
  for ( 0 .. $n ) {
    # Don't VALUES where there is no data to be added
    if ( $h{$hdr[$_]} ne '' ) {
      if ( $_ < $n ) {
	print "'$h{$hdr[$_]}',";
      } else {
	print "'$h{$hdr[$_]}'" if $_ == $n;
      }
    }
  }
  print ");\n\n";
}



# :se list
# These are tab-delimited (simply copy 'n' pasted entire rows in from Excel):
__DATA__
METH_SPEC_NM	METH_VAR_NM	COLUMN_NM	PKS_EXTRACTION_MACRO	PKS_VAR_NM	PKS_STAGE	PKS_PEAK	PKS_LEVEL	PKS_FORMAT	PKS_LAB_TST_DESC	MFG_LOWER_SPEC_LIMIT	MFG_UPPER_SPEC_LIMIT	STABILITY_LOWER_SPEC_LIMIT	STABILITY_UPPER_SPEC_LIMIT	PROD_GRP	PROD_NM	MFG_SPEC_TXT_A	MFG_SPEC_TXT_B	MFG_SPEC_TXT_C	STABILITY_SPEC_TXT_A	STABILITY_SPEC_TXT_B	STABILITY_SPEC_TXT_C	PKS_EXTRACTION_CNTRL_NOTES_TXT
ATM02108DOSEHPLC	Analyst$		SRChkBy											MDPI	Relenza Rotadisk	x			x			ATM02108 - Emitted Dose
ATM02108DOSEHPLC	CheckedBy$		SRChkTs											MDPI	Relenza Rotadisk	x			x			ATM02108 - Emitted Dose
ATM02108DOSEHPLC	TestDate		SRTs											MDPI	Relenza Rotadisk	x			x			ATM02108 - Emitted Dose
ATM02108DOSEHPLC	ZanamivirDoseContentMean		SRNVLim	PeakInfo		Zanamivir		1	Mean Emitted Dose					MDPI	Relenza Rotadisk	x			x			ATM02108 - Emitted Dose
ATM02108DOSEHPLC	ZanamivirIndividualsOutside20		SRNVLim	PeakInfo		Zanamivir		1	Individuals Outside 20 pct					MDPI	Relenza Rotadisk	x			x			ATM02108 - Emitted Dose
ATM02108DOSEHPLC	ZanamivirIndividualsOutside30		SRNVLim	PeakInfo		Zanamivir		1	Individuals Outside 30 pct					MDPI	Relenza Rotadisk	x			x			ATM02108 - Emitted Dose
ATM02108DOSEHPLC	PeakInfo	BtlAvg$	IRNVAL											MDPI	Relenza Rotadisk							ATM02108 - Emitted Dose
ATM02108DOSEHPLC	PeakInfo	PeakName$	IRPeak											MDPI	Relenza Rotadisk							ATM02108 - Emitted Dose
ATM02108DOSEHPLC	PeakInfo	Name$	IRDev											MDPI	Relenza Rotadisk							ATM02108 - Emitted Dose
