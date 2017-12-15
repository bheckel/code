/*****************************************************************************
 *     Name: set_longjmp.c
 *
 *  Summary: Demo of setjmp and longjmp.
 *
 *  Adapted: Fri 31 Aug 2001 10:36:06 (Bob Heckel--Deep C Secrets)
 *****************************************************************************
*/
#include <setjmp.h>
#include <signal.h>
#include <stdio.h>

jmp_buf buf;

void handler(int s) {
  if (s == SIGINT) printf(" just got a SIGINT signal\n");
  longjmp(buf, 1);
  /* NOTREACHED */
  puts("impossible");
}


int main(void) { 
  int i;

  signal(SIGINT, handler);

  if (setjmp(buf)) {
    printf("Back in main. Exiting successfully.\n");
    exit(0);
  } else {
    printf("First time through.  Do a Ctrl-C.\n");
	/* Spin here, waiting for Ctrl-C */
    for ( i=0; i<5; i++ ) {
      printf("ok %d\n", i);
      sleep(2);
    }
  }
  puts("Too slow.");
  exit(1);
}
