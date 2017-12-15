#!/usr/bin/perl -w
##############################################################################
#     Name: query_win_registry.pl
#
#  Summary: Demo of querying the Windows Registry via ActiveState Perl.
#
#  Adapted: Tue 22 Jul 2003 13:36:55 (Bob Heckel -- ActiveState docs)
##############################################################################

use Win32::Registry;

my $tips;
$::HKEY_LOCAL_MACHINE->Open("SOFTWARE\\Microsoft\\Windows"
                           ."\\CurrentVersion\\Explorer\\Tips", $tips)
                                             or die "Can't open tips: $^E";
my ($type, $value);
$tips->QueryValueEx("18", $type, $value) or die "No tip #18: $^E";
print "Here's a tip: $value\n";
