#!/usr/bin/perl
##############################################################################
#     Name: regex_test.pl
#
#  Summary: Test regular expressions when this is not sufficient:

#             $ perl -e 'print "found" if "a"=~/[^1-9]/'
#
#  Created: Fri 08 Jul 2016 09:32:17 (Bob Heckel)
##############################################################################

###$subfolder='RFD';
###$subfolder='Immunizations';
###$subfolder='Imports';
###print "found" if "/Drugs/RFD/2016/02/an.3008/Dataset"=~/Drugs\/RFD\/\d+\/\d+\/AN.*\/Datasets?/i;
###print "found" if "/Drugs/RFD/2016/02/an.3008/Dataset/d_quinaprilhyd.sas7bdat"=~/Drugs\/RFD\/\d+\/\d+\/AN.*\/Dataset/i;
###print "found" if "/Drugs/RFD/2016/02/an.3008/Dataset/d_quinaprilhyd.sas7bdat"=~/\/$subfolder\/\d{4}\/\d{2}\/AN.*\/Dataset/i;
###print "found" if "/Drugs/Immunizations/GiantEagle/Imports/20160817/Data" =~ /\/Immunizations\/.*\/$subfolder\/\d{8}\/Data/i;

###$subfolder='Tasks';
###print "found" if "/Drugs/HealthPlans/Freds/SilverScript/Tasks/20160922"             =~ /\/HealthPlans\/.*$subfolder\/\d{8}/i;
###print "found" if "/Drugs/HealthPlans/UnitedHealthcare/Medicare/Tasks/20160914/Data" =~ /\/HealthPlans\/.*$subfolder\/\d{8}/i;

###$subfolder='Orig';
###print "found" if "/Drugs/RFREval/Freds/2016/20160606/Orig" =~ m!/Drugs/RFREval/\w+/\d{4}/\d{8}/Orig!i;
###print "found" if "/Drugs/RFREval/Freds/2016/20160606/Orig" =~ /\/Drugs\/RFREval\/\w+\/\d{4}\/\d{8}\/Orig/i;

###$subfolder='Dataset';
###print "found" if "/Drugs/RFREval/Freds/2016/20160606/Dataset" =~ /\/Drugs\/RFREval\/\w+\/\d{4}\/\d{8}\/Dataset/i;

###$x='B@@b_test-1';
###($y = $x) =~ s/[^A-z-_]+//g;
###print "ok $y";

###$subfolder='Kmart';
###print "found" if "/Drugs/RFREval/Kmart/2016/20161205/Orig" =~ /\/Drugs\/RFREval\/$subfolder\/\d{4}\/\d{8}\/Orig/i;
###print "found" if "/Drugs/RFREval/Kmart/2016/20161205/OrigData" =~ /\/Drugs\/RFREval\/$subfolder\/\d{4}\/\d{8}\/Orig$/i;

###$subfolder='Freds';
###print "found" if "/Drugs/RFREval/Freds/2016/20161005/Orig" =~ /\/Drugs\/RFREval\/$subfolder\/\d{4}\/\d{8}\/Orig/i;

# $subfolder='GiantEagle';
# print "found" if "/Drugs/RTS/Monthly/GiantEagle/2017/201701/Datasets" =~ /\/Drugs\/RTS\/Monthly\/$subfolder\/\d{4}\/\d{6}\/Datasets/i;

# $subfolder='GiantEagle';
# print "found" if "/Drugs/RTS/Monthly/GiantEagle/2017/201712/Datasets" =~ /\/Drugs\/RTS\/Monthly\/$subfolder\/\d{4}\/\d{6}\/(Datasets|QC_Analysis)/i;
# print "found" if "/Drugs/RTS/Monthly/GiantEagle/2017/201712/QC_Analysis" =~ /\/Drugs\/RTS\/Monthly\/$subfolder\/\d{4}\/\d{6}\/(Datasets|QC_Analysis)/i;

# $subfolder='Walgreens';
# print "found" if "/Drugs/TMMEligibility/Walgreens/DigitalDaily/20170826/Data" =~ /\/Drugs\/TMMEligibility\/$subfolder\/DigitalDaily\/\d{8}\/Data/i;

$subfolder='ActionList';
print "found" if "/Drugs/HealthPlans/UnitedHealthcare/Medicare/ActionList/20170907"             =~ /\/HealthPlans\/.*$subfolder\/\d{8}/i;
