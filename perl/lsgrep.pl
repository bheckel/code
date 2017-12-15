#!/usr/bin/perl -w
# lsgrep - print selected lines of ls output by
#          compiling user queries into code
#
#          Cygwin version.
#
# Adapted: Fri Jan 14 13:30:06 2005 (Bob Heckel Tom Christiansen
#                             file:///C:/bookshelf_perl/cookbook/ch01_19.htm )

use strict;

# each field from the PS header
my @fieldnames = qw(perms wtf uid group size mo day time file);

# determine the unpack format needed (hard-coded for Linux ps).  To port to
# other systems, look at which columns the headers begin at. 
my $fmt = Cut2Fmt(qw/14 16 25 32 43 47 50 56/);

my %fields;                         # where the data will store

die <<EOT unless @ARGV;
usage: $0 criterion ...
    Each criterion is a Perl expression involving:

    @fieldnames  (case insensitive)

    All criteria must be met for a line to be printed.

    E.g.
    lsgrep 'user eq "bqh0"'
    lsgrep 'file =~ /2003/'
EOT

# Create function aliases for uid, size, UID, SIZE, etc.
# Empty parens on closure args needed for void prototyping.
for my $name ( @fieldnames ) {
  no strict 'refs';
  *$name = *{lc $name} = sub () { $fields{$name} };
}

my $code = "sub is_desirable { " . join(" and ", @ARGV) . " } ";
# The mysterious ".1" at the end is so that if the user code compiles, the
# whole eval returns true. That way we don't even have to check $@ for
# compilation errors.
unless ( eval $code . 1 ) {
  die "Error in code: $@\n\t$code\n";
}

open(PS, "/bin/ls -lR |") || die "cannot fork: $!";
while ( <PS> ) {
  @fields{@fieldnames} = Trim(unpack($fmt, $_));
  print if is_desirable();   # line matches their criteria
}
close(PS) || die "ps failed!";

# Convert cut positions to unpack format
sub Cut2Fmt {
  my(@positions) = @_;

  my $template  = '';
  my $lastpos   = 1;

  for my $place ( @positions ) {
    $template .= "A" . ($place - $lastpos) . " ";
    $lastpos   = $place;
  }
  $template .= "A*";

  return $template;
}

sub Trim {
  my @strings = @_;

  for ( @strings ) {
    s/^\s+//;
    s/\s+$//;
  }

  return wantarray ? @strings : $strings[0];
}

# the following was used to determine column cut points.
# sample input data follows
#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
__DATA__
-rw-r--r--    1 bqh0     Users           0 Sep 22 12:46 200001010000
drwxr-xr-x    3 bqh2     Users           0 Nov 16 16:39 2003/
-rw-r--r--    1 bqh0     Users       57154 Sep 14 12:44 BQH0AK0325M.PDF
-rw-r--r--    1 bqh0     Users      181559 Nov  4 15:58 BQH0ID2004N.ONQTR.pdf
-rw-r--r--    1 bqh0     Users      115479 Dec 22 10:36 BQH0ID2004NON.QTR.pdf
-rw-r--r--    1 bqh0     Users       22503 Dec  9 13:31 BQH0NC2004NOO.QTR.pdf
