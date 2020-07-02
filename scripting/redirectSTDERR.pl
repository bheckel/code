#!/usr/bin/perl -w
##############################################################################
#    Name: redirectSTDERR.pl
#
# Summary: Demo of redirecting STDERR to a text file.
#
# Created: Thu, 02 Nov 2000 08:31:56 (Bob Heckel)
##############################################################################

use Net::FTP;

print "start--outside of go()\n";
unlink('foo.txt');
go();

sub go {
  open(OLDERR, ">&STDERR") || die "Can't redirect: $!\n";
  open(STDERR, ">foo.txt") || die "$0--Can't open STDERR: $!\n"; 

  # Debug writes to STDERR.
  $ftp = Net::FTP->new('47.143.208.108', Debug=>1, Timeout=>2) 
                                               || die "$!: no connect\n";
  $ftp->login('bheckel', 'PASSWD') || die "$!: no login\n";

  print "Inside go().  This is not an error.\n";
  # Shows up in the foo.txt STDERR output file.
  warn "\n           XXXInside go().  You have been warned1XXX\n\n";
  print "Inside go().  Logged in " . time() . "\n";

  $ftp->get('junk') || die "$!: no get\n";
  $ftp->quit;

  close(STDERR);
  # Without this, STDERR is not sent to terminal (e.g. the warn below is not
  # displayed).
  open(STDERR, ">&OLDERR");
}

# Back to STDOUT.
print "go() is finished.\n";
print "Connect succeeded since foo.txt exists.\n" if ( -e 'foo.txt' );
warn "You have been warned2\n";
print "...bye...\n";
