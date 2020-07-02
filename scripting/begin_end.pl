#!/usr/bin/perl -w

# Demo of begin and end statements.

BEGIN {
  unshift(@INC, '/opt/lib/perl5/site_perl/5.8.4/i86pc-solaris/auto/DBI');
}

print "Hello prints second\n"; 
BEGIN {print "Greetings prints first\n";} 
END {print "Leaving prints fourth\n";}  
print "Goodbye prints third\n"; 
