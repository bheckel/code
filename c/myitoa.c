#include <stdio.h>

/* Integer to ascii. */
/* Better to use sprintf instead of this. */

int main() {
  char string[2];
  /* Ascii 49 */
  int i = 1;

  /*               48    */
  string[0] =  i + '0';
  string[1] = '\0';

  printf("integer %i is stringified: %s", i, string);

  return 0;
}

