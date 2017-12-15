#include "Defs.h"
#include "ExternVars.h"


extern int WordCount();


UpdateCounts()

{  NChars += LineLength;
   NWords += WordCount();
   NLines++;
}
