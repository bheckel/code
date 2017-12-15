/*****************************************************************************
 *     Name: memcopy.c
 *
 *  Summary: Demo of void pointers using a version of the library function
 *           memcpy().  Copy any sequence of bytes from one place to another.
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h>

void* memcopy(void* target, const void* source, size_t n) {
  /* Copy any object to another.  Uses char since they are 1 byte each. */
  char* targetp = (char*) target;
  const char* sourcep = (const char*) source;

  while ( n-- )  // size of first param passed
    *targetp++ = *sourcep++;

  return target; 
} 


int main(void) {
  int x = 1, y = 2;
  double z = 1.0, zz = 2.0;
  char *word1 = "one";
  char *word2;

  word2 = "two";

  /* Would have been much easier to just assign y to x but this is a demo. */
  memcopy(&x, &y, sizeof x);
  printf("%d\n", x);

  memcopy(&z, &zz, sizeof z);
  printf("%f\n", z);

  memcopy(&word1, &word2, sizeof word1);
  printf("%s\n", word1);

  return 0;
}
