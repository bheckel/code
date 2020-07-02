#!/usr/bin/perl -w

# Split on each character:
# foreach my $char ( split //, $string ) { ... }


# This block is the same as:
# $ ps | awk '{print $3}'
foreach ( `ps` ) {
  chomp;
  ###@line =  split /\s+/, $_;
  ###print "$line[3]\n";

  ###($zero, $one, $two, $three, $four) =  split /\s+/, $_;
  ###print $four, "\n";

  # Better
  (undef, $three) =  (split /\s+/, $_)[1,3];
  print $three, "\n";
}

---

print split /\s+/, "foo   bar baz";

print "\n";

@x = split /\s+/, "foo   bar baz";
print "@x";

---

###while ( <DATA> ){
  ###$field =  (split /;/, $_)[1];
  ###print "$field\n";
###}

while ( <DATA> ) {
  # Only want two chunks split
  ($who, $rest) = split /;/, $_, 2;
  # Then split the 2nd chunk
  @fields = split ';', $rest;
  print @fields;
}



__DATA__
foo;bar;baz;boom
foo2;bar2;baz2;boom2
