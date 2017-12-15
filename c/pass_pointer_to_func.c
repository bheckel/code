/********************************************************
 * tmp_name -- Return a temporary filename.             *
 *                                                      *
 * Each time this function is called, a new name will   *
 * be returned.                                         *
 *                                                      *
 * Returns                                              *
 *      Pointer to the new filename.                    *
 *                                                      *
 * Adapted: Mon 20 Aug 2001 17:56:59 (Bob Heckel --     *
 *                                    Practical C       *
 *                                    Programming * 3rd *
 *                                    Editiion)         *
 ********************************************************/
#include <stdio.h>
#include <string.h>

/* The problem is that this function is tricky to use. A better design would
 * make the code less risky to use. For example, the function could take an
 * additional parameter: the string in which the filename is to be
 * constructed:
 * void tmp_name(char *name_to_return);
 */
char *tmp_name(void) {
  static int sequence = 0;    /* sequence number for last digit */
  static char name[30]; /* name we are generating (must be static or global) */

  ++sequence; /* move to the next filename */

  strcpy(name, "bobh");

  name[3] = sequence + '0';

  name[4] = '\0'; /* end the string */

  return(name);
}
 
int main(void) {
  // Won't work as an automatic variable.
  ///char name[30];       /* the name we are generating */
  char *foo;

  foo = tmp_name();       /* get name of temporary file */
  printf("Name: %s\n", foo);

  // Easier approach.
  printf("Name: %s\n", tmp_name());

  return(0);
}
