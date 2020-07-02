#!/usr/bin/perl -w
##############################################################################
#     Name: repeat.pl
#
#  Summary: Repeat a variable using the .=  += etc style notation using the
#           binary X string operator.
#
#  Created: Wed 30 Apr 2003 09:15:12 (Bob Heckel)
##############################################################################
use strict;

# Without a tmp variable.
print '-' x 80;
print "\n";

# With a tmp variable.
my $line = '*' x 80;
print $line;
print "\n";

my $foo = 'Perl';
$foo x= 5;
print $foo;
print "\n";
