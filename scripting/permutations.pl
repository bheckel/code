#!/usr/bin/perl -w
##############################################################################
#     Name: permutations.pl
#
#  Summary: Add lines of all possible I&O combinations to an existing file
#           where the I&O codes can be grouped together and permuted.
#           (actually creates a completely new file with the original lines
#           and the voluminous permutations).
#
#  Created: Tue 20 Aug 2002 13:12:36 (Bob Heckel)
##############################################################################
use strict qw(subs vars);

# Output file.  Deleted by this program at the start of each run.
###use constant PERMUTED => 'inputknown/bothbigpermute.txt';
use constant PERMUTED => 'inputknown/bothbig2permute.txt';

my @arr = ();
my %numpair_idx = ();

unlink PERMUTED;

###open INPUTFILE, "inputknown/test.small.txt" || die "$0: can't open file: $!\n";
open INPUTFILE, "inputknown/bothbig2.nodup.txt" or die "$0: can't open file: $!\n";
while ( my $line = <INPUTFILE> ) { 
  # DEBUG
  ###next unless ( $. % 100 ) == 0;
  chomp $line;
  my (undef, undef, undef, $iknown, $oknown, $inum, $onum) = 
                                                          split "\t", $line;
  ###create_entry($iknown, $oknown, $inum, $onum) if $iknown;
  create_entry($iknown, $oknown, $inum, $onum) if ( $iknown && $oknown );
  ###print "wtf: xxx$iknown yyy aaa$oknown bbb\n" unless ( $iknown && $oknown );
}
close INPUTFILE;

# E.g. $key == 728080
while ( (my $key, my $val) = each(%numpair_idx) ) { 
  print_numpair($key) if $key;
}

print "now run write_unique_lines.pl on ", PERMUTED, "\n";


sub create_entry {
  my ($iknown, $oknown, $inum, $onum) = @_;

  my $numpair = $inum . $onum;

  my $entry = [ $iknown, $oknown, $inum, $onum ];

  push @{$numpair_idx{$numpair}}, $entry;
}


# Generate all permutations of existing literals and write in
# bothbig.nodup.txt format.
sub print_numpair {
  my $nump = shift;
  my $i = 0;
  my @indarr = ();
  my @occarr = ();
  my $inum = substr $nump,0,3;
  my $onum = substr $nump,3,3;

  # Useless to have an I&O masterfile w/o both codes.
  return unless $inum && $onum;

  # LEAVE THIS to illustrate concepts.
  # First ind.
###  print ${numpair_idx{$nump}->[0][0]};
###  # First occ.
###  print ${numpair_idx{$nump}->[0][1]};
###
###  # Second ind.
###  print ${numpair_idx{$nump}->[1][0]};
###    # Second occ.
###  print ${numpair_idx{$nump}->[1][1]};

  # TODO %numpair_idx is a global hash.
  foreach my $entry ( @{$numpair_idx{$nump}} ) {
    push @indarr, $entry->[0];
    push @occarr, $entry->[1];
  }
  # Want unique elements only.
  my %seen = ();
  @indarr = grep { ! $seen{$_}++ } @indarr;
  %seen = ();  # reset
  @occarr = grep { ! $seen{$_}++ } @occarr;

  open OUTFILE, '>>'.PERMUTED or die "$0: can't open file: $!\n";
  # TODO don't recreate existing or duplicate entries.  For now, just run
  # write_unique_lines.pl over this output
  foreach my $ind ( @indarr ) {
    foreach my $occ ( @occarr ) {
      print OUTFILE "999\t99\t99\t$ind\t$occ\t$inum\t$onum\n";
    }
  }
  close OUTFILE;
}
