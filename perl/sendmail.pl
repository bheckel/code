#!/usr/bin/perl -w
##############################################################################
#     Name: sendmail.pl
#
#  Summary: Send email without a MUA.
#
#           Installed via MCPAN, localhost test sends failed on Cygwin.
#           Had to modify Sendmail.pm to use SMTP server
#           mailhost.worldnet.att.net or use this:
#
#           $mail{smtp} = 'my.mail.server';
#
#  Adapted: Sat 26 Jul 2003 12:35:51 (Bob Heckel -- perldoc)
##############################################################################
use strict;
use Mail::Sendmail qw(sendmail %mailcfg);

$mailcfg{debug} = 6;

###my %mail = ( To      => 'bheckel@sdf.lonestar.org', From    => 'bheckel@att.net', Message => "This is a very short message");

my %mail = ( To      => 'bheckel@cdc.gov',
             From    => 'bqh0@cdc.gov',
             Subject => 'Test automated email',
             Message => 'This is the message'
           );

sendmail(%mail) or die $Mail::Sendmail::error;

print "OK. Log says:\n", $Mail::Sendmail::log, "\n";
