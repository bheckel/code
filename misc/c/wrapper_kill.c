// Allow a Cygwin program to run under a different uid (setuid).
// Assumes winkill.exe exists and uses Perl's $ARGV[0] and
// $ARGV[1].

#include <stdio.h>

int main(int argc, char *argv[]) {
  int rc = execl("/home/bheckel/bin/winkill", "winkill", 
                  argv[1], argv[2], NULL);

  if ( rc == 0 ) {
    return 0;
  } else {
    return 1;
  }
}
