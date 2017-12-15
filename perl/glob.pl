#!/usr/bin/perl -w

# Modify symbol table with globs (typeglobs).  Many things can be done better
# with packages, references and OOP nowadays.

$barney = 3;
$fred   = 5;
$wilma  = 7;
@barney = (1,2,4);

# Non-selective assigment.  Makes $fred an alias for $barney, @fred an alias
# for @barney, etc.
*fred = *barney;

print "\$barney is $barney\n";
print "\$fred is $fred\n";

print "\@barney is @barney\n";
print "\@fred is @fred\n";

# Selective (polymorphic) assigment.
*fred = \&wilma;
print "\$fred is still $fred (not 7) after selective assigment.\n";
# Not calling the original fred() due to glob.
fred();

$ref_to_wilma = \&wilma;
&$ref_to_wilma;


sub wilma { print "inwilma\n"; }
sub fred { print "infred\n"; }


# Principle behind the *fred = *barney line is the same as this simple hash
# assignment:
%hash1 = (
  one   => 90,
  two   => "xx\n",
  three => 3,
);
%hash2 = ();
%hash2 = %hash1;
print $hash2{two};
