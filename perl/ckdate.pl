#!/usr/pkg/bin/perl -w
##############################################################################
#     Name: ckdate.pl
#
#  Summary: Check for timestamp changes, emailing if newer than 1 day.
#           Assuming that this usually runs under cron.
#
#  Created: Sun 11 Mar 2007 09:27:00 (Bob Heckel)
##############################################################################
use strict;

my $ts = (stat("$ARGV[0]"))[9];

if ( $ts > time-86400 ) {
	print "ok" ;
  my $MAIL = "mailx -s '[cron] $ARGV[0] changed recently' bheckel\@gmail.com";

  open MH, "|$MAIL" || die "Can't fork for mailx: $!";

  print MH <<"EOT";
according to $0
EOT

  close MH;

}
