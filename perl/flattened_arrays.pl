#!/usr/bin/perl -w
##############################################################################
#     Name: flattened_arrays.pl
#
#  Summary: Show why to use references when passing arrays to functions.
#
#  Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place tut Ch 07)
# Modified: Fri 25 Apr 2014 13:59:19 (Bob Heckel)
##############################################################################
use strict;

my (@one, @two) = SteamRoller();

print "ONE: @one\nTWO: @two\n";


sub SteamRoller {
  my @first  = qw( lemon orange lime );
  my @second = qw( apple pear medlar );

  # return() flattens @first and @second into a single, big list. 
  #
  # The second problem is that arrays are greedy, so when we return this
  # flattened list from the subroutine, @one slurps up all the return values,
  # and @two gets nothing. 
  return @first, @second;
}


print "\n";
print 'so try this';
print "\n";

my ($one, $two) = SteamRoller2();

print "ONE: @$one\nTWO: @$two\n";


sub SteamRoller2 {
  my @first  = qw( lemon orange lime );
  my @second = qw( apple pear medlar );

  return \@first, \@second;
}


print "\n";
print 'or this using anonymous arrays';
print "\n";

my ($one, $two) = SteamRoller3();

print "ONE: @$one\nTWO: @$two\n";


sub SteamRoller3 {
  my $first  = [ qw( lemon orange lime ) ];
  my $second = [ qw( apple pear medlar ) ];

  return $first, $second;
}

# warnings can be ignored in this example
