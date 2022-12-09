/*****************************************************************************
 *     Name: ezshell.c
 *
 *  Summary: Primitive shell for demonstration of exec'ing other programs.
 *           Good example of a simple parser as well.
 *
 *           TODO graceful warning (not a segfault) on a missing command (i.e.
 *           press enter at ezshell$ prompt.
 *
 *  Adapted: Sun 11 Nov 2001 18:35:37 (Bob Heckel -- Using C on the Unix
 *                                     System p. 103)
 *****************************************************************************
*/
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int parse(char*, char**);
int execute(char**);


int main(void) {
  char  buf[1024];
  char *args[64];

  for ( ;; ) {
      printf("ezshell$ ");       /* prompt for a command */

      if ( gets(buf) == NULL ) {   /* read the user's command */
        printf("\n");
        exit(0);
      }

      /* Split the buffer string into arguments. */
      parse(buf, args);

      /* Pretend to be a shell and execute the command. */
      execute(args);
  }
}


/* Split the command in buf into individual arguments.  */
int parse(buf, args)
char  *buf;
char **args;
{
  while ( *buf != '\0' ) {
    /* Strip whitespace.  Use nulls, so that the previous argument is
     * terminated automatically. */
    while ( (*buf == ' ') || (*buf == '\t') )
      *buf++ = '\0';

    *args++ = buf;   /* Save the argument. */

    /* Skip over the argument. */
    while ( (*buf != '\0') && (*buf != ' ') && (*buf != '\t') )
      buf++;
  }

  *args = '\0';

  return 0;
}


/* Spawn a child process and execute the program. */
int execute(args)
char **args;
{
  int pid, status;

  /* Get a child process. */
  if ( (pid = fork()) < 0 ) {
    perror("fork");
    exit(1);
  }

  /* The child executes the code inside the if. */
  if ( pid == 0 ) {      /* child's pid is always 0 */
    execvp(*args, args);
    perror(*args);
    exit(1);
  }

  /* The parent executes the wait. */
  while ( wait(&status) != pid )
    /* empty; wait until user's requested process finishes */ ;

  return 0;
}

