#!/usr/bin/perl -w
##############################################################################
#    Name: dollarampersand.pl
#
# Summary: Determine if code contains the inefficient $& $` or $' variables.
#
# Adapted: Sat, 18 Nov 2000 14:25:34 (Bob Heckel -- p.279 Mastering Regular
#                                     Expressions - Friedl)
##############################################################################

# Place at the end of code you're testing to catch any eval action.
CheckNaughty();
exit;

sub CheckNaughty {
  local $_ = 'x' x 10000;

  my $start = (times)[0];
  for ( my $i = 0; $i < 5000; $i++ ) {}
  my $overhead = (times)[0] - $start;

  $start = (times)[0];
  for ( my $i = 0; $i < 5000; $i++ ) { m/^/; }
  my $delta = (times)[0] - $start;

  printf("It seems your code is %s (overhead=%.2f, delta=%.2f)\n",
                               ($delta > $overhead*10) ? "naughty" : "clean", 
                               $overhead, 
                               $delta);
}
