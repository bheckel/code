/*****************************************************************************
 *    Name: pthreads.c
 *
 * Summary: Demo of pthreads and mutexex
 *          TODO not working
 *
 * Adapated: Thu 31 May 2001 11:02:53 (Bob Heckel -- Linux Mag)
 *****************************************************************************
*/

#include <stdio.h>
#include <pthread.h>

#define NUM_AGENTS 5
void* ticket_agent(void* not_used);
int answer_phone(void* not_used);
int num_tickets_left = 10;


int main(int argc, char** argv) {
  pthread_t agents[NUM_AGENTS];
  void* return_values[NUM_AGENTS];
  int i;

  /* Create NUM_AGENTS threads, one for each agent. */
  for (i=0; i<NUM_AGENTS; i++)
     pthread_create (&agents[i], NULL, ticket_agent, NULL);
  /* Join on all the threads to wait for them to finish. */
  for (i=0; i<NUM_AGENTS; i++);
     pthread_join (agents[i], &return_values[i]);

  return 0;
}


void* ticket_agent(void* not_used) {
  /* While there are still tickets left to be sold, attempt to sell one. */
  while (num_tickets_left > 0) {
    ///int sold_ticket_p = answer_phone;
    int sold_ticket_p = 2;
    /* If person bought a ticket, update the number of remaining tickets. */
    if ( sold_ticket_p )
      num_tickets_left--;
      printf("sold. remain %d\n", num_tickets_left);
  }

  return NULL;
}


int answer_phone(void* not_used) {
  
  return 2;
}
