#!/usr/bin/perl -w
##############################################################################
#    Name: nmck 1.4
#
# Summary: Send email via NetMail95.  Allow use of ns if files are queued in
#          smtpout.
#
#  Created: Sat, 25 Dec 1999 00:41:08 (Bob Heckel)
# Modified: Thu, 25 May 2000 19:28:21 (Bob Heckel)
##############################################################################

# NetMail95 pgm requires full path.
$netm_receive = '/util/nm95/nm95 /receive /debug';
$netm_send = '/util/nm95/nm95 /send /debug >> $HOME/nmail.sent';
# Dir to check for empty prior to using netm_receive.
$smtpout = '/home/bheckel/smtpout/';

@dircontents = `ls $smtpout`;
###$dircontents = readdir($smtpout);
# Don't count the wrk, only the txt.
$count = @dircontents / 2;

# If dir doesn't contain outgoing mail.
if (! @dircontents ) {
  print "Receiving mail...\n";
  system("$netm_receive");
} else {
  print "\nDo you want to send existing $count email in $smtpout?\n";
  chomp($yorn = <STDIN>);
  if ( $yorn =~ /[yY]/ ) {
    # Run ns and exit.
    print "Sending mail...\n";
    system("$netm_send");
    print "Receiving mail...\n";
    system("$netm_receive");
  } else {
    # Run normal netm_receive, not ready to send yet.
    system("$netm_receive");
    print "Receiving only (outgoing mail not sent)...\n";
  }
}

