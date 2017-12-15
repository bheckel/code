#!/perl/bin/perl -w

# Parse the output of the date command to get the current day of the week.
if (`date` =~ /^S/) {
  print "It's Sat or Sun.\n";
} else {
  print "It's a weekday.\n";
}

# Variation bobh method using an array:
$a = `date`;
print $a;
@b = split (/ +/, $a);
print "@b\n";
print "It's $b[0] on the $b[2]th of $b[1]\n\n";

# Take a colon delimited file, create an array from two of its elements, then
# put those elements in a hash.
open(PASWD, "/home/bh1/passwd");
while(<PASWD>) {
  chomp;
  #   0               4
  # merlyn::118:10:Arandal, Randy:/home/merlyn:/usr/bin/perl;
  ($user, $gcos) = (split /:/) [0,4];
  #      key     value   %real is the hash being created.
  $real{$user} = $gcos;
}

while (($key, $value) = each %real) {
  print "Key is $key and Value is $value\n";
}

print "This gives identical output:\n";

foreach $userid (sort keys %real) {
  print "Key is $userid and Value is $real{$userid}\n";
}

# Test %real in a scalar context. If true, then something is in %real.
if (%real) {
  $noofelements = keys(%real);
  print  "$noofelements elements in the hash \%real.\n\n";
}

