/*****************************************************************************
 *     Name: readfile.c (symlinked as open.c)
 *
 *  Summary: Read a file from hard drive.  Poor man's cat.
 *
 *  Adapted: Fri, 31 Dec 1999 13:47:57 (Bob Heckel)
 * Modified: Thu 11 Oct 2001 17:07:49 (Bob Heckel)
 *****************************************************************************
*/

#include <stdio.h>

int main(void) {
  FILE *fp;
  char letter;

  /* junk is the filename in the CWD. */
  if ( (fp = fopen("junk","r")) == NULL ) {
    puts("Cannot open the file");
    exit(__LINE__);
  }

  while ( (letter = fgetc(fp)) != EOF ) {
    printf("%c", letter);
  }

  fclose(fp);

  return 0;
}

