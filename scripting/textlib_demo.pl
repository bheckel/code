#!/usr/bin/perl -w
##############################################################################
#    Name: textlib_demo.pl
#
# Summary:
#  Sample portrc file contents:
#  PORT_BARCODE=com3
#  PORT_HANDLER=com2
#  PORT_QNX=com2
#  PORT_BOBH=%bobh%
#
# Created: Tue, 10 Oct 2000 08:36:37 (Bob Heckel)
##############################################################################

use TextLib;

$template = 'portrc';
$hash{bobh} = 'replaceme';
$result = tokenReplace($template, \%hash);
print $result;
