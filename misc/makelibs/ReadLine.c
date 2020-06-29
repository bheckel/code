#include "Defs.h"
#include "ExternVars.h"


int ReadLine()

/* reads one line of the file, returning also the number of characters
   read (including the end-of-line character); that number will be 0
   if the end of the file was reached */

{  char C;  int I;

   if (scanf("%c",&C) == -1) return 0;
   Line[0] = C;
   if (C == '\n') return 1; 
   for (I = 1; ; I++) {
      scanf("%c",&C);     
      Line[I] = C;  
      if (C == '\n') return I+1;
   }  
}
