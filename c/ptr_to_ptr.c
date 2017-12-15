/* Demo of pointer to pointers, i.e. multiple indirection (from InformIT). */
/* Modified: Fri 22 Mar 2002 15:06:40 (Bob Heckel) */
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(void) {
  int x; 
  /* A pointer is a numeric value.  It holds the address of some variable.
   * ptr_to_ptr is a variable of type (int **) with a value of 0x1234
   * *ptr_to_ptr is a variable of type (int*) with a value of 0x5678
   * **ptr_to_ptr is a variable of type (int) with a value of 43
   */
  int *ptr;
  int **ptr_to_ptr;

  printf("\nx physical address (&x):\t\t\t\t%p\n", &x);
  printf("pointer ptr physical address (&ptr):\t\t\t%p\n", &ptr);
  printf("pointer ptr_to_ptr physical address (&ptr_to_ptr):\t%p"
         "(irrelevant) \n\n", &ptr_to_ptr);

  x   = 42;
  ptr = &x;
  puts("SIMPLE: After statement  ptr = &x;");
  printf("pointer (ptr) holds: %x at ptr's phys addr (&ptr): %x\n", ptr, &ptr);
  printf("and value (*ptr) is dereffed to: %d\n\n", *ptr);
  ///printf("*ptr points to value: %d (found at ptr %p) at ptr's phys "
         ///"address &ptr: %x\n", *ptr, ptr, &ptr);
  ptr_to_ptr = &ptr;      
  /* Compiler warnings ok here. */
  /* Easier to read in hex (%x) than %d. */
  ///printf("ptr_to_ptr holds value: %x (physical addr of ptr i.e. &ptr)\n",
                                                            ///ptr_to_ptr);

  /* Do not do this:  *ptr_to_ptr = 66;  it will make the ptr point to memory
   * location 66 which is probably not your intention.
   */

  /* After this stmt, x is 43 and *ptr is 43 and **ptr_to_ptr is 43 */
  **ptr_to_ptr = 43;

  ///puts("COMPLEX: After statement  **ptr_to_ptr = 43;");
  puts("COMPLEX: After statement  ptr_to_ptr = &ptr;");
  printf("pointer (ptr_to_ptr) holds: %x at ptr_to_ptr's phys "
         "addr (&ptr_to_ptr): %x\n", ptr_to_ptr, &ptr_to_ptr);
  printf("and value (**ptr_to_ptr) is dereffed to: %d\n\n", **ptr_to_ptr);
  printf("*ptr_to_ptr: %x has little meaning\n\n", *ptr_to_ptr);


  puts("Finally:");
  printf("x value: %d \t *ptr value: %d \t **ptr_to_ptr value: %d\n", 
                                        x,  *ptr, **ptr_to_ptr);

  exit(EXIT_SUCCESS);
}
