/*****************************************************************************
 *    Name: case.c
 *
 *  Summary: Demo of the case switch statement.  Also see Vim imap CsW
 *
 *  Created: Sun Feb 29 10:15:40 2004 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
  ///int ch;
  char* ch;

  switch ( argc ) {
    case 1:
      puts("no arg passed in");
      break;   // don't fall-thru
    case 2:
      ch = argv[1];
      if ( strncmp(argv[1], "h", 1) == 0 ) {
        fprintf(stderr, "Found an h: %s\n", *argv);
        exit(EXIT_SUCCESS);
      } else {
        printf("one arg passed in NOT AN H: %s %d\n", ch, strncmp(argv[1],"h",1));
      }
      break;
    default:
      puts("Sorry, only one char at a time.");
      exit(EXIT_SUCCESS);
      break;
  }

  return 0;
}

