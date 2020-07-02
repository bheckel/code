#!/bin/perl -w

####################################
# Source of input ir/sr:
###$src = '/cygdrive/k/LINKS_Site_Wide/WorkFolders/Site_Wide_Work/Loaded/chunks/';
###$src = '/home/bheckel/projects/lelimsxxxres/tmp';
###$src = '/home/bheckel/projects/bulkload/ds';
$src = '/home/bheckel/projects/CIreload/pullLIMS';

# Server (SQL_Loader\...):
###$links = '/cygdrive/x/SQL_Loader';
$links = '/cygdrive/t';
###$links = '/cygdrive/p';

# Control file of filenames (names in this file should NOT end in .zip but the
# actual files should):
$flist = '/home/bheckel/projects/CIreload/loadLINKS/filelist.txt';

# Where we run this code from (chdir to)
$limsdatadir = '/cygdrive/c/cygwin/home/bheckel/projects/CIreload/pullLIMS';
####################################


print "make sure NNN !!!\n";
print "make sure T: is mapped (if running tst) !!!\n";
print "make sure P: is mapped (if running prod) !!!\n";
print "make sure links server is set ($links) !!!\n";
print "make sure zips are correct ($src) !!!\n";
print "make sure control file is correct ($flist) !!!\n";
print "make sure lims data dir is correct ($limsdatadir) !!!\n";
print "make sure w3m is pointing to correct server !!!\n";
print "ok? press y\n";
die unless <STDIN> =~ /^y|^yes|^ok/i;


open FH, "$flist" or die "$!";

# In case box loses power, we can tell how long it ran using this and the 
# stamp below
($mon, $day, $year) = (localtime())[4,3,5];
$year += 1900;
$now = $mon . '-' . $day . '-' . $year;
open TS, ">tstamp.start.$now.txt" or die "Error: $0: $!";
print TS scalar localtime;
print TS "\n";
# ...leave it open til code finishes

local $/ = '';  # IR/SR filename pairs separated by <CR>

chdir $limsdatadir;

while ( <FH> ){
  print scalar localtime, "\n";
  chomp;
  ($ir, $sr) = split;

  # Almost out of disk space on 321 box so each file has to go 1 at a time.

  $rcuzir = system('unzip', '-jo', "$ir.zip");
  print 'unzip IR:',$rcuzir,"\n";

  # Remove prior run
  unlink "$links/lelimsindres01a.sas7bdat";

  $rccpir = system('mv', '-v', "$src/$ir", "$links/lelimsindres01a.sas7bdat");
  print 'copy IR:',$rccpir,"\n";

  die if $rcuzir or $rccpir;

  ##############

  $rcuzsr = system('unzip', '-jo', "$sr.zip");
  print 'unzip SR:',$rcuzsr,"\n";

  # Remove prior run
  unlink "$links/lelimssumres01a.sas7bdat";

  $rccpsr = system('mv', '-v', "$src/$sr", "$links/lelimssumres01a.sas7bdat");
  print 'copy SR:',$rccpsr,"\n";

  die if $rccpsr or $rcuzsr;

  ##############

  print "running llg...\n";
  # TODO can't use interpolation - w3m won't resolve link properly
  # Make sure x:/sas_web_pages/runllg.asp is pointing to the right
  # x:/sas_programs/run_sas.bat 
  ###system('w3m -no-cookie -dump_source "http://rtpsawn321/links/runllg.asp?action=Run+LLG"');
  system('w3m -no-cookie -dump_source "http://kopsawn557/sas%20validation/runllg.asp?action=Run+LLG"');
  # BE VERY CAREFUL HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # BE VERY CAREFUL HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # BE VERY CAREFUL HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # lowercase before running                                _______________________________
  ###system('w3m -no-cookie -dump_source "http://rtpsawn323/NEWGUYBOBINSANEWEBPAGEMIGHTWORK/runllg.asp?action=Run+LLG"');
  print "\n---\n";
}

# End stamp
print TS scalar localtime;
print TS "\n";
close TS;

print 'now run NYN 1 time manually';


__END__

filelist.txt: 

lelimsindres01a02.sas7bdat
lelimssumres01a02.sas7bdat

lelimsindres01a03.sas7bdat
lelimssumres01a03.sas7bdat
