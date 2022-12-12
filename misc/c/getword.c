/*****************************************************************************
 *     Name: getword.c
 *
 *  Summary: Demo of getting words from stdin.
 *
 *  Adapted: Sat 11 Aug 2001 15:08:35 (Bob Heckel--K&R ANSI C V.2)
 *****************************************************************************
*/
#include <stdio.h>
#include <ctype.h>  // for isspace, isalpha, isalnum

#define BUFSIZE 100

int getword(char *word, int lim);
// The next 2 work together using a shared buffer.
int getch(void);      
void ungetch(int c);

// Globals.
char BUF[BUFSIZE];   // buffer for ungetch
int BUFP = 0;    // next free position in BUF


int main(int argc, char **argv) {
  char word[50] = {};
  
  printf("%s echoes your word(s).  Ctrl-D to exit\n", argv[0]);

  while ( getword(word, 80) != EOF ) {
    printf("here is your word: %s\n", word);
  }

  return 0;
}


// Get entire whitespace delimited word but return only the first char.
int getword(char *word, int lim) {
  int c = 0;
  ///char *w = word;
  char *w = NULL;
  w = word;

  while ( isspace(c = getch()) );

  if ( c != EOF )
    *w++ = c;

  if ( !isalpha(c) ) { 
    *w = '\0';
    return c;
  }

  for ( ; --lim>0; w++ ) {
    if ( !isalnum(*w = getch()) ) {
      ungetch(*w);
      break;   // out of the 'for' loop
    }
  }

  *w = '\0';

  return word[0];
}


// Get a (possibly pushed-back) character.
int getch(void) {
  return (BUFP > 0) ? BUF[--BUFP] : getchar();
}


// Push character back on input.
void ungetch(int c) {
  if ( BUFP >= BUFSIZE )
    printf("ungetch: too many characters\n");
  else 
    BUF[BUFP++] = c;
}


