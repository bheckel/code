
/* Program 2.1 from PTRTUT10.HTM   6/13/97 */

#include <stdio.h>

int my_array[] = {1,23,17,4,-5,100};
int *ptr;

int main(void) {
  int i;
  // Point pointer to the first element of the array.
  // The name of the array is the address of the first element in the array.
  // Array name can be considered a _constant_ pointer.
  // Same thing.
  ////ptr = &my_array[0];  
  ptr = my_array;
                                   
  printf("\n\n");
  for ( i = 0; i < 6; i++ ) {
    // Non-pointer approach.
    printf("my_array[%d] = %d   ", i, my_array[i]);   /*<-- A */
    ////printf("ptr + %d = %d   ", i, *(ptr + i));
    ////printf("ptr + %d = %d\n", i, *ptr++);
    // Not the results desired.
    printf("ptr + %d = %d\n", i, *(++ptr));
  }
  return 0;
}
