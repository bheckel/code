
/* introductory C program 

   implements (a subset of) the Unix wc command  --  reports character, 
   word and line counts; in this version, the "file" is read from the 
   standard input, since we have not covered C file manipulation yet, 
   so that we read a real file can be read by using the Unix `<'
   redirection feature 
   
   Adapted: Mon Sep 13 14:05:59 2004 (Bob Heckel --
         http://heather.cs.ucdavis.edu/~matloff/UnixAndC/CLanguage/Make.html)

 */


#include "Defs.h"
/* Don't need #include ExternVars.h in this file (like we do in all the other
 * C source files) b/c this is where we're declaring global variables.
 */


extern int ReadLine(), WordCount();

char Line[MaxLine];  /* one line from the file */

int NChars = 0,  /* number of characters seen so far */
    NWords = 0,  /* number of words seen so far */
    NLines = 0,  /* number of lines seen so far */
    LineLength;  /* length of the current line */ 


main()  {  
  while ( 1 )  {
    LineLength = ReadLine();
    if (LineLength == 0) 
      break;
    UpdateCounts();
   }
  printf("%d %d %d\n",NChars,NWords,NLines);
}
