/*****************************************************************************
 *     Name: assign_struct.c
 *
 *  Summary: Demo of assigning and passing structs.  Also uses pointers.
 *           Also see dynamic_linkedlist.c
 *
 *  Created: Thu, 11 Jan 2001 09:31:41 (Bob Heckel)
 *****************************************************************************
*/
#include<stdio.h>

struct moon {
  int   one;
  int   two;
  char* three;
};

/* Function prototypes. */
// Without ptrs.
///struct moon transformer();
struct moon* transformer();
int initstruct();


int main(void) {
  // Without ptrs.
  ///struct moon moonstruct2;
  struct moon* ptrstruct;

  // Without ptrs.
  ///moonstruct2 = transformer();
  ptrstruct = transformer();
  printf("main one %d two %d three %s\n", 
                        // Without ptrs.
                        ///moonstruct2.one, moonstruct2.two, moonstruct2.three);
                        ptrstruct->one, (*ptrstruct).two, ptrstruct->three);

  initstruct();
  
  return 0;
}


// Without ptrs.
///struct moon transformer() {
struct moon* transformer() {
  struct moon moonstruct;
  struct moon moonstructclone;
  struct moon* p_moonstruct;

  /* Static nodes based on knowing (at compile time) that we have 3 elements. */
  /* See initstruct() for faster method. */
  moonstruct.one   = 5;
  moonstruct.two   = 10;
  moonstruct.three = "threestring";

  printf("transformer one %d two %d three %s\n", 
                          moonstruct.one, moonstruct.two, moonstruct.three);

  /* Assign all of moonstruct to moonstructclone. */
  moonstructclone = moonstruct;
  /* Point to actual variables of type moon. */
  p_moonstruct = &moonstructclone;

  // Without ptrs.
  ///return moonstructclone;
  return p_moonstruct;
}


/* Quick initialization. */
int initstruct() {
  struct moon demo = {66, 99, "Hull"};
  printf("initstruct one %d two %d three %s\n", 
                                            demo.one, demo.two, demo.three);

  return 0;
}
