#!/usr/bin/perl -w
##############################################################################
#     Name: child_forks_working.pl
#
#  Summary: Parent process orchestrates the processing of a textfile by
#           passing lines to a maximum number of children.
#
#  Adapted: Fri 15 Nov 2002 09:56:44 (Bob Heckel -- Randall Schwartz Unix 
#                                     Review Column 41 (May 2002))
##############################################################################
use strict;
use constant MAX_CHILDPROCESSES => 3;
$|++;
# GLOBALS
my @LINES = ('one str', 'two str', 'three str', 'fourth str', 'the last str');
my %PID_TO_LINE = ();  # key=PID value=line
my %LINE_RESULT = ();  # key=line value=0(no error) or 1(error)

print "Parent pid: $$\n";

# Process the array by passing each element to a new child.
for ( @LINES ) {
  # Max number of children processing simultaneously (avoid running out of
  # resources).
  Wait_for_kid() if keys %PID_TO_LINE >= MAX_CHILDPROCESSES;  
  if ( my $pid = fork() ) {
    # PARENT does...
    # Coordination. 
    # The keys of this hash will be the child process ID, and the value will
    # be the corresponding line that the child is processing.  
    $PID_TO_LINE{$pid} = $_;
    ###warn "$pid created, now processing \"$_\"\n";
    # Better.
    warn "child $pid created, now processing \"$PID_TO_LINE{$pid}\"\n";
  } else {
    # CHILD does...
    # The work. 
    exit Read_a_line($_);
  }
}

1 while Wait_for_kid();  # final reap

for ( sort keys %LINE_RESULT ) {
  print "\"$_\" is ", ($LINE_RESULT{$_} ? "good" : "bad"), "\n";
}

exit 0;


# The Work.
sub Read_a_line {
  my $foo = shift;

  print "Read_a_line(): $$ is working on $foo\n";

  return 0;
}


# Wait for child process to be reaped.
sub Wait_for_kid {
  my $pid = wait();  # gets child pid as reaped
  return 0 if $pid < 0;
  my $line = delete $PID_TO_LINE{$pid} 
                         or warn "uh oh, why did i see $pid($?)\n", next;
  warn "Wait_for_kid(): reaping $pid, now exhausted after working " .
                                                         "on \"$line\" \n";
  $LINE_RESULT{$line} = $? ? 0 : 1;

  return 1;  # reaped successfully
}
