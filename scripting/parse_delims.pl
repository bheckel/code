#!/usr/bin/perl -w

# Using an unusual but distinctive word as a delimiter with with to parse.

Parse();

sub Parse {
  open FH, "/home/bheckel/Fuji/data/SLLX0502_MSL_0201.txt" or die $!;

  my @wholeline   = ();
  my $designation = '';

  $/ = '$ITEM$';          # strange but effective delimiter
  
  while ( <FH> ) {
    chomp;                # Remove $ITEM$ indicators.
    s/\n//g;              # Remove randomly placed newlines.
    # Used to extract $cpccode.
    @wholeline = split(',', $_);
    $_ =~ /,{2,}(.*)/;    # 2 or more commas indicate start of designation.
    $designation = $1;
    # cpccode always located at position 6.
    print "$wholeline[6], $designation\n";
  }
}
