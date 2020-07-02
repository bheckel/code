#!/usr/bin/perl -w
##############################################################################
#     Name: fork.pl
#
#  Summary: Demo of forking.  Good template.  See ADD PARENT and ADD CHILD
#           areas.  Running 3 child processes and dividing the work by 3 is
#           more efficient than having the parent do it all (at least on
#           multi-CPU machines).
#
#           See also keepalive.ftp.pl
#
#  Adapted: Fri 08 Nov 2002 16:47:16 (Bob Heckel --
#                                 http://www.steve.gb.com/perl/lesson12.html)
# Modified: Mon 11 Nov 2002 08:40:11 (Bob Heckel) 
##############################################################################
use strict;

###$| = 1;          # turn off buffering
my $pid = $$;    # $$ holds the current process ID number
my $parent = 0;  # the original process was an immaculate conception
my @kids = ();   # no babies yet

FORKER: for ( 1 .. 3 ) {
  my $newpid = fork();
  # If return value of fork() is undef, something went wrong.
  if ( not defined $newpid ) {
    die "fork didn't work: $!\n";
  } elsif ( $newpid == 0 ) {
    # If return value is 0, this is the child process.
    $parent = $pid;   # which has a parent called $pid
    $pid = $$;        # and which will have a new process ID number of its own
    @kids = ();       # the child doesn't want this baggage from the parent
    last FORKER;      # and we don't want the child making babies either
  } else {
    # The parent process is returned the PID of the newborn by fork().
    print "$$ spawned $newpid\n";
    push @kids, $newpid;
  }
}

# If I have a parent, i.e. if I'm a child process.
if ( $parent ) {
  # ADD CHILD WORK HERE
  my $rnd = int rand 5;
  print "I am process number $pid  I've generated this random number " . 
                                                          "$rnd for you.\n";
  sleep $rnd; 
  foreach my $elem ( @kids ) {
    if ( $elem == $$ ) {
      print "yesDEB $elem and $$\n";
    } else {
      print "noDEB $elem and $$\n";
    }
  }
   
  exit 0;
} else {
  # Parent process needs to preside over the death of its kids.
  while ( my $kid = shift @kids ) {
    # ADD PARENT WORK HERE
    print "...parent waitpiding for $kid to die\n";
    
    my $reaped = waitpid($kid, 0);
    if ( $reaped == $kid ) {
      print "...child $kid reaped\n";
    } else {
      print "What's Become of the Baby? Something's gone terribly wrong: $?\n";
    }
  }
}
