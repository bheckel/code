#include "Defs.h"
#include "ExternVars.h"


/* counts the number of words in the current line, which will be taken
   to be the number of blanks in the line, plus 1 (except in the case 
   in which the line is empty, i.e. consists only of the end-of-line 
   character); this definition is not completely general, and will be
   refined in another version of this function later on */
int WordCount() {  
  int I,NBlanks = 0;  

  for (I = 0; I < LineLength; I++)  
    if (Line[I] == ' ') NBlanks++;

  if (LineLength > 1) return NBlanks+1;
  else return 0;
}

