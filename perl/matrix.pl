#!/usr/bin/perl -w
##############################################################################
#     Name: matrix.pl
#
#  Summary: Read file and create an array of arrays structure using 
#           a symbolic reference.
#
#  Adapted: Mon 11 Feb 2002 07:29:45 (Bob Heckel -- Ch 2 Advanced Perl
#                                     Programming)
# Modified: Tue 26 Aug 2003 16:06:11 (Bob Heckel)
##############################################################################
use strict;
no strict 'refs';   # allow symbolic ref string Mat1, etc.
use Data::Dumper;

ReadMatrix('junk.txt');


sub ReadMatrix {
  my ($fname) = @_;

  open FILE, $fname || die "$0: can't open file: $!\n";

  my $matrix_name;

  while ( chomp(my $line = <FILE>) ) {
    next if $line =~ /^\s*$/;  # skip blank lines
    if ( $line =~ /^([A-Za-z]\w*)/ ) {
      $matrix_name = $1;
    } else {
      my (@row) = split /\s+/, $line;  # *must* use my()
      #      symbolic ref, same as @Mat1 in this case.
      push @{$matrix_name}, \@row; # insert anon row-array into outer matrix 
      #    ^^^^^^^^^^^^^^^
    }
  }

  print Dumper(@{$matrix_name});

  close FILE;
}

__END__
:w this into
junk.txt before running:

Mat1
1  2  3
 
10 20 30
11 22 33
