#!/usr/bin/perl -w

###open FH, 'junk' or die "Error: $0: $!";
open FH, 'limslogins.txt' or die "Error: $0: $!";

@line=<FH>;

$n = 0;

for $line ( @line ) {
  next if $line =~ /^$/;
  if ( $line =~ /^\w/ ) {
    ($day, $month, $date, $yr, $time) = split ' ', $line;
    $date =~ s/,//g;
  } else {
    ($uid, $pid) = split ' ', $line;
###    print "$day $month $date $time - $pid\n";
    $x = "$date $month $yr $time - $pid\n";
    # Mon, Sep 23, 15:06:52 - 28817
    # Push into hash
###    %h = map /^(.*) - (.*)$/gm, $x;  WRONG
    $h{ $_->[0] } = $_->[1] for [ split /-/, $x ];
  }
}

###while ( (my $k, my $v) = each %h ) { print "$k=$v"; }
foreach my $k ( sort keys %h ) { print "$k=$h{$k}\n"; }
