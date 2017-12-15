#!/usr/bin/perl -w

# Alternative:
# $ perl -e 'print "Hello ";' -e 'print "World\n"'

# Must also install (only) Lingua::EN::Inflect 
###use Coy;

# Or can use   $ perl -e 'print "Hello World\n"'
# Or           $ echo "print qq(Hello @ARGV)" | perl - World 

# Customized Hello is provided if name passed on commandline.
if ( $#ARGV >= 0 ) { 
  $whodat = join(' ', @ARGV);
} else {
  $whodat = 'World';
}

# Good demo of random selection:
print "Hello ", ('fellow', 'you')[rand 2], " $whodat!\n";

# Test Coy:
warn "Hal, we seem to have a problem.";
die "A bad one.";

