// Wrapper allows a Perl program to run under a different uid.
//
// $ gcc wrapper_setuid.c
//
// Assumes you will next do
// $ chmod +s as gr8xprog
// -rwsr-sr-x   1 gr8xprog staff      15792 Aug  6 16:34 a.out

int main(int argc, char *argv[]) {
  execv("/opt/sod", argv);

  return 0;
}
