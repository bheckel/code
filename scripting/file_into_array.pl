#!/usr/bin/perl -w

open FH, 'junk.txt' or die "Error: $0: $!";

# Better?
###@data = <FH>;
###for $line ( @line ) { ...

while ( <FH> ){
  push @data, $_;
}
print @data;


__END__
foo bar
bar
