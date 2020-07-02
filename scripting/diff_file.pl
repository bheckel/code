#!/usr/bin/perl -w
##############################################################################
#     Name: diff_file.pl
#
#  Summary: Determine changed lines in a new version of a file.
#
#  Created: Tue 11 Sep 2001 14:01:55 (Bob Heckel)
##############################################################################

# Sample data
# -- first line
# -- second line 
# -- third line that
#    is invisible to this crappy script

open(NEW, "wtc.txt") || die "$0: can't open file: $!\n";
while ( <NEW> ) {
  # TODO can't handle if line wraps w/o a -- suffix.
  push @newlines, $_ if /^--/;
}

open(OLD, "wtc.old.txt") || die "$0: can't open file: $!\n";
while ( <OLD> ) {
  push @oldlines, $_ if /^--/;
}

diff(\@newlines, \@oldlines);

close(NEW);
close(OLD);

open(OLD, ">wtc.old.txt") || die "$0: can't open file: $!\n";
print OLD @newlines;


sub diff {
  my ($n, $o) = @_;

  my %tracker = ();

  $tracker{$_} .= 'newflag' for @$n;
  $tracker{$_} .= 'oldflag' for @$o;
  for (sort keys %tracker) {
    if ($tracker{$_} !~ /oldflag/) {
      print "$_\n";  # found new line
    ###} elsif ($tracker{$_} !~ /2/) {
      ###print "$_ should be deleted\n";
    ###} else {
      ###print "$_ is in both old and new\n";
    }
  }
}
