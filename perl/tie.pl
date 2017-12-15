#!/usr/bin/perl -w
##############################################################################
#     Name: tie.pl
#
#  Summary: Every time the variable is read from, the next value on the ring
#           is displayed. When it's written to, a new value is pushed onto the
#           ring. 
#
#  Adapted: Mon 23 Dec 2002 08:35:51 (Bob Heckel--Perl Cookbook 13.15)
# Modified: Sun 29 Aug 2004 09:28:49 (Bob Heckel)
##############################################################################
use strict;

use ValueRing;  # ./ValueRing.pm

my $color = undef;

# The ValueRing.pm class' TIESCALAR implicitly called.
tie $color, 'ValueRing', qw(red blue);

# Perl's FETCH implicitly called at each print.
print "1 $color\n";
print "2 $color\n";
print "3 $color\n";

# STORE implicitly called.
$color = 'green';
print "green added\n";

###print "$color $color $color $color $color $color\n";
print "4 $color\n";
print "5 $color\n";
print "6 $color\n";
print "7 $color\n";
