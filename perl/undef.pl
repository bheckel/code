#!/usr/bin/perl -w

# Variables have the undef value before they are first assigned or when they
# become "empty." 
# 
# For scalar variables, undef evaluates to zero when used as a
# number, and a zero-length, empty string ("") when used as a string.
# 
# From TPJ Summer 1999 What is Truth?
# 
# undef
# Perl was designed for system administrators who want to automate the
# automatable tasks of their jobs. Such people typically produce small
# programs, and don't need to worry about formally verifiable correctness,
# corporate coding standards, and other such things. They just want to get the
# job done.  For this reason, Perl's default behavior allows the programmer to
# be lazy and leave off parentheses around function arguments, to use
# subroutines before they're defined, and to use variables without
# initializations or even definitions. However, these very same practices that
# enable small programs to be written quickly can bog down larger programs by
# permitting subtle errors.  By assuming that the programmer is all-knowing
# and perfect, Perl fails to notice things that smart and lazy programmers do
# deliberately but are mistakes for the rest of us. That's what Perl's -w flag
# is for. The -w flag turns on warnings for ambiguous or possibly erroneous
# practices. One of the things it catches is the use of a variable before it
# has a value. Here's the simplest possible demonstration of that: 
# 
 
print $x;

# This actually generates two warnings: main::x only used once and use of
# uninitialized value The first warning comes after Perl has finished
# compiling our program and realizes "hey, I only saw that variable once.
# That's probably a mistake." The second warning comes at runtime, when we
# attempt to print out $x without having given it a value. In cases like
# these, $x contains "the undefined value" or "the uninitialized value" and is
# written as undef This value is completely separate from any other Perl
# value: it isn't the empty string, nor is it zero. It's almost like NULL in
# C. undef is a special value used whenever a variable hasn't yet been
# assigned a value. We can test for undef with the defined function: 

if (defined $x) {
    print "x has value $x\n";
} else {
    print "x is undefined\n";
}

# Any attempt to use $x as though it were a real value (by treating it like a
# string or a number, for instance) generates a warning at runtime if you're
# using -w. This means we can't use == or eq with $x since those are number
# and string comparison operators and we'll get a warning for trying to use
# undef as a number or string. If we do try, Perl will emit its warning if we
# used -w but keep on going whether or not we used -w This is how the lazy
# programmers were able to leave warnings off and have their code still work:
# Perl treats undef as either zero or the empty string. That's why we don't
# see anything when we try to print an undefined variable. Similarly: 

  
$y = $x + 3;       # $y = 3, warning emitted
$y = length $x;    # $y = 0, warning emitted

# We can return a scalar variable to its initial pristine undefined state by
# using undef as either a function or a value: 

undef $x;
$x = undef;

# defined and undef are good for testing and setting scalars. Don't try them
# with arrays, though. Presently, defined(@array) returns true if Perl has
# allocated storage for array something that is weird and not useful to the
# average programmer. To return an array to its initial state, we say: 
 
@array = ();        # good

# To say @array = undef is to make @array contain a one-element list, with the
# single element being the scalar value undef. This is hardly ever what we want. 

# undef plus one is one.  So this works to count occurrences of words.
chomp(@words = <STDIN>);      # Read the words, minus newlines
foreach $word (@words) {
  $count{$word} = $count{$word}++
}

