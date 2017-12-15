/*****************************************************************************
 *     Name: menu.c
 *
 *  Summary: 
 *
 *  Adapted: Sat 30 Mar 2002 18:51:40 (Bob Heckel -- Code Capsules Chuck
 *                                     Allison)
 *****************************************************************************
*/
#include <stdio.h> 

void retrieve(void) { puts("retrieve"); }
 

void insert(void) { puts("insert"); }


void update(void) { puts("update"); }


int show_menu(void) { 
  int num;

  puts("enter 1 2 or 3 (4 to quit)"); 
  scanf("%d", &num);

  return num; 
}


int main(void) { 
  int choice;
  void (*farray[])(void) = {retrieve,insert,update};

  for ( ;; ) {
    choice = show_menu();
    if ( choice >= 1 && choice <= 3 )
      /* Array of pointers to functions. */
      farray[choice-1]();   // process request
    else if (choice == 4)
      break;
  }

  return 0;
}
