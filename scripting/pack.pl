#!/usr/bin/perl -w
##############################################################################
#     Name: pack.pl
#
#  Summary: Demo of pad strings.  Padding.  And demo of  breaking out column 
#           delimited data.
#
#           pack is a good option when you need to be frugal about space,
#           because it converts a list of values into one scalar value without
#           necessarily changing each individual item's machine
#           representation.
#
#           See parse_fixed_width.pl for splitting a delimited positional file.
#
#  Created: Mon 26 Mar 2001 16:47:16 (Bob Heckel)
# Modified: Mon 23 Dec 2002 10:05:20 (Bob Heckel)
##############################################################################

##############
# Simple
##############
# Decimal to ASCII
print pack 'CCCC', 80, 101, 114, 108;
# Hex to ASCII
print pack 'H2H2H2H2', '50', '65', '72', '6c';
# or
print pack 'H*', '5065726c';
print "\n\n";


##############
# Padding
##############
$x = 'fiveX';
$y = 'twentyfive--------------Y';
$z = 'twentysix----------------Z';

# Space padded string of bytes.
$foo = pack('A25', $x);
print $foo, '<<<';
print "\n";
$foo = pack('A25', $y);
print $foo, '<<<';
print "\n";
$foo = pack('A25', $z);
print $foo, '<<<';
print "\n\n";


##############
# Break out
##############
chomp(@ps = `ps`);
shift @ps;
# Cygwin:
#       PID    PPID    PGID     WINPID  TTY  UID    STIME COMMAND
# ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
#      1680       1    1680       1680  con 1001   Dec  9 /usr/bin/rxvt
for ( @ps ) {
  ($pid, $ppid, $tty) = unpack '@5 A4  @13 A4  @38 A3', $_;
  print "PID: $pid  PPID: $ppid  TTY: $tty\n";
}
