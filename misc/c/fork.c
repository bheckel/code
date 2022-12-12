/*****************************************************************************
 *     Name: fork.c
 *
 *  Summary: Demo of fork.   
 *
 *  If the parent had files open before the fork(), those files remain
 *  open...and the child will also have those files open complete with file
 *  pointers in the same position as before the fork(). Any data structures
 *  and memory allocated by the parent before the fork() are copied in the
 *  child. If the parent had network socket connections open before the
 *  fork(), the child will have a copy of that socket connection.  The
 *  environment variables, user ID, and other associated baggage also is
 *  copied.
 *
 *  After the fork() however, the processes are independent. If the parent
 *  allocates new memory the child doesn't know (or care). Newly opened
 *  filehandles are only accessable in the process that opened them.
 *
 *  Adapted: Mon 18 Nov 2002 09:21:26 (Bob Heckel --
 *                   http://www.ecst.csuchico.edu/~beej/guide/ipc/fork.html)
 *****************************************************************************
*/
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>     // for pid_t
#include <sys/types.h>
#include <sys/wait.h>

int main(void) {
  pid_t pid;
  // Each process has its own copy of all variables. 
  int rv;

  switch ( pid=fork() ) {
    case -1:
        perror("fork");  /* something went wrong */
        exit(1);         /* parent exits */

    case 0:
        printf("- CHILD: This is the child process!\n");
        printf("- CHILD: My PID is %d\n", getpid());
        printf("- CHILD: My parent's PID is %d\n", getppid());
        printf("- CHILD: Enter my exit status (make it small): ");
        scanf("  %d", &rv);
        printf("- CHILD: I'm outta here!\n");
        exit(rv);

    default:
        printf("PARENT: This is the parent process!\n");
        printf("PARENT: My PID is %d\n", getpid());
        printf("PARENT: My child's PID is %d\n", pid);
        printf("PARENT: I'm now waiting for my child to exit()...\n");
        wait(&rv);
        // WEXITSTATUS is a macro that extracts the child's actual return
        // value from the value wait() returns. 
        printf("PARENT: My child's exit status is: %d\n", WEXITSTATUS(rv));
        printf("PARENT: I'm outta here!\n");
  }

  return 0;
}
