#! /usr/bin/perl
######################################################################
## Program:     wordsearch
## Description: Interactively queries the user for words to add, then
##              adds and displays the modified grid.  On completion,
##              displays the grid and list of words within.
##
## Adapted: Tue Feb 22 11:20:24 2005 (Bob Heckel -- PerlMonks.com posting)
######################################################################

use strict;
use warnings;
use Getopt::Long;

my $help;
my $width  = 20;
my $height = 20;
GetOptions ("help"     => \$help,
            "width=i"  => \$width,
            "height=i" => \$height);
if ($help)
{
  print <<EOHELP;
  Usage: ws [-width W] [-height H] [-help]

EOHELP
  exit 1;
}

# Orientations are thus:
#   7  0  1
#    \ | /
#  6 --.-- 2
#    / | \
#   5  4  3
my @xdelta = (0, 1, 1, 1, 0, -1, -1, -1);
my @ydelta = (-1, -1, 0, 1, 1, 1, 0, -1);

# Initialize the grid.
my @grid;
my @words;
initializeGrid (\@grid, $width, $height);
displayGrid (\@grid);
$| = 1;
srand (time);
my $command = '';
while (1)
{
  $command = getCommand ();
  last if $command eq 'quit';

  if ($command eq 'finish')
  {
    fillGapsInGrid (\@grid, $width, $height);
    displayGrid (\@grid);
    displayWords (\@words);
    last;
  }

  if ($command eq 'help' || $command eq '?')
  {
    print <<EOHELP;

The folllowing commands are supported:

  add <word>  adds the word to the grid, if possible
  help        displays this message
  ?           displays this message
  finish      fills in the remains of the grid, prints out grid and words
  quit        quits program

EOHELP
    next;
  }

  my ($words) = $command =~ /^add (.+)$/;
  for my $word (split /\s+/, $words)
  {
    if (addWord (\@grid, $word))
    {
      push @words, $word;
      displayGrid (\@grid);
    }
    else
    {
      print "Could not add '$word'\n";
    }
  }
}

exit 0;

######################################################################
sub initializeGrid
{
  my ($grid, $width, $height) = @_;
  for my $r (0 .. $height - 1)
  {
    $grid->[$r] = '.' x $width;
  }
}

######################################################################
sub fillGapsInGrid
{
  my ($grid, $width, $height) = @_;
  my @alphabet = ('a' .. 'z');
  $_ =~ s/\./$alphabet[rand (26)]/eg for @$grid;
}

######################################################################
sub displayGrid
{
  my ($grid) = @_;
  print "\n";
  for (@$grid)
  {
    my $row = $_;
    $row =~ s/(.)/ $1/g;
    print $row, "\n";
  }

  print "\n";
}

######################################################################
sub displayWords
{
  my ($words) = @_;
  print "\n", join (', ', @$words), "\n";;
}

######################################################################
sub getCommand
{
  my $input = '';

  while (1)
  {
    print "> ";
    $input = lc <>;
    chomp $input;

    return $input if $input =~ /^(?:quit|finish|help|\?|add .+)$/;
    print "Command '$input' not recognized\n" if $input;
  }
}

######################################################################
sub addWord
{
  my ($grid, $word) = @_;

  # The random algorithm.
  for (0 .. $width * $height * 8)
  {
    my $x   = int rand $width;
    my $y   = int rand $height;
    my $dir = int rand 8;

    if (wordFits ($grid, $word, $x, $y, $dir))
    {
      insertWord ($grid, $word, $x, $y, $dir);
      return 1;
    }
  }

  # The exhaustive algorithm.
  for my $dir (0 .. 7)
  {
    for my $y (0 .. $height - 1)
    {
      for my $x (0 .. $width - 1)
      {
        if (wordFits ($grid, $word, $x, $y, $dir))
        {
          insertWord ($grid, $word, $x, $y, $dir);
          return 1;
        }
      }
    }
  }

  return 0;
}

######################################################################
sub wordFits
{
  my ($grid, $word, $x, $y, $dir) = @_;
  #print "testing $word at [$x,$y] dir $dir\n";

  my $xi = $xdelta[$dir];
  my $yi = $ydelta[$dir];

  # Simple rejection based on length.
  my $endx = $x + (length ($word) - 1) * $xi;
  my $endy = $y + (length ($word) - 1) * $yi;
  return 0 if $endx >= $width  ||
              $endx < 0        ||
              $endy >= $height ||
              $endy < 0;

  for my $i (0 .. length ($word) - 1)
  {
    my $x0 = $x + ($i * $xi);
    my $y0 = $y + ($i * $yi);

    #print "looking for " . substr ($word, $i, 1) . " at $x0,$y0\n";
    return 0 if substr ($grid->[$y0], $x0, 1) ne '.' &&
                substr ($grid->[$y0], $x0, 1) ne substr ($word, $i, 1);
  }

  return 1;
}

######################################################################
sub insertWord
{
  my ($grid, $word, $x, $y, $dir) = @_;

  my $xi = $xdelta[$dir];
  my $yi = $ydelta[$dir];

  for my $i (0 .. length ($word) - 1)
  {
    my $x0 = $x + ($i * $xi);
    my $y0 = $y + ($i * $yi);

    my $row = $grid->[$y0];
    $row = substr ($row, 0, $x0) .
           substr ($word, $i, 1) .
           substr ($row, $x0 + 1, length ($row) - $x0 - 1);
    $grid->[$y0] = $row;
  }
}
