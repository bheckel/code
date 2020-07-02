#!/usr/bin/perl -w
##############################################################################
#     Name: include.pl
#
#  Summary: Demo of including a separate Perl module.
#
# Created: Mon 29 Oct 2001 11:22:51 (Bob Heckel)
##############################################################################
###unshift (@INC, '.');
use MyModule;

$x = "long\nline\n";
$x =~ s/(\012)+/x/g;
$x .= "\n";
print $x;
print $HT::y;
print "\n";


__END__

Sample module file named MyModule.pm (in same directory):

package MyModule;

$y = 'foobar';

1;
