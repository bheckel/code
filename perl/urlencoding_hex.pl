#!/usr/bin/perl -w
##############################################################################
#    Name: urlencoding_hex.pl
#
# Summary: Demo of code used in the cgi_template.pl cgi script.
#
# Created: Fri, 23 Jun 2000 14:49:43 (Bob Heckel)
##############################################################################

# Slash '/' is ascii 2F in hexadecimal, 47 in decimal.
#                                 ___  ___
$userdata_from_form = 'birthday=05%2F21%2F98+is+emiday';
print pack("C", hex('2F')), " is the packed representation of 2F.\n";

($name, $value) = split(/=/, $userdata_from_form);
$value =~ tr/+/ /;
$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
$FORM{$name} = $value;
print keys(%FORM), "\n";
print values(%FORM), "\n";
