#!/usr/bin/perl -w
##############################################################################
#    Name: fujicycle.pl
#
# Summary: Parse heavily nested filesystem to extract board, machine and total
#          cycletime data.  Then sum cycletime data for each board/machine.
#          Output as CSV file for Excel.
#
# Created: Thu 03 May 2001 09:55:26 (Bob Heckel)
##############################################################################

use strict;

$; = ',';

###my $WHERE  = '//d/projects/fujicycle/smalldata';
my $WHERE  = '//d/projects/fujicycle/data';
my $OUTPUT = '//d/projects/fujicycle/output.csv';

my @directories = traverse($WHERE);

my %h = ();
my $i = 0;

foreach my $file ( @directories ) {
  if ( -f $file ) {
    my ($board, $mach, $totcyctime) = parseFile($file);
    # Skip if no board is found.
    next unless $board;
    $totcyctime ||= 0;
    # Hopefully unique delimiter for the split() that occurs later.
    #          -------
    $h{$board,'<<:::>>',$mach} += $totcyctime;
    $i++;
  }
}

open(OUT, ">$OUTPUT") || die "$0: can't open $OUTPUT: $!\n";

while ( (my $key, my $val) = each(%h) ) { 
  my ($board, $mach) = split('<<:::>>', $key);
  chop $board;
  # Comma not required b/c the $; does an implicit $h{join($;, $board, $mach)};
  #               --
  print OUT "$board$mach,$val\n";
}

close(OUT);

print "Parsed $i files starting at $WHERE\nCSV data saved to $OUTPUT\n";


# Extract board, machine and total cycletime data from a file.
sub parseFile {
  my $file = shift;
  
  my $board      = undef;
  my $mach       = undef;
  my $totcyctime = undef;

  open(FILE, $file) || die "$0: can't open $file: $!\n";

  while ( <FILE> ) {
    if ( $_ =~ m/Board Name:\s+\b(\w+)\b/ ) {
      $board = $1;
    }
    elsif ( $_ =~ m/Machine Name:\s+\b(.*)\b/ ) {
      $mach = $1;
    }
    # Look for a number which may be floating point.
    #                                   --------------
    elsif ( $_ =~ m/Total Cycle Time:\s+(\d+\.?(\d+)?)\b/ ) {
      $totcyctime = $1;
    }
  }
  close(FILE);

  return $board, $mach, $totcyctime;
}


# Recurse a directory tree.
sub traverse {
  no strict;
  my $dir = shift;

  opendir($dir, $dir) || die "Cannot open $dir: $!";
  
  while($dirent = readdir($dir)) {
    # Throw out '.' and '..'
    next if (($dirent eq ".") || ($dirent eq ".."));

    $path = $dir."/".$dirent;
    push(@path, $path);
    
    # Recurse for directories.
    traverse($path) if (-d $path);
  }
  closedir($dir);
  
  return @path;
}

