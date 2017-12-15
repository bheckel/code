#!/usr/bin/perl -w
##############################################################################
#     Name: parse_fixed_width.pl (s/b symlinked as column_delimited.pl)
#
#  Summary: Demo of parsing a fixed width textfile at specific column numbers.  
#
#           Could use substr() or regexes but pack is best for fixed width.
#             E.g.
#             m/^(..)(.)(.*)/;
#             $grid[0] = $1;
#             $grid[1] = $2;
#             $grid[2] = $3;
#
#           see http://perldoc.perl.org/perlpacktut.html
#
#  Created: Thu 24 Apr 2003 16:16:39 (Bob Heckel)
# Modified: Tue 30 Oct 2007 14:42:41 (Bob Heckel)
##############################################################################

###open FH, 'junk' or die "Error: $0: $!";

my @grid = ();
my %h = ();

while ( <DATA> ) {
  push @grid, [ unpack '@0 A14  @14 A15  @35 A2  @39 A*', $_ ];
}

use Data::Dumper;print Dumper @grid ;

###print $grid->[1][1];      # NO b/c we're using an array proper, @grid,
                             # not a ref to an array
###print $grid[1]->[1];      # YES
###print $grid[1][1];        # YES

for ( @grid ) {
  print @{$_}[2], "\n";

  $tmpkey = @{$_}[0];
  $tmpval = @{$_}[2];

  # Concise but not readable:
  ###$h{@{$_}[0]} = @{$_}[2];
  # so use this to fill the hash:
  $h{$tmpkey} = $tmpval;
}

foreach ( keys %h ) {
  $tot += $h{$_} if $h{$_};
}
$tot = sprintf "%.2f", $tot;
print $tot;


# Save manual counting (from perl faq, untested):
#################################################
#   # determine the unpack format needed to split Linux ps output
#   # arguments are cut columns
#   my $fmt = cut2fmt(8, 14, 20, 26, 30, 34, 41, 47, 59, 63, 67, 72);
#
#   sub cut2fmt {
#       my(@positions) = @_;
#       my $template  = '';
#       my $lastpos   = 1;
#       for my $place (@positions) {
#           $template .= "A" . ($place - $lastpos) . " ";
#           $lastpos   = $place;
#       }
#       $template .= "A*";
#       return $template;
#   }
#################################################


#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
__DATA__
this is 1     space delimited      66  998
this is l2    moredataherexxx          42   
last  one     yetanotherdatal      68  43   
