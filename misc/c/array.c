/*****************************************************************************
 *     Name: array.c
 *
 *  Summary: Demo of C-style arrays.
 *
 *  Created: Sat 15 Feb 2003 11:23:53 (Bob Heckel)
 * Modified: Fri 02 Apr 2004 11:19:51 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>  // for memset

// Arrays are not assignable b/c the array's name is a constant pointer and
// therefore cannot be the target of assignment.

int main(void) {
  /* Declare and initialize an integer array. */
  int i_array[10] = { 0,1,2,3,4,5,6,7,8,9 };

  char string1[10] = { 'A', 'l', 'a', 'b', 'a', 'm', 'a', '\0' };

  // Defensive programming (initialization at declaration time):
  char stringy[10] = { '\0' };

  // It's more convenient, however, to use a literal string, which is a
  // sequence of characters enclosed in double quotes:
  char string2[10] = "Alabama";

  // When you use a literal string in your program, the compiler automatically
  // adds the terminating null character at the end of the string. If you
  // don't specify the number of subscripts when you declare an array, the
  // compiler calculates the size of the array for you. Thus, the following
  // line creates and initializes an eight-element array:
  char string3[] = "Alabama";

  // Modifying any of the characters in this array is a runtime error,
  // although not all compilers enforce this correctly.  
  //
  // This is technically an error because a character array literal is created
  // by the compiler as a constant character array, and the result of the
  // quoted character array is its starting address in memory
  //
  // If you want to be able to modify the string, put it in an array like
  // string3[] above.
  char *string4 = "Alabama";

  char *string5 = "NewJersey";

  /* In C (but not C++), you must always define all the variables at the
   * beginning of a block, after the opening brace, not at point of use (in
   * the for loop below) 
   */
  int i;  


  // TODO segfault, must use strcp()
  ///char string6[40];
  ///while (*string6++ = *string5++);
  ///printf("Copied string5 into 6: %s\n", string6[0]);

  printf("before: %s\n", string3);
  // Initialize (set) array to zero.
  memset(string3, 0, 7 * sizeof(char));
  printf("zeroed: %s\n", string3);

  // Iterate over an array.
  for ( i=0; i<(sizeof i_array/sizeof *i_array); i++ ) {
    i_array[i]++;
    printf("iteration %d\n", i_array[i]);
  }

  return 0;
}
