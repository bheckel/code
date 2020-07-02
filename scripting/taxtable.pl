#!/usr/bin/perl -w
##############################################################################
#    Name: taxtable.pl
#
# Summary: Calculate income tax the way the IRS does it with Tax Tables (i.e.
#          they average between 0 and 50 times the tax rate.
#
# Created: Sun, 04 Feb 2001 10:11:34 (Bob Heckel)
##############################################################################

$agi           = 20222;
$irs_increment = 50;
$taxrate       = 0.15;
###$cropped       = substr($agi, -2);
$modded        = 1;
$tmpnum        = $agi;

# Determine how high to go until hit first increment of 50 (i.e. the top of
# the range).
for ( $i=0; $modded!=0; $i++ ) {
  $modded = ++$tmpnum % 50;
}

# Increase AGI's last two digits to make them 50.
###$cropped += $i;

$upto50  = $agi + $i;
$downto0 = $upto50 - $irs_increment;
$avgagi  = ($upto50 + $downto0) / 2;

print "Tax is \$$avgagi * $taxrate";
$calc = $avgagi * $taxrate;
# TODO round and commafy.
print " or \$$calc\n";
