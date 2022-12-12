/*****************************************************************************
 *     Name: fgline.c
 *
 *  Summary: Demo of getting lines of a file.  See getline.c for getting lines
 *           from standard input (stdin).
 *
 *  Created: Sun 04 Aug 2002 10:20:08 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

// Read one line from fp, copying it to line array (but no more than max
// chars).  Skips any carriage returns.  Does not place terminating \n in line
// array.  Returns line length, or 0 for empty line, or EOF for end-of-file. 
int fgline(FILE *fp, char line[], int max) {
  int nch = 0;
  int c;

  max = max - 1;			/* leave room for '\0' */

  while ( (c = getc(fp)) != EOF ) {
    if ( c == '\n' )
      break;

    if ( nch < max && c != '\r' ) {
      line[nch] = c;
      ///nch = nch++;    // DON'T try this
      nch = nch + 1;
    }
  }

  if ( c == EOF && nch == 0 )
    return EOF;

  line[nch] = '\0';

  return nch;
}


int main(void) {
  char *filename = "junk.txt";
  FILE *ifp;
  char line[80];
  int n;

  if ( (ifp = fopen("junk.txt", "r")) == NULL ) {
    fprintf(stderr, "can't open %s\n", filename);
    exit(1);
  }

  while ( (n = fgline(ifp, line, 256)) != EOF ) {
    fprintf(stderr,"ok xx%syy\n", line);
    fflush(stderr);
    fprintf(stderr,"len %d\n", n);
    fflush(stderr);
  }

  fclose(ifp);

  return 0;
}
