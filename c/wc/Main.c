/* Adapted: Mon 15 Oct 2001 14:59:01 (Bob Heckel --
 *       http://heather.cs.ucdavis.edu/~matloff/UnixAndC/CLanguage/Make.html) 
 *  introductory C program 
 *
 *   implements (a subset of) the Unix wc command  --  reports character, 
 *   word and line counts; in this version, the "file" is read from the 
 *   standard input, since we have not covered C file manipulation yet, 
 *   so that we read a real file can be read by using the Unix `<'
 *   redirection feature
 */

#include "Defs.h"

extern int ReadLine(), WordCount();

char Line[MaxLine];		/* one line from the file */
int  NChars = 0;		/* number of characters seen so far */
int  NWords = 0;		/* number of words seen so far */
int  NLines = 0;		/* number of lines seen so far */
int  LineLength;		/* length of the current line */


int
main(void)
{
  while ( 1 ) {
    LineLength = ReadLine();
    if (LineLength == 0)
      break;
    UpdateCounts();
  }

  printf("%d %d %d\n", NChars, NWords, NLines);

  return 0;
}
