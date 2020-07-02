#!/usr/bin/perl -w
##############################################################################
#    Name: bch.pl
#
# Summary: Parse doublespaced input file into .bch files.
#
#          Must :se ff=unix on INPUT file before proceeding!!
#
# Created: Wed 02 May 2001 09:41:50 (Bob Heckel)
##############################################################################

use strict;

use constant INPUT     => 'input.txt';
use constant OUTPATH   => 'output/';
use constant EXTENSION => '.bch';

print "This program will use ", INPUT, " to create ", EXTENSION, 
      " files in ", OUTPATH, "  Continue?\n";

unless ( <STDIN> =~ /^y|^yes|^ok/i ) { die "No conversion performed.\n"; }

# Records are delimited by 1 (if date) or 2 (no date) blank lines, each of
# which begin with a space character.
$/ = " \n";

open(FH, INPUT) || die "$0: can't open file ", INPUT, ": $!\n";

my $i = 0;
while ( <FH> ) {
  ###last if $. > 6;
  $_ =~ s/\r*\n//g;
  # Watch out for bad input like ID NO.2147  <--and trailing space.
  # TODO this regex doesn't protect you from it very well
  $_ =~ /ID NO\. (\d+) (......)\s*(.*)/;
  # Skip the strange ones, e.g. N502AA 1-UP, for Mike C to handle manually.
  isGoodData($3) || next;
  next unless $1 && $2;
  $i++ if writeFile($1, $2);
}

printf("Successfully processed %d file%s.\n", $i, $i==1 ? '' : 's'); 


# Eliminate garbage pecs, not ones that simply contain a date.
sub isGoodData {
  my $str = shift;

  my $isdate = 0;

  # It's missing.  OK.
  return 1 unless $str;

  # It's probably a date.  OK.
  $isdate = 1 if $str =~ m{^\d+/\d+/\d+};

  #                                              --------
  # It's garbage if it's not a date, e.g. 3T65AA (DMS-10).
  $isdate ? return 1 : return 0;
}


sub writeFile {
  my ($fixid, $pec) = @_;

  my $fqfn = OUTPATH . $fixid . EXTENSION;
  open(OUT, ">$fqfn") || die "$0: can't open file: $!\n";

  print OUT <<"EOT";
!rts_grget -f $pec $fixid
.$pec
EOT

  close(OUT);
  return 1;
}

__END__
Data sample (skips 2 lines if no date, otherwise skips 1 line):

ID NO. 1
1X68BC


ID NO. 2
6X48AA
   

ID NO. 211
 2T71AA
 1/18/94
 
ID NO. 212
 4T20AA (DMS-10)

 
ID NO. 300
1X68BB
