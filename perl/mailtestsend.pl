#!/usr/bin/perl
##############################################################################
#     Name: mailtestsend
#
#  Summary: Used for debugging mail system.
#
#           DEPRECATED -- see mailprobe.pl
#
#  Created: Modified: Mon, 28 Aug 2000 19:50:44 (Bob Heckel)
# Modified: Tue, 02 Jan 2001 14:42:36 (Bob Heckel)
##############################################################################

use strict;
use Net::SMTP;

###my $mailserver = 'mail.mindspring.com';
my $mailserver = '47.140.202.31';
my $originating  = 'bheckel@nortelnetworks.com';
my $recipient  = 'robertheckel@ral.slr.com';
my $subject    = 'Subject: Testing Perl/SMTP Mail';

my $to         = "To: $recipient";
my $from       = "From: $originating";
my $smtp = Net::SMTP->new($mailserver,
                          Timeout => 30
                          ###,Debug   => 1
                         );
die "Can't create smtp object.  Exiting.\n" unless defined($smtp);
print $smtp->banner();
$smtp->mail($originating);   # Sender's address.
$smtp->to($recipient);       # Recipient's address
$smtp->data();               # Start the mail

# Send the header.
$smtp->datasend("$subject\n");
# These next 2 don't affect delivery, they just look pretty.
$smtp->datasend("$to\n");  
$smtp->datasend("$from\n\n");

my $blade =<<'EOT';
   Early in the 21st Century, THE TYRELL
CORPORATION advanced Robot evolution
into the NEXUS phase -- a being
virtually identical to a human -- known
as a replicant.  The NEXUS 6 Replicants
were superior in strength and agility,
and at least equal in intelligence, to
the genetic engineers who created them.
Replicants were used Off-world as slave
labor, in the hazardous exploration and
colonization of other planets.

   After a bloody mutiny by a NEXUS 6
combat team in an Off-world colony,
Replicants were declared illegal on
earth -- under penalty of death.
Special police squads -- BLADE RUNNER
UNITS -- had orders to shoot to kill,
upon detection, any trespassing
Replicants.

This was not called execution.

It was called retirement.


LOS ANGELES
NOVEMBER, 2019

EOT

# Send the body.
$smtp->datasend("$blade");
$smtp->dataend();            # Finish sending the mail
$smtp->quit();               # Close the SMTP connection
