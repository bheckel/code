/*****************************************************************************
 *     Name: ltrim.c
 *
 *  Summary: Left trim demo.  Strips leading spaces, leaves internal and
 *           trailing spaces alone.
 *
 *  Created: Wed 31 Jul 2002 15:18:05 (Bob Heckel)
 * Modified: Sat 30 Aug 2003 10:57:19 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void ltrim(char s[]) {
  while ( *s == ' ' ) {
    //    dest src    n bytes to move
    memmove(s, s+1, strlen(s));
    printf("%d ", strlen(s));
  }
}


int main(void) {
  // No no no
  ///char *str = "  mullholland  dr ";
  char str[] = "  mullholland  dr ";
   
  printf("%s\n", str);
  ltrim(str);
  printf("\n%s\n", str);

  return 0;
}
