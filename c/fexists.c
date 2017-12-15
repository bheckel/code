/*****************************************************************************
 *     Name: fexists.c
 *
 *  Summary: Determine if a file exists.
 *
 *  Created: Sat 03 Aug 2002 22:52:59 (Bob Heckel)
 * Modified: Mon 05 Aug 2002 10:15:53 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

#define TRUE 1
#define FALSE 0


int exists(char * fname) {
  FILE *f;

  if ( (f = fopen(fname, "r")) == NULL )
    return FALSE;
  else {
    fclose(f);
    return TRUE;
  }
}


int main(int argc, char *argv[]) {
  int rv;

  rv = exists("junk.txt"); 

  return !rv;
}
