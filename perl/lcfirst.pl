#!/perl/bin/perl -w

# Slurp up lines in a file. TODO this only does first capitalization in a
# line.
open(FIL, "$ARGV[0]") || die ("Can't open file $ARGV[0] !\n");
  while(<FIL>) {
    print ucfirst("$_");
    ###print "$_\n";
  }
