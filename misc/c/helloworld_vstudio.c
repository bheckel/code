/* Demo from MSDN Library.
 * Adapted: Mon, 15 Jan 2001 12:54:31 (Bob Heckel)
 *
 * See helloworld_vstudio.tar.gz for the whole project (which includes this
 * file).
 *
 * Used Wizard Commandline Empty to create the Project.
 * Added empty text file and pasted this code into it.
 * Then this file was added via menu:Project:Add To Project:File
 *
 * Sample call (from command line): helloworld_vstudio.exe foo1 foo2
 */

#include <stdio.h>

void main(int  argc,        /* Number of strings in array argv */
          char *argv[],     /* Array of command-line argument strings */
          char **envp ) {   /* Array of environment variable strings */
  int count;

  /* Display each command-line argument. */
  printf("\nCommand-line arguments:\n");
  for ( count = 0; count < argc; count++ )
    printf( "  argv[%d]   %s\n", count, argv[count] );

  /* Display each environment variable. */
  printf("\nEnvironment variables:\n");
  while ( *envp != NULL )
    printf("  %s\n", *(envp++));

  return;
}
