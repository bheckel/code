#include "Defs.h"
#include "ExternVars.h"


PrintLine()  /* for debugging purposes only */

{  int I;

   for (I = 0; I < LineLength; I++) printf("%c",Line[I]);
   printf("\n");
}
