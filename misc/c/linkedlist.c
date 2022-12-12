/*****************************************************************************
 *     Name: linkedlist.c
 *
 *  Summary: Demo of linked lists using structs.
 *
 *           Use a linked list instead of an array when:
 *             1.  The number of data elements is unpredictable.
 *             2.  The list needs to be sorted.
 *
 *           See also linkedlist2.c and linkedlist3.c
 *
 *  Adapted: Thu, 11 Jan 2001 09:31:41 (Bob Heckel -- Steve Summit tutorial)
 * Modified: Sat 10 May 2003 22:13:16 (Bob Heckel)
 *****************************************************************************
*/
#include<stdio.h>

/* See the other linkedlistN.c samples for typedef conveniences. */
struct Listnode {
  char* item;
  struct Listnode* next;
};


int main(void) {
  struct Listnode* listp;

  /* Static nodes (known at compile time).  Must assign in this order. */
  /*                              end of list                          */
  struct Listnode node3 = {"ghi", NULL};
  struct Listnode node2 = {"def", &node3};
  struct Listnode node1 = {"abc", &node2};
  struct Listnode* head = &node1;

  for ( listp=head; listp!=NULL; listp=listp->next )
    printf("%s ", listp->item);
  
  return 0;
}
