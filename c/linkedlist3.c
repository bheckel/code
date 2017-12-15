/*========================================================*
 * Program:  list1513.c                                   *
 * Book:     Teach Yourself C in 21 Days                  *
 * Purpose:  Implementing a linked list                   *
 *========================================================*/
#include <stdio.h>
#include <stdlib.h>

#ifndef NULL
#define NULL 0
#endif

/* List data structure */
struct list {
  int ch;     /* using an int to hold a char */
  /* When next is equal to NULL, the end of the linked list has been
   * reached.  Otherwise next is the next linked list in the chain.
   */
  struct list* next;  
      
};

/* Typedefs for the structure and pointer (for convenience). */
typedef struct list LIST;
typedef LIST* LISTPTR;

/* Function prototypes. */
LISTPTR add_to_list(int, LISTPTR);
void show_list(LISTPTR);
void free_memory_list(LISTPTR);


int main(void) {
  /* You should never let a pointer go uninitialized. */
  LISTPTR first = NULL;  /* head pointer is declared */
  int i = 0;
  int ch;
  char trash[80];        /* used to clear stdin buffer to avoid problems */

  while ( i++ < 4 ) {    /* build a list based on 4 items given by user */
     ch = 0;
     printf("\nEnter character number %d (a-zA-Z): ", i);

     do {
       ch = getc(stdin); /* get next char in buffer  */
       gets(trash);      /* remove any waiting characters from stdin buffer */
     } while( (ch < 'a' || ch > 'z') && (ch < 'A' || ch > 'Z'));
     /* Should have used isalpha() */

     /* The user's character and a ptr to beginning of the list are passed. */
     first = add_to_list(ch, first);
  }

  show_list(first);           /* dumps the entire list */
  free_memory_list(first);    /* release all memory */

  return(0);
}
 

/*========================================================*
 * Function: add_to_list()
 * Purpose : Inserts new link in the list
 * Entry   : int ch = character to store
 *           LISTPTR first = address of original head pointer
 * Returns : Address of head pointer (first)
 *========================================================*/
LISTPTR add_to_list(int ch, LISTPTR first) {
  LISTPTR new_rec  = NULL;       /* holds address of new rec */
  LISTPTR tmp_rec  = NULL;       /* hold tmp pointer */
  LISTPTR prev_rec = NULL;

  /* Allocate memory for the new link being added. */
  /* malloc() doesn't initialize allocated memory -- calloc() does. */
  new_rec = (LISTPTR)malloc(sizeof(LIST));

  if ( !new_rec ) {
    printf("\nUnable to allocate memory!\n");
    exit(__LINE__);
  }

  /* Set new link's data.  Sets the data in the structure to the data passed
   * into this function. 
   */
  new_rec->ch = ch;
  /* Sets the next in the new record to NULL so that it doesn't point to
   * some random stupid location in France.
   */
  new_rec->next = NULL;

  /* Starts the "add a link" logic by checking to see whether there are any
   * links in the list.
   */
  if ( first == NULL ) {   /* adding first link to list if first is == 0x0 */
    first = new_rec;
  } else {                 /* not first record */
     /* See if it belongs (alphabetically) before the first link: */
     if ( new_rec->ch < first->ch ) {
       new_rec->next = first;
       first = new_rec;
     } else {  /* it is being added to the middle or end */
        /* The pointer tmp_rec is set to the address of the second link in the
         * list, and prev_rec is set to the first link in the list.
         */
        tmp_rec = first->next;
        prev_rec = first;

         /* Check to see where link is added. */
         if ( tmp_rec == NULL ) {  /* we are adding second record to end */
           /* If tmp_rec is NULL, you know that this is the second link being
            * added to the list. Because you know the new link doesn't come
            * before the first link, it can only go at the end. To accomplish
            * this, you simply set prev_rec->next to the new link
            */
           prev_rec->next = new_rec;
         } else {
            /* Check to see if adding in middle. */
            /* If the tmp_rec pointer isn't NULL, you know that you already
             * have more than two links in your list. 
             */
            while ( ( tmp_rec->next != NULL) ) {
               if ( new_rec->ch < tmp_rec->ch ) {
                  new_rec->next = tmp_rec;
                  /* These 5 lines could be removed;  as long as the
                   * program is running correctly, they will never be called.
                   * After the new link's next pointer is set to the current
                   * pointer, it should be equal to the previous link's next
                   * pointer, which also points to the current record. If they
                   * aren't equal, something went wrong! 
                   */
                  if ( new_rec->next != prev_rec->next ) {
                     printf("ERROR");
                     getc(stdin);
                     exit(__LINE__);
                  }
                  prev_rec->next = new_rec;
                  break;   /* link is added; exit while */
               } else {
                 tmp_rec = tmp_rec->next;
                 prev_rec = prev_rec->next;
               }
            }

            /* Check to see if adding to the end. */
            /* If the last link in the list was reached, tmp_rec->next
             * will equal NULL.
             */
            if ( tmp_rec->next == NULL ) {
               if ( new_rec->ch < tmp_rec->ch ) {
                 new_rec->next = tmp_rec;
                 prev_rec->next = new_rec;
               } else  { /* at the end */
                 tmp_rec->next = new_rec;
                 new_rec->next = NULL;  /* redundant */
               }
            }
         }
     }
  }

   return(first);
 }


/*========================================================*
 * Function: show_list
 * Purpose : Displays the information current in the list
 *========================================================*/
void show_list(LISTPTR first) {
  LISTPTR cur_ptr;
  int counter = 1;

  printf("\n\nRec addr  Position      Next Rec addr\n");
  printf("========  ========      ========= ====\n");

  cur_ptr = first;
  while ( cur_ptr != NULL ) {
    printf("  %X   ", cur_ptr );
    printf("     %2i       %c", counter++, cur_ptr->ch);
    printf("      %X   \n",cur_ptr->next);
    cur_ptr = cur_ptr->next;
  }
}


/*========================================================*
 * Function: free_memory_list
 * Purpose : Frees up all the memory collected for list
 *========================================================*/
void free_memory_list(LISTPTR first) {
  LISTPTR cur_ptr, next;
  cur_ptr = first;                /* start at beginning */

  while ( cur_ptr != NULL ) {     /* go while not end of list */
    next = cur_ptr->next; /* get address of next record */
    free(cur_ptr);                /* free current record */
    cur_ptr = next;  /* adjust current record*/
  }
}
