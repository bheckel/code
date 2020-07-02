#!/usr/bin/perl -w
##############################################################################
#     Name: email.mailx.pl
#
#  Summary: Simple email sending on Unix.
#
#           Also see chuckmail.pl for a sendmail implementation.
#
#  Created: Thu 29 Apr 2004 16:31:07 (Bob Heckel)
##############################################################################

$MAIL = 'mailx -s "bob test" bqh0@cdc.gov';

open MAILHANDLE, "|$MAIL" || die "Can't fork for mailx: $!";

print MAILHANDLE <<"EOT";
testing two
EOT

close MAILHANDLE;

