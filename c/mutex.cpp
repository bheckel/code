//////////////////////////////////////////////////////////////////////////////
//     Name: mutex.cpp
//
//  Summary: Demo a POSIX mutex (mutual exclusion) that implements a simple, 
//           single, global lock.  The goal is to avoid race conditions.
//
//           A program has a data race if it is possible for a thread to
//           modify an addressable location at the same time that another
//           thread is accessing the same location.
//
//           See also mutex_condition_vari.cpp
//
//  Adapted: Sun 27 Jan 2002 11:01:02 (Bob Heckel -- Martin Casado tutorial
//                                     http://www.cse.nau.edu/~mc8/index.html)
//////////////////////////////////////////////////////////////////////////////
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <iostream.h>
#include <fstream.h>
#include <string.h>

// In this example we are going to use a global mutex.
pthread_mutex_t myMutex = PTHREAD_MUTEX_INITIALIZER;

// File Stream for the threads to write to.
ofstream fileOut;

// Char arrays of words to write to file.
char *intro     = "Once a king\n\0";
char *body      = "Always a king\n\0";
char *nearend   = "But....\n\0";
char *end       = "Once a night's enough\n\0";
char *separator = "*************************\n\0";

// Prototypes.
void *myThreadFunc(void *arg);
void writeStoryToFile(void);


int main(void){
  pthread_t thread1, thread2;   // declare two threads

  // Open a file to write to in append mode.
  fileOut.open("junk.txt", ios::out | ios::app);

  // Start the first thread running.
  pthread_create(&thread1, NULL, myThreadFunc, (void *)NULL);
  // Start the second thread running.
  pthread_create(&thread2, NULL, myThreadFunc, (void *)NULL);

  // Wait for threads to stop before we exit main().
  pthread_join(thread1, NULL);
  pthread_join(thread2, NULL);

  fileOut.close();

  cout << "junk.txt created.  Exiting main().\n";

  return 0;
}


// Thread function simply calls our writeStoryToFile method. What we *don't*
// want to be doing is writing to the same file at the same time.
void *myThreadFunc(void *arg){
  for ( int i=0;i<5;i++ ){
    writeStoryToFile();
  }

  return((void*)NULL);
}


// Print to file (without collisions).
void writeStoryToFile(void){
  // Lock the global mutex so only one thread is writing to the file at a
  // time.  The other thread spins until it's unlocked.
  pthread_mutex_lock(&myMutex);
  // Begin "critical section".  Flip the bathroom's OCCUPIED sign.
  fileOut.write(intro, strlen(intro));
  fileOut.write(body, strlen(body));
  fileOut.write(nearend, strlen(nearend));
  fileOut.write(end, strlen(end));
  fileOut.write(separator, strlen(separator));
  // End "critical section".  Flip the bathroom's VACANT sign.
  // Now Unlock the global mutex enabling thread2 to run this section of code.
  pthread_mutex_unlock(&myMutex);
}
