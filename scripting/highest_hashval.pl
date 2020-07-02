#!/usr/bin/perl
##############################################################################
#     Name: highest_hashval.pl
#
#  Summary: Find the highest score.
#
#  Created: Wed 14 Aug 2002 11:47:18 (Bob Heckel)
##############################################################################
use strict;

my %h = ();

open INPUTFILE, 'act_vs_fuzz.out' || die "$0: can't open file: $!\n";
while ( <INPUTFILE> ) {
  $_ =~ s/[\r\n]+$//;  # chomp
  $_ =~ s/!(.*)!/$1/;
  my $score = lc $1;
  $_ =~ m/\((.*)\)/;
  my $rawindocc = lc $1;
  $_ =~ m/\[(.*)\]/;
  my $knownindocc = lc $1;

  ###my $fused = lc $rawind . "\t" . lc $rawocc . ' --- ' . lc $knownind . 
                                                     ###"\t" . lc $knownocc;
  ###my $fused = lc $rawindocc . "\t" . lc $knownindocc;
  my $fused = '(' . $rawindocc . ')' . "\t" . '[' . $knownindocc . ']';
  ###my $fused = $rawindocc . 'x' . $knownindocc;
  ###$fused =~ s/\t+//;

  # If this key has already been seen at least once.
  if ( exists $h{$fused} ) {
    # Store its highest-so-far value.
    my $tmp = $h{$fused};
    if ( $score > $tmp ) {
      # Give it a new score if we've found a higher one.
      $h{$fused} = $score;
    } else {
      # Do nothing.  Leave highest-so-far score in place.
      $h{$fused} = $tmp;
    }
  } else {
    $h{$fused} = $score;
  }
}
close INPUTFILE;

my $numunique = 0;
open CLEANED, '>clean.out' || die "$0: can't open file: $!\n";
while ( (my $key, my $val) = each(%h) ) { 
  print CLEANED "$key: $val\n";
  ###print "$key: $val\n";
  $numunique++;
}
close CLEANED;
print $numunique;


# TODO not working.
###my %h2 = ();
###my $numunique2 = 0;
###open CLEANINPUT, 'clean.out' || die "$0: can't open file: $!\n";
###while ( <CLEANINPUT> ) {
###  $_ =~ s/[\r\n]+$//;  # chomp
###
###  $_ =~ m/\((.*)\)/;
###  my $rawindocc2 = lc $1;
###  $_ =~ m/: (\d+\.\d+|\d+\.|\.\d+|\d+)$/;
###  my $score2 = $1;
###
###  # If this key has already been seen at least once.
###  if ( exists $h2{$rawindocc2} ) {
###    # Store its highest-so-far value.
###    my $tmp2 = $h2{$rawindocc2};
###    if ( $score2 > $tmp2 ) {
###      # Give it a new score if we've found a higher one.
###      $h2{$rawindocc2} = $score2;
###    } else {
###      # Do nothing.  Leave highest-so-far score in place.
###      $h2{$rawindocc2} = $tmp2;
###    }
###  } else {
###    $h2{$rawindocc2} = $score2;
###  }
###}
###close CLEANINPUT;
###
###open CLEANTWICE, '>clean2.out' || die "$0: can't open file: $!\n";
###while ( (my $key, my $val) = each(%h2) ) { 
###  print CLEANED "$key: $val\n";
###  ###print "$key: $val\n";
###  $numunique2++;
###}
###close CLEANTWICE;
###print $numunique2;
###print "$numunique unique lines\n";
