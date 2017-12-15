/*****************************************************************************
 *     Name: array_passing.c
 *
 *  Summary: Demo of C treating array parameters as pointers.
 *
 *  Adapted: Mon 03 Sep 2001 16:07:55 (Bob Heckel--Deep C Programming p.249)
 *****************************************************************************
*/
#include <stdio.h>


/* All arrays that are function arguments are rewritten by the compiler (at
 * compiletime) into pointers.
 */
int passed_as_arr(char in[7]) {
  puts("\n-------\nPARAM AS ARRAY");
  printf("in: %p\n", in);
  printf("&in addr: %p\n", &in);
  printf("&(in[0]) addr: %p\n", &(in[0]));
  printf("&(in[1]) addr: %p\n", &(in[1]));
  printf("++in addr: %p\n", ++in);
  
  printf("\nsizeof: %d\n\n", sizeof(in));

  return 0;
}


int passed_as_ptr(char *in) {
  puts("-------PARAM AS PTR");
  printf("in: %p\n", in);
  printf("&in addr: %p\n", &in);
  printf("&(in[0]) addr: %p\n", &(in[0]));
  printf("&(in[1]) addr: %p\n", &(in[1]));
  printf("++in addr: %p\n", ++in);
  
  printf("\nsizeof: %d\n\n", sizeof(in));

  return 0;
}


int main(void) {
  char lca[7] = "soylent"; 

  printf("\n-------\nlocal char arr addr: %p", lca);
  printf("\tgca value: %s", lca);
  printf("\tsizeof gca: %d\n", sizeof(lca));
  passed_as_arr(lca);
  passed_as_ptr(lca);

  return 0;
}
