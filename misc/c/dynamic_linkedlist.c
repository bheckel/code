/*****************************************************************************
 *     Name: dynamic_linkedlist.c
 *
 *  Summary: Dynamically grow a linked list.  Allocates nodes dynamically.
 *
 *  Adapted: Thu, 11 Jan 2001 09:31:41 (Bob Heckel -- Steve Summit tutorial
 *                                      section 15.5)
 *****************************************************************************
*/
/* TODO where is getline() in the Std C Library? */
#include<stdio.h>
#include<stdlib.h>     /* for malloc, exit   */
#include<string.h>     /* for strlen, strcpy, fgets */
#define MAXLINE 80

struct listnode {
  char*  item;
  struct listnode* next;
};

struct listnode *prepend(char *newword, struct listnode *oldhead);


int main(void) {
  /* For printf-ing. */
  struct listnode* lp;
  ///struct listnode node2 = {"world", NULL};
  ///struct listnode node1 = {"hello", &node2};
  ///struct listnode* head = &node1;
  /* Initialize the list head pointer with a null pointer (i.e. an empty
   * list).
   */
  struct listnode* head = NULL;
  char line[MAXLINE];

  /* Build a list. */
  ///head = prepend("world", head);
  ///head = prepend("cruel", head);
  ///head = prepend("hello", head);
  puts("Enter word(s) to push on top of stack:");
  while ( fgets(line, MAXLINE, stdin) ) {
    puts("Enter word(s) to push on top of stack (Ctrl-d to exit):");
    head = prepend(line, head);
  }

  for ( lp=head; lp!=NULL; lp=lp->next )
    printf("%s\n", lp->item);

  return 0;
}


/* Prepend an item to a list (i.e. push onto a stack).  Complexity is that the
 * head pointer is modified on every push.
 */
struct listnode* prepend(char* newword, struct listnode* oldhead) {
  ///struct listnode* newnode = malloc(sizeof(struct listnode));
  ///if(newnode == NULL) {
  ///    fprintf(stderr, "out of memory\n");
  ///    exit(1);
  ///}
  /* Allocate new space for the new string.  Now we're not dependent on the
   * newword pointer remaining valid while the list is in use. 
   */
  ///newnode->item = malloc(strlen(newword) + 1);
  ///if(newnode->item == NULL) {
  ///    fprintf(stderr, "out of memory\n");
  ///    exit(1);
  ///}

  /* BETTER --- Combine the malloc calls, verifying success at same time,
   * short circuiting if necessary.
   */
  struct listnode* newnode;

  /* malloc() returns a pointer if successful, NULL ptr if it fails. */
  if ( (newnode       = malloc(sizeof(struct listnode))) == NULL || 
       (newnode->item = malloc(strlen(newword)+1))       == NULL ) {
    fprintf(stderr, "out of memory\n");
    exit(1);
  }

  strcpy(newnode->item, newword);

  newnode->next = oldhead;

  /* Returns a pointer to the _new_ head of the list. */
  return newnode;
}

