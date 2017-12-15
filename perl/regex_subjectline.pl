#!/usr/bin/perl -w

# Test for finding the begining of mail message in a mail file or folder. We
# are looking for the 'From' line.  Using capturing parenthesis to implement.

$prev = ""; 

while ( <DATA> ) {
  s/[\r\n]+$//;  # chomp
  if ( (not $prev) && (m/^From:\s+(\S+@\S+)\s+(.*)/) ) { 
    $address = $1; 
    $date = $2; 
  }

  # Save this line for testing the next line.
  $prev = $_; 
}

print "found $address\t$date\n";



__DATA__
ignore this
please
thanks

From: exxx32@duckweb.com  Sun Jun  1 07:52:25 1997
To: SEEKING, BETA, TESTERS
Date: Sun, 1 Jun 1997 03:11:46 +0000
X-Distribution: Bulk
Subject: Seeking Beta Testers
Priority: urgent
Status: RO

junk trails
