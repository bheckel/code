/* Demonstrates the fundamentals of using  a linked list (built at
 * compile-time) 
*/

/*  Adapted: Fri 20 Jul 2001 23:55:12 (Bob Heckel -- InformIT) */
/* Modified: Mon 25 Dec 2006 14:23:58 (Bob Heckel) */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* The list data structure. */
struct Listnode {
  char name[20];
  struct Listnode* next;
};

/* Define typedefs for the structure and a pointer to it (for convenience). */
typedef struct Listnode PERSON;
typedef PERSON* LINK;

int main() {
  /* Head, new, and current element pointers. */
  LINK head    = NULL;
  LINK newl    = NULL;
  LINK current = NULL;

  ///////////
  /* Add the first list element. We do not */
  /* assume the list is empty, although in */
  /* this demo program it always will be. */
  newl = (LINK) malloc(sizeof(PERSON));
  newl->next = head;
  head = newl;
  strcpy(newl->name, "First");

  ///////////
  /* Add an element to the end of the list.
   * We assume the list contains at least one element.  Then we walk the list
	 * to the end before adding.
	 */
  current = head;
  while ( current->next != NULL ) {
    current = current->next;
  }

  newl = (LINK) malloc(sizeof(PERSON));
  current->next = newl;
  newl->next = NULL;
  strcpy(newl->name, "Fourth");

  ///////////
  /* Add a new element at the third position in the list. */
  newl = (LINK) malloc(sizeof(PERSON));
  newl->next = head->next;
  head->next = newl;
  strcpy(newl->name, "Third");

  ///////////
  /* Add a new element at the second position in the list. */
  newl = (LINK) malloc(sizeof(PERSON));
  newl->next = head->next;
  head->next = newl;
  strcpy(newl->name, "Second");

  ///////////
  /* Print all Listnode items in order. */
  current = head;
  while ( current != NULL ) {
    printf("%s\n", current->name);
    current = current->next;
  }

  return(0);
}
