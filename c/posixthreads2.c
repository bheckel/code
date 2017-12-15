/*****************************************************************************
 *     Name: posixthreads2.c
 *
 *  Summary: Demo of POSIX threads.  Intentional bug.
 *
 *  Adapted: Tue 22 Jan 2002 18:56:47 (Bob Heckel --
 *         ftp://www6.software.ibm.com/software/developer/library/posix1.pdf)
 *****************************************************************************
*/
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int myglobal;

void *thread_function(void *arg) {
  int i, j;

  for ( i=0; i<20; i++ ) {
    // The function assumes (wrongly) that myglobal won't be messed with while
    // it's running.
    j = myglobal;
    j++;
    printf(".");
    fflush(stdout);
    sleep(1);
    myglobal = j;
  }

  return NULL;
}


int main(void) {
  pthread_t mythread;
  int i;

  if ( pthread_create(&mythread, NULL, thread_function, NULL) ) {
    printf("error creating thread.");
    abort();
  }

  for ( i=0; i<20; i++) {
    myglobal++;
    printf("o");
    fflush(stdout);
    sleep(1);
  }

  if ( pthread_join(mythread, NULL) ) {
    printf("error joining thread.");
    abort();
  }

  printf("\nmyglobal (s/b 40) equals %d\n",myglobal);

  exit(0);
}
