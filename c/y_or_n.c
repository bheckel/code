/*****************************************************************************
 *     Name: y_or_n.c
 *
 *  Summary: Receive confirmation from user.  Yes or no.
 *
 *  Adapted: Fri 10 Aug 2001 22:35:24 (Bob Heckel--Libc.txt)
 *****************************************************************************
*/
#include <stdio.h>

int y_or_n_p(const char *question) {
  fputs(question, stdout);

  while ( 1 ) {
    int c, answer;

    /* Write a space to separate answer from question. */
    fputc(' ', stdout);

    /* Read the first character of the line.
       This should be the answer character, but might not be. */
    c = tolower(fgetc(stdin));
    answer = c;

    /* Discard rest of input line. */
    while ( c != '\n' && c != EOF )
      c = fgetc(stdin);

    /* Obey the answer if it was valid. */
    if ( answer == 'y' )
      return 0;
    if ( answer == 'n' )
      return 1;
    /* Answer was invalid: ask for valid answer. */
    fputs("Please answer y or n:", stdout);
  }
}

int main(int argc, char *argv[]) {
  int rc;

  rc = y_or_n_p("did you do it?");

  return rc;
}
