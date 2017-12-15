#!/usr/bin/perl
##############################################################################
#     Name: keepalive.ftp.pl
#
#  Summary: Force an FTP connection to remain open for a certain number of
#           minutes, allowing immediate, interactive, uploads of a single
#           file.
#
#           An actually useful application of forking processes.
#
#  Created: Thu 04 Nov 2004 16:29:24 (Bob Heckel)
# Modified: Sat 20 Nov 2004 23:47:55 (Bob Heckel)
##############################################################################
use strict;
use warnings;
###use Coy;
use Net::FTP;
$|++;

die <<EOT if ! @ARGV;
 usage: keepalive.ftp.pl FILETOREPEATEDLYUPLOAD REMOTENAME'
        keepalive.ftp.pl ~/projects/month_qtr/TSAAAZQT.sas 'pgm.lib(tsaaazqt)'
EOT

my $n = 50;  # times to cycle

$ARGV[1] ||= $ARGV[0];

print "\n\npress u to upload, enter to quit\n\n";

my $ftp = Net::FTP->new('mf',
                        Debug   => 1,
                        Timeout => 90) 
                 || die "Can't connect to ftpserver: $@. $?. $!. Exiting.\n";

$ftp->login('bqh0', 'tistyb4p') 
                 || die "Can't login as username: $@. $?. $!. Exiting.\n";



my $pid = $$;    # $$ holds the current process ID number
my $parent = 0;  # the original process was an immaculate conception

my $newpid = fork();

if ( not defined $newpid ) {
  die "fork didn't work: $!\n";
} elsif ( $newpid == 0 ) {
  # This is the child process which has a parent called $pid.
  $parent = $pid;   
} else {
  # The parent process is returned the PID of the newborn by fork().
  print "pid $$ spawned $newpid\n";
}

# If I have a parent, then I'm a child process.
if ( $parent ) {
  my $tries = 0;  # init
  # CHILD WORK:
  while ( $tries < $n ) {
    $ftp->pwd;
    print "DEBUG keepalive sleeping in cycle $tries of $n\n", 
          scalar localtime, "\n";
    # mf timeout is 5 minutes.
    sleep 295;
    $tries++;
  }
  print "WARNING: child process has finished keepalive\n";
  print "         quitting is suggested (press enter)\n";
} else {
  # Parent process needs to preside over the death of its kids.
  # PARENT WORK:
  ###while ( <STDIN> ne "\n" || <STDIN> ne 'q' ) {  TODO does this work?
  while ( <STDIN> ne "\n" ) {
    $ftp->put($ARGV[0], $ARGV[1]) || die "Can't upload localfile. $@ Exiting.";
    print 'last upload: ', scalar localtime, "\n";
  }

  my $reaped = kill 9, $newpid;
  if ( $reaped ) {
    print "...child $newpid signalled\n";
    $ftp->quit || warn "Not a graceful quit.  May indicate a problem.\n";
  } else {
    print "DEBUG: child process already gone, chief\n";
  }

}

exit 0;
