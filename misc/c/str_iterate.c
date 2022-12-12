/*****************************************************************************
 *     Name: str_iterate.c
 *
 *  Summary: Iterate over each letter in a string.
 *
 *  Created: Sun 24 Feb 2002 20:54:17 (Bob Heckel)
 * Modified: Wed 31 Jul 2002 15:49:16 (Bob Heckel -- more concise example)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  char *str, *str2;

  str = "THIS is the girl";

  while ( *str ) {
    printf("%c\n", str[0]);
    str++;
  }

  // This is better:
  str2 = "mullholland drividlynch";

  while ( *str2 != '\0' ) {
    printf("%c_", *str2++);
  }

  return 0;
}
