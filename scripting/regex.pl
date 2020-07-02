#!/usr/bin/perl -w
##############################################################################
#     Name: regex.pl
#
#  Summary: Demo of regular expression usage in Perl.
#
#           http://perldoc.perl.org/perlfaq6.html
#
#  Created: Fri 16 Jan 2004 12:14:42 (Bob Heckel)
# Modified: Tue 20 Dec 2016 09:33:21 (Bob Heckel)
##############################################################################

# Search
$x = 'foobar';

###$y = $x =~ /foo/;
$y = $x =~ m!foo!;

print $x, "\n", $y;
print "\n\n";


# Search and replace
# Same as  $ perl -e 'BEGIN{$x='bob'};($y=$x)=~s/o/0/g;END{print $y}'

# Untouched during the regex substitution:
$x = 'bobh';

($y = $x) =~ s/o/0/g;

print $x, "\n", $y;
print "\n";
print "\n";


$x = 'be stingy very stingy greedy';
$x =~ s/.*stingy/xxx/;
print "greedy: $x\n";

$x = 'be stingy very stingy greedy';
$x =~ s/.*?stingy/xxx/;
print "not greedy: $x\n";
