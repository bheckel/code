// Allow a Perl program to run under a different uid (setuid).
// Assumes helloworld.pl exists and uses Perl's $ARGV[0] and $ARGV[1].
// $ gcc -o helloworld wrapper.c
// $ ./helloworld onefoo twofoo
// Modified: Wed 08 Aug 2001 10:50:14 (Bob Heckel)

#include <stdio.h>

int main(int argc, char *argv[]) 
{
  // helloworld.pl is supplied once to name the program to execute and a
  // second time to supply a value for 'argv[0]'
  execl("helloworld.pl", "helloworld.pl", argv[1], argv[2], NULL);

  return 0;
}
