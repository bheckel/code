#!/usr/bin/perl -w
##############################################################################
#    Name: sort_ipaddresses.pl
#
# Summary: Sort the dotted quads of an IP address.
#
# Adapted: Sun 18 Mar 2001 12:16:46 (Bob Heckel -- Effective Perl Joseph Hall
#                                    p. 222)
##############################################################################

@addr = qw(146.12.1234.999 121.33.39.292 121.11.39.300 121.1.39.932 5.123.456.789);

@sorted_addr = map { $_->[0] }
               sort { $a->[1] cmp $b->[1] }
               map { [ $_, pack('C*', split /\./) ] }
               @addr;

print "$sorted_addr[0]\n";
print "$sorted_addr[1]\n";
print "$sorted_addr[2]\n";
print "$sorted_addr[3]\n";
print "$sorted_addr[4]\n";
