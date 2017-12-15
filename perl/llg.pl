#!/bin/perl -w

# run from bulkload/ds !!!

local $/ = '';  # IR/SR filename pairs separated by <CR>

# Control file of filenames:
###open FH, '/home/bheckel/projects/bulkload/junk' or die "Error: $0: $!";
open FH, '/home/bheckel/projects/bulkload/filelist2006_2007.llg.txt' or die "$!";

# Source of ir/sr:
###$src = '/cygdrive/k/LINKS_Site_Wide/WorkFolders/Site_Wide_Work/Loaded/chunks/';
###$src = '/home/bheckel/projects/lelimsxxxres/tmp';
$src = '/home/bheckel/projects/bulkload/ds';

# Server:
$links = '/cygdrive/p';


while ( <FH> ){
  print scalar localtime, "\n";
  chomp;
  ($ir, $sr) = split;

  # Almost out of disk space on 321 box so each file has to go 1 at a time.

  $rcuzir = system('unzip', '-jo', "$ir.zip");
  print 'unzip IR:',$rcuzir,"\n";

  unlink "$links/lelimsindres01a.sas7bdat";

  $rccpir = system('cp', '-v', "$src/$ir", "$links/lelimsindres01a.sas7bdat");
  print 'copy IR:',$rccpir,"\n";

  unlink "$ir";

  die if $rcuzir or $rccpir;

  ######

  $rcuzsr = system('unzip', '-jo', "$sr.zip");
  print 'unzip SR:',$rcuzsr,"\n";

  unlink "$links/lelimssumres01a.sas7bdat";

  $rccpsr = system('cp', '-v', "$src/$sr", "$links/lelimssumres01a.sas7bdat");
  print 'copy SR:',$rccpsr,"\n";

  unlink "$sr";

  die if $rccpsr or $rcuzsr;

  ######

  print "running llg...\n";
  ###system('w3m -no-cookie -dump_source "http://rtpsawn321/links/runllg.asp?action=Run+LLG"');
  ###system('w3m -no-cookie -dump_source "http://kopsawn557/sas%20validation/runllg.asp?action=Run+LLG"');
  system('w3m -no-cookie -dump_source "http://rtpsawn323/newguybobinsanewebpagemightwork/runllg.asp?action=Run+LLG"');
  print "\n---\n";
}
