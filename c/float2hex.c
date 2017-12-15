// From http://www.duke.edu/~twf/cps104/floating.htm
// Converts float to hex. 
//
// ESSENTIAL
// 
// Adapted: Thu, 10 Aug 2000 15:46:51 (Bob Heckel)

#include <stdio.h>

int main() {
  float floater;

  while ( 1 ) {
    scanf("%f", &floater);
    printf("0x%08X, %f\n", *(int *)&floater, floater);
  }
  return 0;
}

// Compare to hex2float:
//int main() {
//  float floater;
//
//  while ( 1 ) {
//    // Accepts a hex number and reads it as raw data into variable floater.
//    scanf("%x", (int *) &floater);
//    // Outputs hexadecimal representation of the data in the variable floater.
//    ////printf("0x%08X, %f\n", *(int *) &floater, floater);
//    printf("%f\n", floater);
//  }
//  return 0;
//}
