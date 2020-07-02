#!/usr/bin/perl -w
##############################################################################
#     Name: disconnect_timed.pl (s/b symlinked as ~/bin/disc)
#
#  Summary: Force a W2K modem dialup disconnect after a certain number of
#           minutes.
#
#           TODO make connectoid default to active one
#
#           Alternative:
#           $ rasdial     <---determine connectoid
#           $ wget -c http://foo.com/getme.mp3 ; rasdial "my connectoid" /d
#
#           $ wget -c http://foo.com/getme.mp3 ; disc -m1
#
#  Created: Sat 24 Jan 2004 17:45:41 (Bob Heckel)
# Modified: Tue 18 Jan 2005 22:44:30 (Bob Heckel)
##############################################################################
use strict;
use Getopt::Std;

my %h;
getopts('m:', \%h);

# There are two spaces in my connectoid name
###my $connectoid = 'Intergate Raleigh  645-1026';
my $connectoid = 'Connection to 645-1026';

die "Usage: disc -m10\nDisconnects from dialup $connectoid in -m mins\n" 
  if ! defined $h{m};

my $discmins = $h{m};

my $t = time;
my $disctime = $t + ($discmins * 60);

# Display current connection for user to verify (visually only for now).
print "#### START rasdial output ####\n";
system('rasdial');
print "##### END rasdial output #####\n\n";
print "disconnecting from $connectoid in $discmins minutes...\n";
system('date');

while ( 1 ) {
  if ( $t >= $disctime ) {
    system("rasdial '$connectoid' \/d") == 0 or die "Cannot disconnect\n";
    system('date');  # timestamp the end
    exit 0;
  } else {
    sleep 60;  # seconds
    $t = time;
  }
}

exit 1;  # shouldn't reach

