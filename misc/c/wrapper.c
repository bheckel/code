// Allow a Perl program to run under a different uid (setuid).
// Assumes /webshop/bin/cadfile_copy.pl exists and uses Perl's $ARGV[0] and
// $ARGV[1].

#include <stdio.h>

int main(int argc, char *argv[]) {
  int rc = execl("/webshop/bin/cadfile_copy.pl", "cadfile_copy.pl", 
                  argv[1], argv[2], NULL);

  if ( rc == 0 ) {
    return 0;
  } else {
    return 1;
  }
}
