#!/usr/bin/perl

# $ variable_args_ARGV.pl foo bar

map { print "$_\n" } @ARGV;


__END__
###$numArgs = $#ARGV + 1;
$numArgs = @ARGV;  #counts the number of elements in @ARGV in scalar context 
print "thanks, you gave me $numArgs command-line arguments.\n";

foreach $argnum (0 .. $#ARGV) {
  print "$ARGV[$argnum]\n";
}
