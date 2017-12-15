#!/usr/bin/perl -w

use Socket;
use IO::Handle;
# We say AF_UNIX because although *_LOCAL is the POSIX 1003.1g form of the
# constant, many machines still don't have it.
socketpair(CHILD, PARENT, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or 
                                                     die "socketpair: $!";

CHILD->autoflush(1);
PARENT->autoflush(1);

if ( $pid = fork() ) {
  # In parent.
  close PARENT;
  print CHILD "Parent Pid $$ is sending this\n";
  chomp($line = <CHILD>);
  print "Parent Pid $$ just read this: `$line'\n";
  close CHILD;
  waitpid($pid,0);
} else {
  # In child.
  die "cannot fork: $!" unless defined $pid;
  close CHILD;
  chomp($line = <PARENT>);
  print "Child Pid $$ just read this: `$line'\n";
  print PARENT "Child Pid $$ is sending this\n";
  close PARENT;
  exit;
}
