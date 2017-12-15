/*****************************************************************************
 *    Name: printf_n.c
 *
 * Summary: Demo of printf's %n specifier.
 *          When the %n is encountered, printf() assigns the integer pointed
 *          to by the associated argument the number of characters output so
 *          far.
 *
 * Adapted: Thu, 31 Aug 2000 12:24:14 (Bob Heckel -- from Teach Yourself C 2nd
 *                                     Edition)
 *****************************************************************************
*/
#include <stdio.h>

int main(void) {
  int i;
  char *cp;

  cp = "twisty maze";

  //                           pointer to an int
  printf("String: %s\n%n", cp, &i);
  // Includes newline in the count.
  printf("Chars printed: %d\n", i);

  puts("Should be 20 including the newline");

  return 0;
}
