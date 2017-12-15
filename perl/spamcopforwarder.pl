#!/usr/bin/perl -Tw
##############################################################################
#  SpamCop Forwarder
#  Feed this script the emails or postings you want to report to SpamCop
#
#  Mutt config:
#  macro pager S "<pipe-message>spamcopforwarder\n<save-message>=received.spam\n" "Forward spam to SpamCop"
#  macro pager R "<pipe-message>spamcopreporter\n" "Report to SpamCop"
#
#  When viewing a spam message in mutt, you can press 'S' to forward the
#  message to SpamCop and save a copy in in a special mailbox.  
#
#  When viewing a SpamCop AutoResponder message in mutt (like the one above),
#  you can press 'R' to report the previously sent message to SpamCop.  After
#  the message has been parsed and complaints have been sent to the proper
#  abuse addresses, you will get an email with the results.
#
#  Written by Robert Jan Scheer in july 2001
##############################################################################

# Create a safe environment
BEGIN {
	for my $var (keys %ENV) {
		next if $var eq "LOGNAME" and $ENV{$var} =~ m!^\w+$!i;
		next if $var eq "HOME" and $ENV{$var} =~ m!^[/\w]+$!i;
		delete $ENV{$var};
	}
	$ENV{SHELL} = '/bin/sh';
}

# Load modules
use strict;
use Net::Domain qw(hostdomain);

##############################################################################

my($version)   = q$Revision: 1.7 $ =~ /(\d+\.\d+)/;	# RCS revision controL
my $useragent  = "SpamCopForwarder/$version";
my $sendmail   = "/usr/sbin/sendmail -t";
my $maintainer = '&lt;rj at xs4all dot net&gt;';		# Against harvesters
my $spamcop    = 'spam' . '@' . 'cmds.spamcop.net';	# Against harvesters

##############################################################################

# Collect user info
my $user = $ENV{'LOGNAME'} || (getpwuid($&lt;))[0];
my $home = $ENV{'HOME'} || (getpwuid($&lt;))[7];
defined $user and defined $home or die "Who are you\n";

# Configurable user options
my %opt = (
	forwarddebug =&gt; 0,	# Only print what would be forwarded
	exitcode =&gt; 0,		# Exit code. Useful w/ 'nowait_key' in mutt
);

##############################################################################


# Read user configuration
my $config = "$home/.spamcoprc";
if (open(CONFIG,"&lt;$config")) {
	while (&lt;CONFIG&gt;) {
		s/#.*//;				# Delete comments
		if (/^\s*(\w+)\s*=\s*([^\s,;]+)/i) {	# Read until sep char
			$opt{$1} = $2;			# Hash should be safe
		}
	}
}

# Determine your email address
if (not defined $opt{email}) {
	$opt{email} = $user . '@'
	. hostdomain() || die "Cannot determine your email address\n";
}

# Determine address to forward to
if (not defined $opt{forward_to}) {
	die "SpamCop reporting has changed. Please do the following once:\n"
	.   "1. Sign up at http://spamcop.net/anonsignup.shtml\n"
	.   "2. You will receive an email address to forward spam to.\n"
	.   "3. Put 'forward_to=that\@email.address' in the file $config\n"
	.   "Now you can report spam as normal.\n";
}

my $ismail;
my $ispost;
my $fromspamcop;
my @lines;

while (&lt;STDIN&gt;) {
	push @lines, $_;
	if (1  .. /^$/) {
		$ismail++ if /^Received:/i;
		$ispost++ if /^Path:/i;
		$fromspamcop++ if /^From: SpamCop Auto(Responder|Reporter)/i;
		next;
	}
	last;
}

die "Will not forward SpamCop mail to SpamCop!\n" if $fromspamcop;

if ($ismail or $ispost) {
	unless ($opt{forwarddebug}) {
		open(SENDMAIL, "|$sendmail") or die "$sendmail: $!\n";
		select(SENDMAIL);
	}
	print &lt;&lt;EOH;
From: $opt{email}
To: $opt{forward_to}
Subject: Forwarded spam...
Mime-Version: 1.0                                                               
Content-Type: message/rfc822                                                    
Content-Disposition: inline
User-Agent: $useragent

EOH
	print @lines;
	print &lt;STDIN&gt;;
	unless ($opt{forwarddebug}) {
		close(SENDMAIL) or die "$sendmail: $!\n";
	}
	warn "Forwarded to SpamCop!\n";
	exit ($opt{exitcode} =~ /^\d+/ ? $opt{exitcode} : 0);
}
die "No mail or post found!\n";
