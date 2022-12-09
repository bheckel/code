/*****************************************************************************
 *     Name: pipe.c
 *
 *  Summary:  Demo of piping.  Sends mail via mutt.
 *
 *  Adapted: Mon 12 Nov 2001 21:42:38 (Bob Heckel -- Using C on the Unix
 *                                     System p.108)
 * Modified: Mon 19 Nov 2001 11:08:21 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
  FILE *fp;
  int pid, pipefiledescriptor[2];

  /* Create the low level pipe.  This has to be done BEFORE the fork.  
   * int pipe(int fd[2]) -- creates a pipe and returns two file descriptors,
   * fd[0], fd[1]. fd[0] is opened for reading, fd[1] for writing.  Returns 0
   * on success, -1 on failure (and sets errno accordingly).
   */
  if ( pipe(pipefiledescriptor) < 0 ) {
    perror("pipe");
    exit(1);
  }

/* The standard programming model is that after the pipe has been set up, two
 * (or more) cooperative processes will be created by a fork and data will be
 * passed using read() and write() (this program appears to be a hybrid, using
 * fdopen() instead).
 */

  if ( (pid = fork()) < 0 ) {
    perror("fork");
    exit(1);
  }

  /* 
   * The child process executes the code inside the if. 
   */

  if ( pid == 0 ) {
    /* Make the read side of the pipe (i.e. pipefiledescriptor[0]) our
     * standard input. 
     */
    close(0);
    dup(pipefiledescriptor[0]);
    close(pipefiledescriptor[0]);

    /* Close the write side of the pipe; we'll let our output go to the
     * screen.
     */
    close(pipefiledescriptor[1]);
    /* Execute the command "mutt username". */
    execl("/bin/mutt", "mutt", "bheckel", 0);
    perror("exec");
    exit(1);
  }

  /*
   * The parent executes this code.
   */

  /* Close the read side of the pipe; we don't need it (and the child is not
   * writing on the pipe anyway).
   */
  close(pipefiledescriptor[0]);

  /* Convert the write side of the pipe to stdio. */
  fp = fdopen(pipefiledescriptor[1], "w");

  /* Send a message, close the pipe. */
  fprintf(fp, "Hello from your pipe.c program.\n");
  fclose(fp);

  /* Wait for the process to terminate. */     
  while ( wait((int *) 0) != pid )
    ;

  exit(0);
}
