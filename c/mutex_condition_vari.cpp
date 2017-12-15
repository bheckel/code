//////////////////////////////////////////////////////////////////////////////
//     Name: mutex_condition_vari.cpp
//
//  Summary: Play tug of war between two threads on a rope struct by 
//           continuously tugging on the rope.  The strength of each pull
//           by the threads is determined by a randomly generated number.  A
//           judger thread will read from the rope to determine who is winning
//           and eventually who has won the contest.
//
//           A program has a data race if it is possible for a thread to
//           modify an addressable location at the same time that another
//           thread is accessing the same location.
//
//           See also mutex.cpp
//
//           TODO collision on the word 'pulling' in the screen output
//           TODO if runs long enough, core dumps
//
//  Adapted: Sun 27 Jan 2002 11:01:02 (Bob Heckel -- Martin Casado tutorial
//                                     http://www.cse.nau.edu/~mc8/index.html)
//////////////////////////////////////////////////////////////////////////////
#include <pthread.h>
#include <iostream.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

// This struct carries its own mutex and condition variable to protect the
// position of the rope. This is an example of using a mutex to "lock" off a
// data-structure.
typedef struct{ 
  pthread_mutex_t rope_mutex;
  pthread_cond_t checkMe;
  int rope_position; 
} Rope;

// Thread method prototypes.
void *tugRope(void* direction);
void *judgeContest(void* null);
void pull(int x);

Rope *theRope;
 

int main(void){
  pthread_t *contestant1, *contestant2, *judger;

  srand((unsigned int)time(NULL));  // generate random number

  contestant1 = new pthread_t();
  contestant2 = new pthread_t();
  judger      = new pthread_t();
  theRope     = new Rope();
  theRope->rope_position = 0;
  pthread_mutex_init(&theRope->rope_mutex, NULL);
  pthread_cond_init(&theRope->checkMe, NULL);

  cout << "The contest has started!" << endl;
  // Start all three threads, passing a +1 to contestant 1 for a positive
  // direction of pull and a -1 to contestant 2 for a negative direction of
  // pull.
  pthread_create(contestant1, NULL, tugRope, (void*)1);
  // Tug the rope right!
  pthread_create(contestant2, NULL, tugRope, (void*)-1);
  // Tug the rope left!
  pthread_create(judger, NULL, &judgeContest, NULL);

  // Wait for judger thread to end.
  pthread_join(*judger, NULL);

  return(0);
}


void *tugRope(void* direction) {
  // Keep tugging until the program exits.
  int strength = 0;
  int dir      = (int)direction;

  while ( 1 ) {
    sleep(2);
    strength = rand() % 5;
    cout << "Thread " << pthread_self() << " is pulling: " << (dir * strength)
                                                                     << endl;
    pull((dir * strength));
  }

  return NULL;
}


void *judgeContest(void *null) {
  while ( 1 ) {
    pthread_mutex_lock(&theRope->rope_mutex);

    pthread_cond_wait(&theRope->checkMe, &theRope->rope_mutex);

    // Check the rope, and see who has won, if anyone.
    if ( theRope->rope_position >= 5 ){
      cout << "Judger: Contestant number 1 has won!" << endl;
      break;

    } else if ( theRope->rope_position <= -5 ) {
      cout << "Judger: Contestant number 2 has won!" << endl;
      break;
    }

    pthread_mutex_unlock(&theRope->rope_mutex);
  }

  return NULL;
}


// Method to pull the rope a certain way.
void pull(int x) {
  // We don't want both threads to modify rope at once.
  pthread_mutex_lock(&(theRope->rope_mutex));
  theRope->rope_position += x;
  cout << "The current position is " << theRope->rope_position << endl;
  // Here we tell the judger to go ahead and check the rope, because it has
  // been modified.
  pthread_cond_signal(&theRope->checkMe);
  pthread_mutex_unlock(&(theRope->rope_mutex));
}
