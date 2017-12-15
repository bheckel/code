/*****************************************************************************
 *     Name: tmpfile.c
 *
 *  Summary: Temp file demo.
 *           TODO needs work.  Look into other versions in libc.
 *
 *  Created: Sat 23 Mar 2002 13:58:12 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int main(int argc, char *argv[]) {
  FILE *tmpfp;
  int x;

  // File is written to $TEMP.
  tmpfp = tmpfile();

  gets(x);
  // TODO segfault
  fprintf(tmpfp, "written %s");
  fclose(tmpfp);

  return 0;
}
