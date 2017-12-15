#!/usr/bin/perl -w
##############################################################################
#     Name: indocc.pl
#
#  Summary: Parse Industry & Occupation literals into codes.
#
#  Created: Fri 09 Aug 2002 08:31:01 (Bob Heckel)
# Modified: Mon 19 Aug 2002 17:54:30 (Bob Heckel)
##############################################################################
use strict;
###use String::Approx qw(amatch adist asubstitute);
###use Text::Soundex;
###use Text::Metaphone;
use String::Similarity;
###use String::Trigram;

use constant DEBUG => 1;
use constant ACCURACYPCT => 0.90;
###use constant TOPROCESS => 'BEN2PT1.txt';
###use constant TOPROCESS => 'BEN2PT1.noret.txt';
use constant TOPROCESS => 'test.small.raw.txt';
###use constant KNOWNGOODFILE => 'IO_ACGH_BFKL_FTCX.txt';
###use constant KNOWNGOODFILE => './inputknown/soiccoded.nodup.txt';
###use constant KNOWNGOODFILE => './inputknown/bothbig.nodup.txt';
###use constant KNOWNGOODFILE => './inputknown/bothbigpermute.nodup.txt';
use constant KNOWNGOODFILE => './inputknown/test.small.mstr.txt';
###use constant KNOWNGOODFILE => './inputknown/temp.txt';
use constant OUTPUTFILE => './output/parsedIO.out';

my $starttime = time();
my $directmatch = 0;  # success direct
my $totfound = 0;  # success tot
my $linesproc = 0;
my $numskipped = 0;

if ( DEBUG ) {
  unlink './output/act_vs_fuzz.out';
  unlink './output/no_match_at_all.out';
  print "line    !score!                (raw)                 [known]\n";
  open DEBUGFILE1, ">./output/act_vs_fuzz.out" || die "$0: can't open file: $!\n";
  print DEBUGFILE1 "line    !score!                (raw)                 [known]\n";
  open DEBUGFILE2, ">./output/no_match_at_all.out" || die "$0: can't open file: $!\n";
}

# This array will be searched from top to bottom for each line of raw input
# that is looking for an I&O match.
my @memoryhog = ();
open MASTERFILE, KNOWNGOODFILE || die "$0: can't open file: $!\n";
while ( <MASTERFILE> ) {
  $_ =~ s/[\r\n]+$//;  # chomp
  my ($junk1, $junk2, $junk3, $iknown, $oknown, $inum, $onum) = split "\t", $_;
  push @memoryhog, [ $iknown, $oknown, $inum, $onum, "$iknown\t$oknown" ];

}
close MASTERFILE || die "cannot close MASTERFILE: $!\n";

open RAWFILE, TOPROCESS || die "$0: can't open file: $!\n";
unlink OUTPUTFILE;  # cleanup from previous run

# TODO this loop is way too big and slow
LINE: while ( <RAWFILE> ) {
  my $certno = 0;
  my $age = 0;
  my $sex = 0;
  my $educ = 0;
  my $stoccur = 0;
  my $stresid = 0;
  my $raw = '';   # the line from the unprocessed input file
  my $rawi = '';  # the split out Industry literal
  my $rawo = '';  # the split out Occupation literal
  my $inum = 0;  # goal is to populate
  my $onum = 0;  # goal is to populate

  if ( DEBUG ) {
    # 8000 line file.  Therefore 8 lines.
    ###next unless ( $. % 1000 ) == 0;
    # 8000 line file.  Therefore 80 lines.
    ###next unless ( $. % 100 ) == 0;
    # 8000 line file.  Therefore around 200 lines.
    ###next unless ( $. % 40 ) == 0;
    # 8000 line file.  Therefore 800 lines.
    ###next unless ( $. % 10 ) == 0;
  }
  $linesproc++;
  $_ =~ s/[\r\n]+$//;  # chomp
  (undef, $certno, $age, $sex, $educ, $stoccur, $rawi, $rawo) = 
                                                             split "\t", $_;
  my $foundraw = '';
  my $foundinum = '';
  my $foundonum = '';

  $raw = $rawi . "\t" . $rawo;

  # TODO need to jump to printing section (need a sub)
  # Nothing was coded in the industry field...
###  if ( !$rawi ) {
###    # ...which may be normal for these categories:
###    if ( lc $rawo eq 'infant' || lc $rawo eq 'child' || 
###         lc $rawo eq 'student' || lc $rawo eq 'unknown' ) {
###      $directmatch++;
###      $foundraw = $raw;
###      print "infant rule!" if DEBUG;
###      ###if ( DEBUG ) {
###        ###$foundinum = '989XXXXXX';
###      ###} else {
###        ###$foundinum = 989;
###      ###}
###      ###$foundonum = 910;
###      # TODO jump out of 2 loops
###      ###next LINE;  # line in RAWFILE 
###    } else {
###      $numskipped++;
###      next LINE; # line in RAWFILE
###    }
###  }
  # Nothing was coded in the occupation field.
  ###if ( !$rawo ) {
  if ( !$rawi || !$rawo ) {
    $numskipped++;
    next LINE; # line in RAWFILE
  }

  my $highestscore = 0;
  # Get a known, well-coded line to compare raw against.
  # E.g. HARDWARE SALES  HARDWARE SALESMAN 488 476
  foreach my $line ( @memoryhog ) {
    my $inum = @$line[2];
    my $onum = @$line[3];
    my $bothio = @$line[4];

    # TODO check for valid numbers in age, sex, educ

    # ~~~~~~~~~~~~~~~ Phase I ~~~~~~~~~~~~~~~
    # Look for simple direct match.
    if ( lc $raw eq lc $bothio ) {
      $directmatch++;
      $foundraw = $raw;
      if ( DEBUG ) {
        $foundinum = $inum . 'DDDDDDDD';
      } else {
        $foundinum = $inum;
      }
      $foundonum = $onum;
      last;  # get out of MASTERFILE, can't improve on an exact match
    }

    # ~~~~~~~~~~~~~~~ Phase II ~~~~~~~~~~~~~~~
    # Look for a close match not requiring manipulation of the original raw
    # input.
    if ( (my $score = fuzzscore($raw, $bothio)) > ACCURACYPCT ) {
      # Select the best match.
      if ( $score > $highestscore ) {
        $highestscore = $score;
        $foundraw = $raw;
        if ( DEBUG ) {
          $foundinum = $inum . 'FFFFFF';
          # Going to see *all* fuzzy matches, not just the highest score.
          print "$. !$score! found fuzz ($raw) [$bothio]\n";
          # Going to see *all* fuzzy matches, not just the highest score.
          print DEBUGFILE1 "$. !$score! ($raw) [$bothio]\n";
        } else {
          $foundinum = $inum;
        }
        $foundonum = $onum;
      }
      # Keep trying for better match percentage.
      next; # line in MASTERFILE
    }
  }  # end complete iteration of known good coded file for single rawline

  if ( $foundraw && $foundinum && $foundonum ) {
    $totfound++;
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    print RESULTSFILE "$certno\t$rawi\t$foundinum\t$rawo\t$foundonum\t" .
                      "$age\t$sex\t$educ\t$stresid\t$stoccur\n";
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
  } else {  # complete failure
    print DEBUGFILE2 "$raw\n";
  }
}  # end iteration of raw to-be-coded file
close RAWFILE || die "cannot close RAWFILE: $!\n";

print "\nCoding Results:\n";
print "  lines processed: $linesproc\tblanks skipped: $numskipped\n";
my $fuzzmatch = $totfound - $directmatch;
print "  total matched: $totfound\tfuzzy: $fuzzmatch\texact: $directmatch\n";
my $pct = sprintf("%.2f%%", ($totfound / ($linesproc-$numskipped))*100);
print "  successfully coded: $pct\n";
my $elapsed = time() - $starttime;
my $spl = $elapsed / $linesproc;
print "  total time in seconds: $elapsed\t seconds per line: $spl\n";

exit(0);


sub fuzzscore {
  my ($rawin, $codedin) = @_;
  my $score1 = 0;
  my $score2 = 0;
  my $score3 = 0;
  my $score4 = 0;

  $rawin = lc $rawin; 
  $codedin = lc $codedin;

  # TODO add more intelligence
  ###$score1 = fmatch($rawin, $codedin);
  $score1 = similarity $rawin, $codedin;
  ###$score3 = mmatch($rawin, $codedin);
  ###$score4 = trimatch($rawin, $codedin);

  # DEBUG
  ###print "1: $score1 2: $score2\n" 
                            ###if (($score1 + $score2) / 2) > ACCURACYPCT-.01;

  # Return average score.
  return $score1;
  ###return ($score1 + $score2) / 2; 
  ###return ($score1 + $score2 + $score3) / 3; 
  ###return ($score1 + $score2 + $score3 + $score4) / 4; 
}


###sub fmatch {
###  my ($x, $y) = @_;
###  # Find shortest string's length.
###  my $len = (length($x) < length($y)) ? length($x) : length($y);
###  my $matches = 0;
###  my $w = 2;  # substring width
###
###  $x eq $y && return(1.0);
###  $len > $w || return(0.0);
###
###  for my $i ( 0 .. $len-$w ) {
###    my $s = substr($x, $i, $w);
###    # Escape regex characters in string.
###    ###$s =~ s/([()+[\]*|?.{}\\])/\\$1/;
###    $s = quotemeta $s;
###    $y =~ $s && $matches++;
###  }
###
###  my $score = $matches/($len-$w);
###
###  return ($score > 1) ? 1 : $score;
###}


###sub mmatch {
###  my ($rawin, $codedin) = @_;
###
###  my $x = Metaphone($rawin);
###  my $y = Metaphone($codedin);
###
###  
###  return fmatch($x, $y);
###}


###sub trimatch {
###  my ($rawin, $codedin) = @_;
###
###  return String::Trigram::compare($rawin, $codedin);
###}
