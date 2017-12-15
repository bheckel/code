#include "Defs.h"
#include "ExternVars.h"


extern int WordCount();


int 
UpdateCounts(void) {  NChars += LineLength;
  NWords += WordCount();
  NLines++;

  return 0;
}

