#!/usr/local/bin/perl 
 
# Spamcop reporter

open(SENDMAIL, "|/usr/lib/sendmail -oi -t") || die "Cannot open sendmail output";

print SENDMAIL  <<"ENDENDEND";
From: nobody@spamcop.net
To: <replace with your customized reporting address>
Subject: report spam
MIME-Version: 1.0
Content-Type: multipart/mixed;
  boundary="DeathToSpamDeathToSpamDeathToSpam"

This is a multi-part message in MIME format.
--DeathToSpamDeathToSpamDeathToSpam
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


--DeathToSpamDeathToSpamDeathToSpam
Content-Type: message/rfc822
Content-Disposition: attachment

ENDENDEND

while (<STDIN>) {
        print SENDMAIL ;
}


print SENDMAIL  <<"ENDENDEND";

--DeathToSpamDeathToSpamDeathToSpam--
ENDENDEND

close (SENDMAIL);
