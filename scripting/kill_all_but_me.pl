#!/usr/bin/perl
# Find all of this user's processes and kill all of them except for this
# one.  Used to clean up after a network disruption or X-server crash,
# or if this festering pile of Microsoft shit decides to flake out in some
# sort of "innovative" way.
# 
# RedHat Linux 6.1 version

TODO

chomp($myName = `whoami`);
$myName = '^' . $myName;
chomp($myDev  = `tty`);
@shellSpec = split(/\//, $ENV{'SHELL'});
$myShell = pop @shellSpec;
$myShell = "csh" if ($myShell eq "tcsh");

open(PS, "ps -aux | grep $myName|") || die "Error - can't do ps\n";

# TODO clean up this hacked mess
while ( <PS> ) {
  chop;
  #bheckel    766  0.0  0.3  1072  348 pts/3    S    15:33   0:00 blink_linux
  ($pid, $dev, $task) = extract($_, 9,5, 36,6, 63,20); 
  ###if ( ($task =~ /$myShell/) && ($myDev !~ /$dev/) ) {
  $dev = '/dev/' . $dev;
  ###warn "x${myDev}x  y${dev}y\n";
  # TODO for now just kill blinks til I understand what the other zombies are
  # doing
  ###next unless $task =~ /blink/;
  next if $myDev eq $dev;
  # DEBUG
  ###print "pid: $pid  dev: $dev  task: $task\n";
  system("kill -9 $pid");
}
close PS;
exit;

sub extract {
  @fields = ();
  $s1 = shift @_;

  while ($offset = shift @_) {
    $len = shift @_;
    ($s2 = substr($s1, $offset, $len)) =~ s/ //g;
    $s2 =~ s/^-//;
    push @fields, $s2;
  }
  return @fields;
}
