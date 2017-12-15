#!/usr/bin/perl -w
##############################################################################
#    Name: struct.pl
#
# Summary: C struct like implementation in Perl.
#
# Adapted: Tue, 23 Jan 2001 14:02:36 (Bob Heckel -- from perltoot)
##############################################################################

$hashref = {
   NAME  => "Jason",
   AGE   => 23,
   PEERS => [ "Norbert", "Rhys", "Phineas" ],
};


print $hashref->{NAME};
print "\n";

print $hashref->{AGE};
print "\n";

print @{$hashref->{PEERS}};
print "\n";

print ${$hashref->{PEERS}}[1];
print "\n";
