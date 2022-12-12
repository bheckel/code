// Demo of bit fiddling from Summit C tutorial (sx4ab.html)
// Adapted: Thu, 09 Nov 2000 15:33:19 (Bob Heckel)

#include <stdio.h>
#include <stdlib.h>

#define DIRTY   0x01
#define OPEN    0x02
#define VERBOSE 0x04
#define RED     0x08
#define SEASICK 0x10

int main(int argc, char **argv) {
  unsigned int flags;

  flags = atoi(argv[1]);

  /* If the dirty bit is 'on' */
  if ( flags & DIRTY ) { 
    /* E.g. 5 would be 0101
     *        DIRTY is 0001
     *                 ----
     *           so    0001 TRUE (non-zero) b/c dirty's bit is 'on'
     */
    puts("it's dirty");
  }

  if ( !(flags & OPEN) ) { 
    puts("it's closed");
  } else { 
    puts("dont know");
  }

 return 0;
}
