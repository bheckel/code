/*****************************************************************************
 *     Name: ltrim_minimal.c
 *
 *  Summary: Left trim basic demo.  See ltrim.c for version that returns a
 *           pointer to the modified string.
 *
 *  Created: Wed 31 Jul 2002 15:18:05 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <ctype.h>

void ltrim(char str[]) {
  int charsfound = 0;

  while ( *str != '\0' ) {
    if ( isalpha(*str) ) {
      ++charsfound;
      printf("%c_", *str);
    }

    if ( !isalpha(*str) && charsfound )
        printf("%c_", *str);

    str++;
  }
}


int main(void) {
  // Either work.  TODO shouldn't the ptr version fail occasionally?
  ///char *s = " mullholland   drividlynch";
  char s[] = " mullholland   drividlynch";
   
  ltrim(s);

  return 0;
}
