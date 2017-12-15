
#include <stdio.h>

// FYI a pointer is more than an address, it also carries the notion of what
// _type_ of data it points to.

int j, k, m;
int *ptr;

int main(void){    
  j = 1;    
  k = 2;
  m = 3;
  ptr = &k;    

  printf("\n ptr = &k in effect.\n");
  printf("j has the value %d and is stored at %p\n", j, (void *)&j);
  printf("k has the value %d and is stored at %p\n", k, (void *)&k);
  printf("ptr has the value %p and is stored at %p\n", ptr, (void *)&ptr);
  printf("The value of the integer pointed to by ptr converted hex to dec is %d\n", ptr);
  printf("The value of the integer pointed to by ptr deferenced is %d\n", *ptr);
  printf("\n");

  printf("m has the value %d and is stored at %p\n", m, (void *)&m);
  printf("\n ptr = &m in effect.\n");
  ptr = &m;    

  printf("m still has the value %d and is still stored at %p\n", m, (void *)&m);
  printf("ptr now has value %p but still stored at %p\n", ptr, (void *)&ptr);
  printf("The value of integer pointed to by ptr dereferenced now %d\n", *ptr);

  printf("\n");
  // Moves 4 bytes for int.
  printf("Pointer arithmetic: %p", ++ptr);

  return 0;
}
