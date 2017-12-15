#!/usr/bin/perl -w
##############################################################################
#    Name: farenheit2celsius.pl
#
# Summary: Convert either way depending on how this pgm is called.
#          TODO need c to f algorithm (then create symlink)
#
# Created: Tue, 13 Feb 2001 16:56:43 (Bob Heckel)
##############################################################################

$pgmname = $0;

if ($pgmname =~ /farenheit2celsius.pl/) {
  convert(1);
} elsif ($pgmname =~ /celsius2farenheit.pl/) {
  convert(0);
} else {
  die("Can't figure out which function to perform from the program name: $0\n");
}


sub convert {
  my $tocelsius = shift;

  $tocelsius ? print "farenheit? " : print "celsius? ";
  $degrees = <STDIN>;
  $tocelsius ? ($temperature = ($degrees - 32) * 5/9) : sdlkfj;
  $tocelsius ? print "celsius $temperature\n" : sdlkfj;
}
