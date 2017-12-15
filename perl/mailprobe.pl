#!/usr/bin/perl
##############################################################################
#     Name: mailprobe.pl
#
#  Summary: Send an automated email.
#
#  Created: Wed 06 Oct 2004 15:16:21 (Bob Heckel)
##############################################################################
use strict;
use Net::SMTP;

my $frequency   = $ARGV[0];
my $mailserver  = '158.111.2.21';
my $originating = 'bheckel@cdc.gov';
my $recipient   = 'lmithelp@cdc.gov';
my $now         = scalar localtime;
my $subj        = "Subject: Successful probe -- SMTP mainframe $now";
my $to          = "To: $recipient";
my $from        = "From: $originating";
my $msg =<<"EOT";
This is a ${frequency} daily automated test to confirm the 
availability of the SMTP server on the CDC mainframe 
(158.111.2.21).
EOT

my $smtp = Net::SMTP->new($mailserver,
                          Timeout => 30,
                          Debug   => 1
                          );
die "Can't create smtp object.  Exiting.\n" unless defined($smtp);

print $smtp->banner();
$smtp->mail($originating);
$smtp->to($recipient);
$smtp->data();   # start the mail
$smtp->datasend("$subj\n");
# These next 2 don't affect delivery, they just look pretty.
$smtp->datasend("$to\n");  
$smtp->datasend("$from\n\n");
$smtp->datasend("$msg");
$smtp->dataend();
$smtp->quit();
