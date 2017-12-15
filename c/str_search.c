/*****************************************************************************
 *     Name: str_search.c
 *
 *  Summary: Determine the number of tokens found in a string.
 *
 *  Created: Wed 05 Dec 2001 15:45:30 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  char s[] = "fooxstrxing";  
  int i, j;

  j = 0;
  for ( i=0; s[i]!='\0'; i++ ) {
    if ( s[i] == 'x' ) {
      printf("found %c\n", s[i]);
      j++;
    } else {
      puts("not found");
    }
  }

  printf("found total %d instance(s) of x\n", j);

  return 0;
}
