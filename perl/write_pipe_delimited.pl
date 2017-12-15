#!/usr/bin/perl -w

# NYSE    CPO     2009-01-06      0.14
# NYSE    CCS     2009-10-28      1.414


while ( <> ) {
  my @fields = split;
  if ($fields[3] > 1.0) {
    print join("|", @fields) . "\n"
  }
}
