#!/usr/bin/perl
##############################################################################
#     Name:
#
#  Summary:  TODO not working 2006-12-22 
#
#  Created:
##############################################################################
###use strict;
use warnings;
use Mail::POP3Client;

$pop = new Mail::POP3Client( USER     => 'bheckel@gmail.com',
															  PASSWORD => "eanda1h",
                                HOST     => "pop.gmail.com",
																USESSL   => 1,
																DEBUG => 1,
																AUTH_MODE => 'best',
																PORT => 995
																);

for ( $i = 1; $i <= $pop->Count(); $i++ ) {
	foreach ( $pop->Head( $i ) ) {
		/^(From|Subject):\s+/i and print $_, "\n";
	}
	print "\n";
}
