#!/usr/bin/perl -w
##############################################################################
#    Name: format.pl
#
# Summary: Demo of wrapping text via an external program. (how would I do this
#          without fmt??)
#
# Created: Sun, 18 Feb 2001 17:38:11 (Bob Heckel)
##############################################################################

$result = 'big fat test - the spice must flow and go on and on and on for way more than 78 characters';
$FMT = '/bin/fmt';
open(F, "| $FMT") or die "nogo";
print F $result;
