/*****************************************************************************
 *     Name: open_write.c
 *
 *  Summary: Log each user's login to a textfile.
 *
 *  Created: Tue Jul 09 11:25:54 2002 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int main(void) {
  time_t tval;
  char *fname = "junk.txt";
  // A file pointer is a data structure which helps us access or manipulate
  // the file. 
  FILE *fptr;   // handle by which we refer to the stream

  tval = time(NULL);

  //                    append
  if ( (fptr = fopen(fname, "a")) == NULL ) {
    printf("cannot open %s.  Exiting\n", fname);
    return 1;
  }

  fprintf(fptr, "User: %s logged in at: %s", getenv("USER"), ctime(&tval));
  ///sleep(20);

  if ( fclose(fptr) == EOF ) {
    printf("cannot close %s.  Exiting.\n", fname);
    return 1;
  }

  return 0;
}
