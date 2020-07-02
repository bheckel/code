#!/usr/bin/perl -w
##############################################################################
#     Name: parse_vnetlog.pl
#
#  Summary: Summarize data in /var/local/vnet_usage_log
#
#           Assuming this will be run Monday mornings. 
#
#  Created: Mon 22 Jul 2002 14:50:55 (Bob Heckel)
# Modified: Fri 26 Jul 2002 08:39:46 (Bob Heckel) 
##############################################################################
use Time::Local;  # for timelocal()

use constant SECSPERDAY =>  24 * 60 * 60;
use constant SECSPERWK  =>  24 * 60 * 60 * 7;
use constant DAYSINWK   =>  7;
# Used to convert to numbers for timelocal().
my %mo = (
  'Jan' =>  0,
  'Feb' =>  1,
  'Mar' =>  2,
  'Apr' =>  3,
  'May' =>  4, 
  'Jun' =>  5,
  'Jul' =>  6,
  'Aug' =>  7,
  'Sep' =>  8,
  'Oct' =>  9,
  'Nov' =>  10,
  'Dec' =>  11,
);
my $statistician = ();
$statistician{arouse}   = 'Adrienne Rouse';
$statistician{bgreen}   = 'Brenda Green';
$statistician{bqh0}     = 'Bob Heckel';
$statistician{djustice} = 'David Justice';
$statistician{fwinter}  = 'Francine Winter';
$statistician{jjustice} = 'Jenny Justice';
$statistician{mtrotter} = 'Margy Trotter';
$statistician{vnetusr}  = 'Test User';

my $seven_days_ago = time - (DAYSINWK * SECSPERDAY);
my $fourteen_days_ago = time - (DAYSINWK * 2 * SECSPERDAY);

if ( @ARGV && $ARGV[0] =~ /-+h.*/ ) {
  print STDERR "Usage: $0\n       Summarizes Vitalnet usage log statistics\n";
  exit(__LINE__);
}

open FILE, "/var/local/vnet_usage_log" || die "$0: can't open file: $!\n";
my $usercount_alltime = 0;
my $usercount_twowksago = 0;
my $usercount_onewkago = 0;
my %users = ();
while ( <FILE> ) {
###while ( <DATA> ) {
  #      User: bqh0  logged in at: Thu  Jul    11    09:00:08      2002
  if ( m/User: (\w+) logged in at: \w+ (\w+) (\d+) \d\d:\d\d:\d\d (\d+)/ ) {
    # DEBUG
    next if $1 eq 'vnetusr';  # skip the test user accesses
    $usercount_alltime++;
    if ( (timelocal(0, 0, 0, $3, $mo{$2}, $4)) >= $fourteen_days_ago ) {
      if ( (timelocal(0, 0, 0, $3, $mo{$2}, $4)) < $seven_days_ago ) {
        $usercount_twowksago++;
      }
    }
    if ( (timelocal(0, 0, 0, $3, $mo{$2}, $4)) >= $seven_days_ago ) {
      $users{lc $1}++;        # track logins by user
      $usercount_onewkago++;  # count number of logins
    }
  }
}
close FILE;


$dateonly = localtime scalar $seven_days_ago; 
# Remove unwanted 00:00:00  
# TODO get rid of it more gracefully than this
$dateonly =~ s/\d\d:\d\d:\d\d//;

# ------------ Start Output Section ----------------
print "Vitalnet Usage for the Week of $dateonly\n";
# DEBUG
# Verbose mode:
###while ( ($key, $value) = each %users ) {
###  printf("%17s: %3d access%s\n", $statistician{$key},
###                                $value,
###                                $value == 1 ? "" : "es",);
###}

print "$usercount_onewkago accesses last week\n";

print "$usercount_twowksago accesses two weeks ago\n";
 
# Average since July 15 2002:
my $wks_since_incept = int((time - 1026172920) / SECSPERWK);
my $avg_accesses = int($usercount_alltime / $wks_since_incept);
print "Average accesses per week since July 15 2002:  $avg_accesses\n";


__DATA__
User: bqh0 logged in at: Thu Jul 10 09:00:08 2002
User: vnetusr logged in at: Thu Jul 11 09:35:57 2002
User: djustice logged in at: Tue Jul 16 08:36:39 2002
User: vnetusr logged in at: Mon Jul 22 10:17:53 2002
User: vnetusr logged in at: Mon Jul 22 13:53:33 2002
User: djustice logged in at: Tue Jul 23 13:14:35 2002
User: jjustice logged in at: Tue Jul 24 13:46:52 2002
User: fwinter logged in at: Tue Jul 18 13:46:52 2002
User: fwinter logged in at: Tue Jul 22 13:46:52 2002
User: fwinter logged in at: Tue Jul 23 13:46:52 2002
