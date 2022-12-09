/*****************************************************************************
 *    Name: getopt.c
 *
 * Summary: Demo of obtaining switches from the command line.
 *
 * Adapted: Thu 09 Aug 2001 10:25:34 (Bob Heckel--libc.txt)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>

int main(int argc, char **argv) {
  int aflag = 0;
  int bflag = 0;
  char *cvalue = NULL;
  int index;
  int c;

  opterr = 0;

  // 'getopt' returns '-1', to indicate no more options are present.
  while ( (c = getopt(argc, argv, "abc:")) != -1 )
    switch ( c ) {
      case 'a':
        aflag = 1;
        break;
      case 'b':
        bflag = 1;
        break;
      case 'c':
        cvalue = optarg;
        break;
      case '?':
        if ( isprint (optopt) )
          fprintf (stderr, "Unknown option `-%c'.\n", optopt);
        else
          fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
        return 1;
      default:
        abort();
    }

  printf ("aflag = %d, bflag = %d, cvalue = %s\n", aflag, bflag, cvalue);

  for ( index=optind; index<argc; index++ )
    printf ("Non-option argument %s\n", argv[index]);

  return 0;
}
