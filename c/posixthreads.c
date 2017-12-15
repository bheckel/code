/*****************************************************************************
 *     Name: posixthreads.c
 *
 *  Summary: Demo of POSIX threads (simple).  May have to compile like so: 
 *           $ gcc posixthreads.c  -lpthread
 *
 *  Adapted: Tue 22 Jan 2002 18:56:47 (Bob Heckel --
 *         ftp://www6.software.ibm.com/software/developer/library/posix1.pdf)
 * Modified: Tue 29 Jan 2002 13:04:59 (Bob Heckel)
 *****************************************************************************
*/
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

void *thread_function(void *arg) {
  int i;

  for ( i=0; i<10; i++ ) {
    printf("In thread_function()\n");
    sleep(1);
  }

  return NULL;
}


int main(void) {
  int i;
  pthread_t mythread;   // prepare a thread object, i.e. thread id (tid)
  // Single-threaded at this point (one thread).
  
  // Prototype of pthread_create():
  // int pthread_create(pthread_t *threadp,       <---object trying to create
  //                    const pthread_attr_t *attr,   <---modi thread attribs
  //                    void *(*start_routine)(void *),         <---fn to run
  //                    void *arg);      <---other args, can be a struct, etc.
  //
  //                                use this fn in thread
  if ( pthread_create(&mythread, NULL, thread_function, NULL) ) {
    //                                  ^^^^^^^^^^^^^^^
    printf("error creating thread.");
    abort();
  }
  // Multi-threaded at this point (two threads).

  // Interleave w/ thread_function()'s output.  This wouldn't happen if this
  // block were placed after pthread_join() b/c main() blocks after joining.
  for ( i=0; i<10; i++ ) {
    printf("In main()\n");
    sleep(1);
  }

  // There is no parent/child relationship with threads.  This lack of
  // genealogy has one major implication: if you want to wait for a thread to
  // terminate, you need to specify which one you are waiting for by passing
  // the proper tid to pthread_join(). 
  //
  // Wait for thread to exit, otherwise we just run off the end of main().
  // Without this next line, we will prematurely terminate the thread we
  // created (when main exits).
  if ( pthread_join(mythread, NULL) ) {
    printf("error joining thread.");
    abort();
  } else {
    printf("Joined.\n");
  }

  printf("Exiting main() gracefully.\n");

  exit(0);
}
