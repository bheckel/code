#!/usr/bin/perl -w
##############################################################################
#     Name: chuckmail
#
#  Summary: Automate delivery of Excel spreadsheets from pack_fs to Chuck's
#           email account charleswilliamson@nortelnetworks.com Assumes that a
#           cron job has smbclient 'ed the .xls from pack_fs to ~/sfc
#
#  Created: Mon, 07 Aug 2000 11:07:06 (Bob Heckel)
# Modified: Mon, 07 Aug 2000 14:31:41 (Bob Heckel)
##############################################################################

$MAIL = '/usr/sbin/sendmail';
# -t tell Sendmail to read headers.  -oi tell Sendmail to not exit if reads a
# single dot.
$mailflags = '-t -oi';     
$excel = '/home/bheckel/sfc/Production\ Revenue.xls';
# This is the name that shows up as the attachment in the email.
$shortexcel = 'Production\ Revenue.xls';  # Per Chuck Williamson.
$tempuue = '/home/bheckel/sfc/out.uue';

system("uuencode $excel $shortexcel >| $tempuue");

open(UUE, $tempuue) || die "$0--Can't open $tempuue: $!";

local $/ = undef;     # Slurp mode.
# Lucky side effect is that I don't get interpolation within the heredoc
# (which would have meant escaping @s etc.).
$uued = <UUE>;        
close(UUE);

open(MAILHANDLE, "| $MAIL $mailflags") || die "Can't fork for sendmail: $!";

print MAILHANDLE <<"EOT";
From: Cron Job <bheckel\@nortelnetworks.com>
To: Chuck Williamson <charleswilliamson\@nortelnetworks.com>
Bcc: Bob Heckel <bheckel\@nortelnetworks.com>
Subject: Production Revenue.xls attached

Automated delivery of spreadsheet from 
\\\\pack_fs\\SFC\\SYG-Production Revenue
directory.

$uued

EOT

close(MAILHANDLE);
