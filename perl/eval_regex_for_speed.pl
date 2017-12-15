#!/usr/bin/perl -w
##############################################################################
#     Name: eval_regex_for_speed.pl
#
#  Summary: Demo of using eval to avoid recompiling regexes.
#
#  Adapted: Fri 05 Dec 2003 12:27:44 (Bob Heckel --
#                             file:///C:/bookshelf_perl/advprog/ch05_05.htm)
##############################################################################

use Benchmark qw(cmpthese);

@patterns = ('one', 'two');

sub test1 {
  while ( $s = <DATA> ) {
    $all_matched = 1;     # start by assuming all patterns match $s
    foreach $pat ( @patterns ) {
      # Compiled on each iteration, ugh.
      if ( $s !~ /$pat/ ) {
        $all_matched = 0; # no, our assumption was wrong
        last;
      }
    }
    print $s if $all_matched;
  }
}

sub test2 {
  # Faster:
  $code = 'while (<DATA>) {'; 
  $code .= 'if (/';
  $code .= join ('/ && /', @patterns);
  $code .= '/) {print $_;}}';
  ###print $code, "\n";
  eval $code;   # Ahh, finally !
  # Check if faulty regular expressions given as input patterns
  die "Error ---: $@\n Code:\n$code\n"    if ($@);
}


# Comparisons are done in pairs, negatives are better.
cmpthese(-2, {
  test1 => \&test1,
  test2 => \&test2,
  }
);


__DATA__
junk line
one and two
more junk
one    two
