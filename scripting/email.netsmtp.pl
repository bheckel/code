#!/usr/bin/perl
##############################################################################
#     Name: email.netsmtp.pl
#
#  Summary: Send email from Windows or Unix box.
#
#           TODO install MIME-Lite to include attachments
#
#  Created: Mon 12 Nov 2007 13:13:27 (Bob Heckel)
# Modified: Thu 06 Mar 2008 15:26:19 (Bob Heckel)
##############################################################################
use warnings;
use Net::SMTP;

use constant USAGEMSG => <<USAGE;
Usage: email smtp from to subject
       e.g. email smtphub.glaxo.com rsh86800\@sgk.com bheckel\@gmail.com all should go on subj line for now
USAGE

$svr = shift;
$from = shift;
$from =~ s:@:\@:g;
$to = shift;
$to =~ s:@:\@:g;
$subj = "@ARGV";


$smtp = Net::SMTP->new("$svr");
$smtp->mail("$from"); # sender address
$smtp->to("$to",{ SkipBad => 1}); # address to userlist
$smtp->data();
$smtp->datasend("To: $to\n"); # human to section
$smtp->datasend("Subject: $subj\n"); # subject
$smtp->datasend("\n"); # end Header
$smtp->dataend();
$smtp->quit();

__END__
$smtp = Net::SMTP->new('smtphub.glaxo.com');
$smtp->mail('rsh86800@sgk.com'); # sender address
$smtp->to('rsh86800@sgk.com',{ SkipBad => 1}); # address to userlist
$smtp->data();
###$smtp->datasend("To: bheckel\@gmail\n"); # human to section
$smtp->datasend("To: rsh86800\@sgk.com\n"); # human to section
$smtp->datasend("Subject: test\n"); # subject
###$smtp->datasend("X-Priority: $pri\n"); # Priority (translates to importance)
$smtp->datasend("\n"); # end Header
$smtp->datasend("$ARGV[0]\n");
$smtp->dataend();
$smtp->quit();
