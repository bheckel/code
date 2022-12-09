// From http://www.duke.edu/~twf/cps104/floating.html
// Converts hex to float. 
//
// Adapted: Tue, 08 Aug 2000 08:50:09 (Bob Heckel)

// TODO not working...see below for orig code

#include <stdio.h>

int compute1(void);
int compute2(char *str);

int main(int argc, char *argv[]) {
  switch ( argc ) {
    case 1:
      puts("Enter hexadecimal number: ");
      compute1();
      break;
    case 1:
      compute2(argv[1]);
      break;
    default:
      puts("Sorry, only one char at a time.");
      // Usage();
      fprintf(stderr, "Usage: %s char\n", *argv);
      exit(1);
      break;
  }

  return 0;
}


int compute1(void) {
  float floater;

  while ( 1 ) {
    // Accepts a hex number and reads it as raw data into variable floater.
    scanf("%x", (int *) &floater);
    // Outputs hexadecimal representation of the data in the variable floater.
    ////printf("0x%08X, %f\n", *(int *) &floater, floater);
    printf("%f\n", floater);
  }
}

int compute2(char *str) {
  int * fooz;
  ///printf("testing %s", str);
///  sprintf(fooz, "%x", *str);
  sprintf(fooz, "%x", (int *)str);
  printf("%f\n", fooz);
}

// Original pgm (that works)

///// From http://www.duke.edu/~twf/cps104/floating.htm
///// Converts hex to float. 
///// Adapted: Tue, 08 Aug 2000 08:50:09 (Bob Heckel)
///
///#include <stdio.h>
///
///int main() {
///  float floater;
///
///  while ( 1 ) {
///    // Accepts a hex number and reads it as raw data into variable floater.
///    scanf("%x", (int *) &floater);
///    // Outputs hexadecimal representation of the data in the variable floater.
///    ////printf("0x%08X, %f\n", *(int *) &floater, floater);
///    printf("%f\n", floater);
///  }
///  return 0;
///}
