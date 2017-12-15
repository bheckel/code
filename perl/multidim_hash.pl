#!/usr/bin/perl -w
##############################################################################
#    Name: multidim_hash.pl
#
# Summary: Demo of multi dimensional hashes.
#
# Adapted: Sun, 03 Dec 2000 14:18:59 (Bob Heckel -- from PerlArchive.com)
##############################################################################

# Using key/value pairs is great, but what if you wanted to associate more
# than one value to a key? Using a slightly different construct, you can
# essentially use an array as a key's value:
%hash = (
  Apples               => [4,	"Delicious red", "medium"],
  "Canadian Bacon"     => [1,	"package",       "1/2 pound"],
  artichokes           => [3,	"cans",          "8.oz."],
  Beets                => [4,	"cans",          "8.oz."],
  "5 Spice Seasoning"  => [1,	"bottle",        "3 oz."],
  "10 Star Flour"      => [1,	"package",       "16 oz."],
  "911 Hot Sauce"      => [1,	"bottle",        "8 oz."],
);

# Now, to extract the values, you can treat them as an array of the hash: E.g.
# print $hash{"Canadian Bacon"}[1]; will print package, because package is the
# second element of Canadian Bacon's "array". You can also add an predefined
# array to a hash value: 
# @garlicstuff = (4, "cloves", "medium");
# $hash{"Garlic"} = [@garlicstuff];
# print $hash{"Garlic"}[1]; # prints cloves

# But what if @garlicstuff had more elements than others? Let's say that
# @garlicstuff is 
@garlicstuff = (4, "cloves", "medium", "chopped");
$hash{"Garlic"} = [@garlicstuff];
# instead? How do we print out all values for a key if one key can have 3
# values, and another has 4 (or more) values? 
foreach my $key (sort keys %hash){
  print "$key: \n";
  #                ______________
  foreach my $val (@{$hash{$key}}){
  print "\t$val\n";
  }
  print "\n";
}
# Because a multidimensional hash's values are essentially arrays, a key's
# group of values can be dereferenced by using @{$hash{$key}}.



###############
# Example using anon hash instead of anon arrays:

my %hash2 = (
  name   => { fore => "Steve", sur  => "Cook" },
  age    => 26,
  weight => 160,
);
###my $forename = $hash2{name}->{fore};
# Better
my $forename = $hash2{name}{fore};
my $age      = $hash2{age};
print "name $forename, age $age\n";
