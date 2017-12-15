#!/usr/bin/perl -w

@numbers = (3, 56, 23, 4, 456); 

@sorteddesc = sort @numbers;  
print "asciibetical: @sorteddesc\n";

# Spaceship operator
@sorteddesc = sort {$a<=>$b} @numbers;  
print "normal: @sorteddesc\n";

@sorteddesc = sort {$b<=>$a} @numbers;  
print "reversed: @sorteddesc\n";


#######
# TODO why is this not working?
@mixedcase = ("apple", "Aap", "beta", "Bamboo");

###sort @mixedcase;
print sort "@mixedcase";
print "\n";
###sort nocase @mixedcase;
###print "@mixedcase";

###sub nocase { uc($a) cmp uc($b) }
#######
