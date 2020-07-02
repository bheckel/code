#!/usr/bin/perl -w

=test1
print "press y to continue looping: ";
chomp($y_or_n = <STDIN>);
if ( $y_or_n =~ /n/i ) {
  "ok, got an 'n'\n";
  exit(1);
}
=cut

=test2
print "press y to not die: ";
<STDIN> eq "y\n" ? print "ok, got a 'y'\n" : die "dead\n";
=cut

=test3
print "press y or yes or ok to not die: ";
die unless <STDIN> =~ /^y|^yes|^ok/i;
=cut

my $yesno = '';
print "press n to break from loop\n";
while ( $yesno ne 'y' ) {
  print "i'm looping, want more? ";
  chomp($yesno = <STDIN>);
}
