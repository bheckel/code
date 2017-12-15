#!/usr/bin/perl -w
##############################################################################
#    Name: server_inetd.pl
#
# Summary: Demo of a servier app using Chatbot::Eliza.
#
#          Launched by inetd using "wait".  Services requests until a minute
#          goes by without any new connections.  Server then exits and returns
#          control to inetd.
#
#      TODO never got it working with Cygwin.
#      Add this line to inetd.conf:
#      12000 stream tcp wait /home/bheckel/server_inetd.pl server_inetd.pl 2
#      Then HUP it.
#
# Adapted: Sat 17 Mar 2001 14:42:32 (Bob Heckel -- TPJ #15 Lincoln Stein p.
#                                    29)
##############################################################################

use strict qw(vars refs);

use Chatbot::Eliza;
use IO::Socket;
use POSIX 'WNOHANG';

# Idle time before server exits.
use constant TIMEOUT => 1;

my $timeout = shift || TIMEOUT;

# Signal handler for timeout, invoked if the alarm goes off before accept()
# returns.
$SIG{ALRM} = sub { exit 0 };

$SIG{CHLD} = sub { while ( waitpid(-1, WNOHANG) > 0 ) { } };

# Retrieve socket from STDIN.
die "STDIN is not a socket" unless -S STDIN;

# STDIN is turned into a IO::Socket object.
my $listen_socket = IO::Socket->new_from_fd(STDIN, "r+") || die 
                                                   "Can't create socket: $!";

warn "Server ready.  Waiting for connections...\n";

# Go to sleep and wait for the operating system to tell that a new connection
# if ready for servicing.
while ( my $connection = $listen_socket->accept ) {
  # A child processes talking to a connected client so that the parent can go
  # back to accepting (or sleeping).  One child per client.
  die "Can't fork: $!" unless defined (my $child = fork());
  # In the parent process, fork() returns the PID of the child.
  # In the child process, fork() returns 0.
  # In either, returns undef on failure.
  if ( $child == 0 ) {     # In child process.
    # Don't want the alarm to go off in a forked child processes.
    alarm(0);
    $listen_socket->close;
    interact($connection);
    # User typed 'bye' in interact() so child terminates itself.
    exit 0;
  }
} continue {
  $connection->close;
  alarm($timeout * 60);
}


sub interact {
  my $sock = shift;
  
  # Inherited from IO::Handle, it closes existing filehandle, reopenning it
  # using info from another filehandle given to it.
  #      -----
  STDIN->fdopen($sock, "r") || die "Can't reopen STDIN: $!";
  STDOUT->fdopen($sock, "w") || die "Can't reopen STDOUT: $!";
  STDERR->fdopen($sock, "w") || die "Can't reopen STDERR: $!";

  # Same as $| = 1;
  STDOUT->autoflush(1);
  Chatbot::Eliza->new->command_interface;
}
