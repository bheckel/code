#!/usr/bin/perl -w
##############################################################################
#    Name: filemode.pl
#
# Summary: Determine file mode.
#
# Adapted: Sun 18 Mar 2001 12:16:46 (Bob Heckel  -- Network Programming with
#                                    Perl ch 6 Lincoln Stein)
##############################################################################

use strict;

# Turn symbolic modes into octal.
print filemode('rw-r--r--');

sub filemode {
  my $symbolic = shift;

  my (@modes) = $symbolic =~ /(...)(...)(...)$/g;
  my $result_dec;
  my $multiplier = 1;

  while ( my $mode = pop @modes ) {
    my $m = 0;

    $m += 1 if $mode =~ /[xsS]/;
    $m += 2 if $mode =~ /w/;
    $m += 4 if $mode =~ /r/;

    $result_dec += $m * $multiplier if $m > 0;

    # Cctal
    #  64  8   1
    # rwx rwx rwx 
    $multiplier *= 8;
  }

  $octal_str = sprintf("%lo", $result_dec);

  return $octal_str;
}
