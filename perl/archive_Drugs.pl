#!/usr/bin/perl -w
####################################################################################
#  SAVED AS:            /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl
#                                                                      
#  CODED ON:            24-Jun-16 by bheckel
#                                                                      
#  DESCRIPTION:         Delete or move/compress old /Drugs files
#                       using the following specification:
#
# If a file in /Drugs/TMMEligibility/.../$subfolder/.../Data is older than n
# days then compress and move it from /Drugs/TMMEligibility/... to
# /Drugs/Archive/... unless it is:
#   a.   rxfilldata.sas7bdat, in that case delete it
#   b.   rxtotal.sas7bdat, in that case delete it
# Remove the original directory if empty.  A mirror of the original will be in 
# /Drugs/Archive/TMMEligibility
#
# If a file in /Drugs/RFD/.../$subfolder/.../Data is older than n
# days then compress and move it from /Drugs/RFD/... to
# /Drugs/Archive/...
#
# Ignores files with spaces since the spec mandates no spaces in filenames.
#
# Perl was chosen over shell or SAS due to the complexity of specifying which
# directories/subdirectories to archive.
#
# The regexes will select the longest name variations.  This is probably a
# feature e.g. Data and Dataset and Datasets, Orig and OrigData get selected.
#                                                                       
#  PARAMETERS:          Days old threshold, folder, subfolder under /Drugs
#
#  Sample call: /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 TMMEligibility Imports
#
#  LAST REVISED:                                                          
#   24-Jun-16 (bheckel) Initial see https://issues.ateb.com/browse/AN-4318
#   23-Sep-16 (bheckel) Add Immunizations toplevel (for Imports in this case)
#   16-Dec-16 (bheckel) Add HealthPlans
#   03-Jan-17 (bheckel) Add RFREval Dataset
#   12-Jan-17 (bheckel) Add RFREval Dataset & Orig per Fei
####################################################################################
# 00 13 * * 3 /sasdata/Cron/Weekly/ArchiveOldFiles/archive.sh
use strict;
use File::Find;

$ARGV[2] || die "Usage: $0 OlderThanDays ToplevelFoldername SublevelFoldername";

# EDIT CAREFULLY
# 1 is dryrun, 0 is !!!DELETE or MOVE!!!
my $debugflag = 1;
# Slow things down n seconds for interactive debugging
my $sleepsec = 0;

my $daysold = $ARGV[0];
my $folder = $ARGV[1];
my $subfolder = $ARGV[2];
my $topfolder = "/Drugs/$folder";
my $archivefolder = '/Drugs/Archive';

my @to_process;
my @fs;
my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime();
my $y = $year+1900;
my $m = $mon+1;
my $dt ="${y}${m}${day}";
my $stem = '';


# Recursive
sub Fnd {
	push @fs, $File::Find::name;
}
find(\&Fnd, "$topfolder/");


foreach my $file ( @fs ) {
  $file eq '.' || $file eq '..' or push @to_process, $file;
}


foreach my $file ( @to_process ) {
  print "DEBUG: $file\n";
   if ( -d $file ) {
     $stem = $file;
   } else {
     $file =~ m#((?:[^/]*/)*)(.*)#;
     $stem = $1;
   }

   # /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 TMMEligibility Imports
   # E.g. /Drugs/TMMEligibility/TimsPharBeav/Imports/20160421/Data/medispanchronic.sas7bdat
   # or
   # /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 TMMEligibility Projections
   # E.g. /Drugs/TMMEligibility/MediCentPhar/Projections/20160210/Data/nrx.sas7bdat
   if ( $folder eq 'TMMEligibility' and $file =~ /\/$subfolder\/\d{8}\/Data/ ) {
     if ( ! -d $file && -M $file > $daysold ) {
       if ( $file !~ / / ) {
         print "TMME FOUND: ";
         system "ls -lgh $file";
         sleep $sleepsec;

         if ( $folder eq 'TMMEligibility' and $file =~ /rxfilldata.sas7bdat|rxtotal.sas7bdat/ ) {
           # Delete, do not archive, these datasets per the spec
           print " TMME PROCESS: rm -v $file\n";
           sleep $sleepsec;
           system "rm -v $file" unless $debugflag;
           print "\n";
         } else {
           # Just archive
           print " TMME PROCESS: chmod g-s $file\n";
           system "chmod g-s $file" if not $debugflag;

           print " TMME PROCESS: gzip $file\n";
           system "nice -n19 gzip --best $file" if not $debugflag;

           print " TMME PROCESS: mkdir -p ${archivefolder}${stem}\n";
           system "mkdir -p ${archivefolder}${stem}" if not $debugflag;

           print " TMME PROCESS: mv $file.gz ${archivefolder}${stem}\n";
           system "mv $file.gz ${archivefolder}${stem}\n" if not $debugflag;

           # Try but may not be empty yet, failure is ok
           print " TMME PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
           system "rmdir -p --ignore-fail-on-non-empty $stem" if not $debugflag;

           sleep $sleepsec;
           print "\n";
         }
       } else {
         print "TMME SKIP: $file has spaces\n"
       }
     }
   }

   # /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 RFD RFD
   # E.g. /Drugs/RFD/2015/12/AN-2340/Datasets/compiled.sas7bdat
   if ( $folder eq 'RFD' and $file =~ /\/$subfolder\/\d{4}\/\d{2}\/AN.*\/Data/i ) {
     if ( ! -d $file && -M $file > $daysold ) {
       if ( $file !~ / / ) {
         print "RFD FOUND: ";
         system "ls -lgh $file";
         sleep $sleepsec;

         print " RFD PROCESS: chmod g-s $file\n";
         system "chmod g-s $file" if not $debugflag;

         print " RFD PROCESS: gzip $file\n";
         system "nice -n19 gzip --best $file" if not $debugflag;

         print " RFD PROCESS: mkdir -p ${archivefolder}${stem}\n";
         system "mkdir -p ${archivefolder}${stem}" if not $debugflag;

         print " RFD PROCESS: mv $file.gz ${archivefolder}${stem}\n";
         system "mv $file.gz ${archivefolder}${stem}\n" if not $debugflag;

         print " RFD PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
         system "rmdir -p --ignore-fail-on-non-empty $stem" if not $debugflag;

         sleep $sleepsec;
         print "\n";
       } else {
         print "RFD SKIP: $file has spaces\n"
       }
     }
   }

   # /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 Immunizations Imports
   # E.g. /Drugs/Immunizations/GiantEagle/Imports/20160921/Data/pneumovax_e1.sas7bdat
   if ( $folder eq 'Immunizations' and $file =~ /\/Immunizations\/.*\/$subfolder\/\d{8}\/Data/i ) {
     if ( ! -d $file && -M $file > $daysold ) {
       if ( $file !~ / / ) {
         print "IMMI FOUND: ";
         system "ls -lgh $file";
         sleep $sleepsec;

         print " IMMI PROCESS: chmod g-s $file\n";
         system "chmod g-s $file" if not $debugflag;

         print " IMMI PROCESS: gzip $file\n";
         system "nice -n19 gzip --best $file" if not $debugflag;

         print " IMMI PROCESS: mkdir -p ${archivefolder}${stem}\n";
         system "mkdir -p ${archivefolder}${stem}" if not $debugflag;

         print " IMMI PROCESS: mv $file.gz ${archivefolder}${stem}\n";
         system "mv $file.gz ${archivefolder}${stem}\n" if not $debugflag;

         print " IMMI PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
         system "rmdir -p --ignore-fail-on-non-empty $stem" if not $debugflag;

         sleep $sleepsec;
         print "\n";
       } else {
         print "IMMI SKIP: $file has spaces\n"
       }
     }
   }

   # /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 HealthPlans Tasks
   # E.g. /Drugs/HealthPlans/UnitedHealthcare/Medicare/Tasks/20160914/Data
   #   or /Drugs/HealthPlans/Freds/SilverScript/Tasks/20160922
   if ( $folder eq 'HealthPlans' and $file =~ /\/HealthPlans\/.*$subfolder\/\d{8}/i ) {
     if ( ! -d $file && -M $file > $daysold ) {
       if ( $file !~ / / ) {
         print "HP FOUND: ";
         system "ls -lgh $file";
         sleep $sleepsec;

         print " HP PROCESS: chmod g-s $file\n";
         system "chmod g-s $file" if not $debugflag;

         print " HP PROCESS: gzip $file\n";
         system "nice -n19 gzip --best $file" if not $debugflag;

         print " HP PROCESS: mkdir -p ${archivefolder}${stem}\n";
         system "mkdir -p ${archivefolder}${stem}" if not $debugflag;

         print " HP PROCESS: mv $file.gz ${archivefolder}${stem}\n";
         system "mv $file.gz ${archivefolder}${stem}\n" if not $debugflag;

         print " HP PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
         system "rmdir -p --ignore-fail-on-non-empty $stem" if not $debugflag;

         sleep $sleepsec;
         print "\n";
       } else {
         print "HP SKIP: $file has spaces\n"
       }
     }
   }


   # /Drugs/Cron/Weekly/ArchiveOldFiles/archive_Drugs.pl 90 RFREval Dataset Freds
   # E.g. /Drugs/RFREval/Freds/2016/20160606/Dataset
   if ( $folder eq 'RFREval' and $file =~ /\/Drugs\/RFREval\/$subfolder\/\d{4}\/\d{8}\/Dataset/i ) {
     if ( ! -d $file && -M $file > $daysold ) {
       if ( $file !~ / / ) {
         print "RFREVAL1 FOUND: ";
         system "ls -lgh $file";
         sleep $sleepsec;

         print " RFREVAL1 PROCESS: chmod g-s $file\n";
         system "chmod g-s $file" if not $debugflag;

         print " RFREVAL1 PROCESS: gzip $file\n";
         system "nice -n19 gzip --best $file" if not $debugflag;

         print " RFREVAL1 PROCESS: mkdir -p ${archivefolder}${stem}\n";
         system "mkdir -p ${archivefolder}${stem}" if not $debugflag;

         print " RFREVAL1 PROCESS: mv $file.gz ${archivefolder}${stem}\n";
         system "mv $file.gz ${archivefolder}${stem}\n" if not $debugflag;

         print " RFREVAL1 PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
         system "rmdir -p --ignore-fail-on-non-empty $stem" if not $debugflag;

         sleep $sleepsec;
         print "\n";
       } else {
         print "RFREVAL1 SKIP: $file has spaces\n"
       }
     }
   }
   # E.g. /Drugs/RFREval/Freds/2016/20160606/Orig
   if ( $folder eq 'RFREval' and $file =~ /\/Drugs\/RFREval\/$subfolder\/\d{4}\/\d{8}\/Orig/i ) {
     if ( ! -d $file && -M $file > $daysold ) {
       if ( $file !~ / / ) {
         print "RFREVAL2 FOUND: ";
         system "ls -lgh $file";
         sleep $sleepsec;
         if ( $folder eq 'RFREval' and $file =~ /sas7bdat/ ) {
           # Delete, do not archive, these datasets per the spec
           print " RFREVAL2 PROCESS: rm -v $file\n";
           sleep $sleepsec;
           system "rm -v $file" unless $debugflag;

           print " RFREVAL2 PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
           system "rmdir -p --ignore-fail-on-non-empty $stem" if not $debugflag;

           print "\n";
         } else {
           print "RFREVAL2 SKIP: $file has spaces\n"
         }
       }
     }
   }
   

}  # end of this file's processing

print "END: $topfolder $subfolder\n";
