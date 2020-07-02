#!/usr/bin/perl -w
##############################################################################
#     Name: binding_op_vs_equal.pl 
#
#  Summary: Demo of difference between equals = and binding operator =~
#
#  Created: Thu 15 May 2003 13:53:51 (Bob Heckel)
##############################################################################

$_ = 'foobar';

# Search $_, put 0 or 1 into $x
$x = /foo/;
print "$x\n";
# or same output:
# Search $_, print 0 or 1
print /foo/ . "\n";


# Don't care about $_
$y = 'zoobar';
if ( $y =~ /foo/ ) {
  print "found but discarding \$y\n";
} else {
  print "not found but discarding \$y\n";
}

