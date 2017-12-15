/* Adapted: Mon 15 Oct 2001 12:42:12 (Bob Heckel --
 *   http://heather.cs.ucdavis.edu/~matloff/UnixAndC/CLanguage/PointersI.html)
 *
 * Modified: Sun 29 Feb 2004 18:00:13 (Bob Heckel)
 */

/* Structs and pointers. 
 *
 * Warehouse setting, the user inputs information from a pile of papers which
 * document purchase orders and cancellation orders 
 *
 * Each paper has a time stamp on it, showing the time the paper was written
 * (in the case of a cancellation, the time stamp is the time at which the
 * original order was place).
 * 
 * The information must be maintained in time stamp sequence, in a linked
 * list, which in this case would be preferable to an array since we don't
 * have to "move everything over" when a cancellation occurs.
 * 
 * Initial input can be from a previously-created file if desired; 
 * file is in binary format, to save disk space, depending on the size of the
 * numbers involved. If a number is at least five digits long in decimal form,
 * then binary form will save space here: An int variable on a SPARCstation
 * takes up 32 bits, thus four bytes; in character form, i.e. when stored by a
 * statement of the form 
 *
 *   fprintf(file pointer,"%d",variable name);
 *
 * we would be using five bytes. On the other hand, if we knew that all our
 * integer values would be in the range 0-255, we could use the type unsigned
 * char instead of int, in which we would still save space by
 * using binary form.  
 *
 * TODO isn't there a better way using C++ to avoid the "struct per record"
 * algorithm?
 */

/* The file /usr/include/fcntl.h contains some #define's that will be
 * needed for our I/O, e.g. a definition of the value O_RDONLY
 */
#include <fcntl.h>
#include <stdlib.h>

#define MAXFILESIZE 1000 

/***************** Global Declarations ************************/
/* command -- see main() for acceptable letters
 * inFileArray[]: --  buffer for input file, if any
 */
char command;
int cancelTmStmp;

/* Create a ListNode type.  There is one of these structs for each 
 * transaction. 
 */
struct ListNode  {
  int itemNum,
      timeStamp,   /* time at which the paper was written */
      customerID;
  struct ListNode* link;  /* type: pointer-to-ListNode, a link to next node */
};

typedef struct ListNode* NodePtrType;

NodePtrType listHead,  /* head of linked list */
            currPtr;   /* ptr to node containing the paper being processed */

/* Number of bytes in the information part of the node, i.e. excluding the
 * link.  Usually 4 bytes * 3 ints == 12 
 */
int nodeInfoSize = sizeof(struct ListNode) - sizeof(NodePtrType);
/***************** Global Declarations ************************/


/********************* Functions *************************************/
  /* tmpPtr initially points to the head of the list.  At the end of each
   * iteration of the loop tmpPtr is advanced to the next struct in the list.
   */
Display() {  
  NodePtrType tmpPtr = listHead;

  while ( tmpPtr != 0 )  {
    printf("%x %d %d %d %x\n", tmpPtr,
                               tmpPtr->itemNum,
                               tmpPtr->timeStamp,
                               tmpPtr->customerID,
                               tmpPtr->link)
                               ;
    tmpPtr = tmpPtr->link;
  }
}


/* Read all the records stored in the file, create structs for each one (with
 * the struct type defined in struct ListNode), and link the structs together,
 * with the head of the chain being pointed to by listHead. On the other hand,
 * if we start with nothing in the list, listHead will be initialized to 0. 
 */
BuildListFromFile()  {  
  char inFileArray[MAXFILESIZE];
  int FD,          /* file descriptor */
      inFileSize,  /* number of bytes in the input file */
      nNodes,      /* number of nodes stored in the file */
      startByte,   /* index of the starting byte of the current
                      stored node in inFileArray */
       i, j;
   char inFileName[20], *bytePtr;
   NodePtrType tmpPtr, ListTail;

   printf("enter file name\n");
   scanf("%s", inFileName);

   FD = open(inFileName, O_RDONLY);
   inFileSize = read(FD, inFileArray, MAXFILESIZE);
   nNodes = inFileSize / nodeInfoSize;
   printf("!!!%d\n", nNodes);
   /* Now build the linked list, by copying from inFileArray, one node at a
    * time. 
    */
   for ( i=1; i<=nNodes; i++ )  {
      /* Make room for one node in memory. */
      tmpPtr = (NodePtrType) calloc(1, sizeof(struct ListNode));  

      /* Copy the i-th stored-node information to this new node. */
      startByte = (i-1) * nodeInfoSize;

      for ( j=0; j<nodeInfoSize; j++ )  {
        /* TODO huh? */
        bytePtr = ((char *) tmpPtr) + j;
        *bytePtr = inFileArray[startByte+j];
      }

      tmpPtr->link = 0; 

      /* Now append this new node to the linked list. */
      if ( i == 1 ) 
        listHead = ListTail = tmpPtr;
      else  {
        /* Attach to the list. */
        ListTail->link = tmpPtr;
        /* At least for now, this will be the new tail. */
        ListTail = tmpPtr;
      }
   }
}


GetCommand() {  
  printf("enter command\n");  
  scanf("%c", &command);
  /* Might be a leftover end-of-line character from the previous action; if
   * so, then read the next character in the input stream.
   */
  if ( command == '\n') 
    scanf("%c", &command );  
}


/* Prompt user for the information, and put it in the struct pointed to by
 * currPtr.
 */
GetData() {  
  int itmNm, tmStmp, cstmrID;  

   printf("enter item number, time stamp and customer i.d. (all ints)\n");
   scanf("%d%d%d", &itmNm, &tmStmp, &cstmrID);

   /* Create new node. */
   currPtr = (NodePtrType) calloc(1, sizeof(struct ListNode));  

   /* Now fill it with the data. */
   currPtr->itemNum = itmNm;
   currPtr->timeStamp = tmStmp;
   currPtr->customerID = cstmrID;

   /* This node is not connected to anything yet. */
   currPtr->link = 0;  
}


/* Inserts the struct pointed to by currPtr into the list. */
Insert() {  
  NodePtrType leadingPtr, trailingPtr;

  /* List currently empty? */
  if ( listHead == 0 )  {
    listHead = currPtr;

    return;
   }
   
   /* Current time stamp earlier than list head? */
   if ( currPtr->timeStamp < listHead->timeStamp )  {
     currPtr->link = listHead;
     listHead = currPtr;

     return;
   }
   
   leadingPtr = listHead->link;  trailingPtr = listHead;

   while ( 1 )  {
      /* Reached end of list? */
      if ( leadingPtr == 0 )  {
        trailingPtr->link = currPtr;

        break;
      }

      /* Arrived at insertion point? */
      if ( currPtr->timeStamp < leadingPtr->timeStamp )  {
        trailingPtr->link = currPtr;
        currPtr->link = leadingPtr;

        return;
      }
      /* Otherwise move to next node. */
      else  {
        trailingPtr = leadingPtr;
        leadingPtr = leadingPtr->link;
      }
   }
}


/* Delete the node whose time stamp matches cancelTmStmp; to keep the program
 * simple so as to ease the teaching about pointers, it is assumed that there
 * will be one, and only one, node which matches the given time stamp 
 */
Cancel()  {  
  NodePtrType LeadingPtr,TrailingPtr;

   if ( listHead->timeStamp == cancelTmStmp )  {
     listHead = listHead->link;

     return;
   }

   LeadingPtr = listHead->link;  TrailingPtr = listHead;

   while ( LeadingPtr->timeStamp != cancelTmStmp )  {
     TrailingPtr = LeadingPtr;
     LeadingPtr = LeadingPtr->link;
   }

   TrailingPtr->link = LeadingPtr->link;
}


/* Traverse the chain, writing the data from each struct to the designated
 * file. This data will consist of the three fields in the ListNode struct,
 * but not the link value. The link values are irrelevant, since when the file
 * is read in again later on and the list recreated, the link values will
 * probably be different anyway. 
 */
SaveToFile() {  
  int FD;
  NodePtrType tmpPtr;
  char OutFileName[20];

  printf("enter output file name\n");
  scanf("%s", OutFileName);

  FD = open(OutFileName, O_WRONLY|O_CREAT, 0700);

  tmpPtr = listHead;

  while ( tmpPtr != 0 )  {
    write(FD,tmpPtr, nodeInfoSize);
    tmpPtr = tmpPtr->link;
  }
}
/********************* Functions *************************************/


int main(void) {  
  puts("q, input, delete, print, save to file, ?");
  printf("read in a file y/[n]?\n");
  scanf("%c", &command);
  if ( command == 'y') 
    BuildListFromFile();
  else 
    listHead = 0;

  /* TODO cleanup per -Wall */
  while ( 1 )  {
    GetCommand();
    /* Continue to take commands from the user, either adding new records to
     * the list, or deleting them when a cancellation request is made. 
     */
    switch ( command )  {
       case '?':  puts("q, input, delete, print, save to file, ?");
       case 'i':  GetData(); Insert(); break;
       case 'd':  printf("enter time stamp\n");
                  scanf("%d", &cancelTmStmp);  
                  Cancel(); break;
       /* TODO only displays on typed-in data, not saved to file data */
       case 'p':  Display(); break;
       case 's':  SaveToFile();
       case 'q':  exit(EXIT_SUCCESS);
    }
 }

   return 0;
}
