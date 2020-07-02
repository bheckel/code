#!/usr/bin/perl -w
####################################################################################
#  SAVED AS:               /Drugs/Cron/Weekly/ArchiveOldFiles/archive_tmmeligibility_imports.pl
#                                                                         
#  CODED ON:               12-Feb-16 by bheckel
#                                                                         
#  DESCRIPTION:            Process TMM Imports folders
#
# If a file in Imports/.../Data is older than 90 days then compress and move it to /Drugs/Archive unless it is:
#   a.   rxfilldata.sas7bdat, in that case delete it
#   b.   rxtotal.sas7bdat, in that case delete it
#                                                                           
#  PARAMETERS:              
#
#  LAST REVISED:                                                          
#   12-Feb-16 (bheckel)  Initial cron is in DEBUG mode, doing manual runs until
#                        reliability is confirmed
#   2016-04-22 (bheckel) Running non-debug
####################################################################################
use strict;
use File::Find;

# 1 == dryrun, do not execute system 
my $debugflag = 1;
# For interactive debugging
my $sleepsec = 5;

my $dir = "/Drugs/TMMEligibility";
my $archive_dir = "/Drugs/Archive";
my $daysold = 90;

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
find(\&Fnd, "$dir/");


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

   if ( $file =~ /\/Imports\/\d+\/Data/ ) {
     if ( ! -d $file && -M $file > $daysold ) {
       print ">>FOUND: "; system "ls -g $file";
       sleep $sleepsec;
       if ( $file =~ /rxfilldata.sas7bdat|rxtotal.sas7bdat/ ) {
         print ">>>PROCESS: rm $file\n";
         sleep $sleepsec;
         system "rm -v $file" unless $debugflag;
         print "\n";
       } else {
         print ">>>PROCESS: gzip $file\n";
         sleep $sleepsec;
         # TODO handle files with spaces
         system "nice -n19 gzip --best $file" if $file !~ / / and not $debugflag;

         print ">>>>PROCESS: mkdir -p ${archive_dir}${stem}\n";
         sleep $sleepsec;
         system "mkdir -p ${archive_dir}${stem}" if $file !~ / / and not $debugflag;

         print ">>>>>PROCESS: mv $file.gz ${archive_dir}${stem}\n";
         sleep $sleepsec;
         system "mv -i $file.gz ${archive_dir}${stem}\n" if $file !~ / / and not $debugflag;

         # Try but may not be empty yet, failure is ok
         print ">>>>>>PROCESS: rmdir -p --ignore-fail-on-non-empty $stem\n";
         sleep $sleepsec;
         system "rmdir -p --ignore-fail-on-non-empty $stem" if $file !~ / / and not $debugflag;

         print "\n";
       }
     }
   }
}
