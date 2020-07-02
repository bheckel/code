#!/usr/bin/perl -w
##############################################################################
# psgrep - print selected lines of ps output by
#          compiling user queries into code
#
#          Cygwin version.  TODO leading I etc zombie junk screws up results
#
# Adapted: Fri Jan 14 13:30:06 2005 (Bob Heckel Tom Christiansen
#                             file:///C:/bookshelf_perl/cookbook/ch01_19.htm )
##############################################################################

use strict;

# each field from the PS header
my @fieldnames = qw(PID PPID PGID WINPID TTY UID STIME COMMAND);

# Determine the unpack format needed (hard-coded for Linux ps).  To port to
# other systems, look at which columns the headers begin at (I think). 
# Ignore columns starting in pos 1.
my $fmt = Cut2Fmt(qw/11 20 30 37 42 48 56/);

my %fields;                         # where the data will store

die <<EOT unless @ARGV;
usage: $0 criterion ...
    Each criterion is a Perl expression involving:

    @fieldnames  (case insensitive)

    All criteria must be met for a line to be printed.

    E.g.
    psgrep '/sh\b/'
    psgrep 'command =~ /sh\$/'
    psgrep 'command =~ /^-/' 'tty ne "?"'

    You'll probably want to use 'eq' instead of '=='
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

open(PS, "ps |") || die "cannot fork: $!";
print scalar <PS>;  # emit header line
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
      PID    PPID    PGID     WINPID  TTY  UID    STIME COMMAND
     1536       1    1536       1536  con 14278 17:32:21 /usr/bin/rxvt
I    1556    1536    1556       1576    0 14278 17:32:22 /usr/bin/bash
     1608    1556    1556       1612    0 14278 17:32:28 /home/bqh0/bin/blink
      304       1     304        304    1 14278 17:32:40 /usr/bin/rxvt
     1640     304    1640       1672    2 14278 17:32:40 /usr/bin/bash
     1728    1640    1640       1696    2 14278 17:32:40 /home/bqh0/bin/blink
