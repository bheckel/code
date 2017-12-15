#!/usr/bin/perl -w
##############################################################################
#     Name: double_index.adv.pl
#
#  Summary: Demo of a double indexing scheme.
#
#                     c a t e g o r y
#            Actor    Picture    ...
#          ----------------------------
#  y e a r |
#    1995  |  ...     ...     ...
#    1996  |  ...     ...     ...
#     ...  |  ...     ...     ...
#
#
#  Adapted: Mon 22 Sep 2003 15:02:21 (Bob Heckel --
#                           file:///C:/bookshelf_perl/advprog/ch02_04.htm)
##############################################################################
use strict;

my %CATEGORY_IDX = (); my %YEAR_IDX = ();  # globals

while ( my $line = <DATA> ) {
  chomp $line;
  my ($year, $category, $name) = split /:/, $line;
  CreateEntry($year, $category, $name) if $name;
}

PrintEntriesForYear(1994);
PrintEntriesForYear(1995);

exit 0;


sub CreateEntry {
  my ($year, $category, $name) = @_;
  my $rEntry = undef;

  # Create an anonymous array for each entry...
  $rEntry = [ $year, $category, $name ];
  # ...and add it to the two indices' arrays.
  push @{ $YEAR_IDX{$year} }, $rEntry;
  push @{ $CATEGORY_IDX{$category} }, $rEntry;
} 


sub PrintEntriesForYear {
  # Parens mandatory for list context.
  my ($year) = @_;

  print "Year : $year \n";
  foreach my $e ( @{ $YEAR_IDX{$year} } ) {
    print "\t",$e->[1], "  : ",$e->[2], "\n";
  }
}


__DATA__
1995:Actor:Nicholas Cage
1995:Picture:Braveheart
1995:Supporting Actor:Kevin Spacey
1994:Actor:Tom Hanks
1994:Picture:Forrest Gump
1928:Picture:WINGS
