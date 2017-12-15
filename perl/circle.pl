#!/usr/bin/perl -w
#####################################################################
#    PROGRAM: circle.pl
#    PURPOSE: A driver for Circle.pm.
#     AUTHOR: Steve A. Chervitz (sac@genome.stanford.edu)
#     SOURCE: http://genome-www.stanford.edu/~sac/perlOOP/examples/
#    CREATED: 18 Aug 1996
#   MODIFIED: sac --- Tue Jul  1 14:56:20 1997
#    Adapted: Wed, 21 Jun 2000 09:17:23 (Bob Heckel)
#####################################################################

package main;
use strict;
use Circle;

print "I'm in circle.pl, the Circle driver.\n";
print "----------------------------------\n\n";

defined $ARGV[1] || die "\nUsage: circle.pl <radius> <color_name>\n\n";

my $radius = $ARGV[0];
my $color  = $ARGV[1];
my $factor = 2.5;

############################################################
# Create a new Circle object.
my $circleObj  = new Circle($radius, $color);
print "\nI'm back in circle.pl...New circleObj has in fact been created and initialized.\n";


############################################################
# Modify object through one of its instance methods.
$circleObj->growArea( $factor );
$circleObj->printStats();


############################################################
# Try to set a circle data member to an illegal value
# using accessor function (the correct way).
print "\nI'm back in circle.pl...Attempting to change our circle's data POLITELY via accessor:\n";
$circleObj->setColor('puce');


############################################################
# But Perl is very laissez faire about OOP. It allows us to modify 
# the object's data directly, assigning an illegal color. 
# This is frowned upon by the Gods of OOP. 
print "\nI'm in circle.pl...Attempting to violate our circle's data directly:\n\n";
$circleObj->{'color'} = 'gareen';
print "I'm in circle.pl...violated...no problem:\n\n";
$circleObj->printStats();


exit;
