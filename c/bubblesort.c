// Demo of bubblesort from 'C++ From the Ground Up'
// Adapted: Thu, 12 Aug 1999 09:51:47 (Bob Heckel)

#include <iostream.h>
#include <stdlib.h>

main() {
  int sizeofarray = 10;
  int nums[10];
  int a, b, t;

  // Populate random array.
  for(t=0; t<sizeofarray; t++) nums[t] = rand();

  for(a=1; a<sizeofarray; a++) {
    for(b=sizeofarray-1; b>=a; b--) {
      if(nums[b-1] > nums[b]) {
        t = nums[b-1];
        nums[b-1] = nums[b];
        nums[b] = t;
      }
    }
  }
  cout << "sorted is";
  for(t=0; t<sizeofarray; t++) cout << nums[t] << "\n";
}

