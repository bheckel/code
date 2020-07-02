#!/usr/bin/perl -w

# Convert embedded hexadecimal values into the correct ASCII values.
#  Adapted: Fri 15 Jun 2001 10:52:13 (Bob Heckel -- InformIT Perl CGI in a
#                                     Week)
# Test via code/perl/urlencoded.pl > junk  (use vim's ga to see the space and
# tab inserted)

$urlencoded = 'foo%20bar';
$urlencoded =~ s/%(..)/pack("c",hex($1))/ge;
print $urlencoded;
print "\n";
$urlencoded = 'foo%09bar';
$urlencoded =~ s/%(..)/pack("c",hex($1))/ge;
print $urlencoded;
