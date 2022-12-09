/*****************************************************************************
 *    Name: ascii
 *
 *  Summary: Display binary, decimal, octal and hexadecimal representation of
 *           ascii character passed to program after prompt.
 *
 *           Or to go in reverse, if you know the ASCII value, use perl:  
 *             print pack "C", 97;
 *           or if you only know the hex code:
 *             print pack "C", hex(61);
 * 
 *           ESSENTIAL
 *
 *  Created: Sat, 16 Sep 2000 15:58:09 (Bob Heckel -- Teach Yourself
 *                                     C Herbert Schildt)
 * Modified: Tue 09 Jul 2002 15:47:57 (Bob Heckel -- keep looping)
 * Modified: Sun 29 Feb 2004 17:03:09 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  int ch;   // preferred over char ch;
  int i;
  int j;

  puts("This loops over your input but it only translates alpha to num.");
  puts("Might be better to use perl:");
  puts("e.g. perl -e 'print unpack \"C\", a'");
  puts("e.g. perl -e 'print pack \"C\", 97'");
  switch ( argc ) {
    case 1:
      puts("Enter a single case sensitive ASCII char (Ctrl-d to quit): ");
      while ( (ch = getchar()) != EOF ) {
        for ( i=128, j=1; i>0; i=i/2, j++ ) {
          if ( i & ch ) printf("1");
          else printf("0");
          // Beautification purposes only.
          if ( j == 4 ) printf(" ");
        }
        printf(" BIN\n");
        printf("0%o OCT\n", ch);
        printf("%d DEC\n", ch);
        printf("0x%x HEX\n\n", ch);
        getchar();  // chomp the newline that came after the char
      }
      break;
    case 2:
      ch = *argv[1];
      if ( strncmp(*argv, "-h", 2) ) {
        fprintf(stderr, "Usage: %s char\n", *argv);
        exit(1);
      }
      break;
    default:
      puts("Sorry, only one char at a time.");
      // Usage();
      fprintf(stderr, "Usage: %s\n", *argv);
      exit(1);
      break;
  }

  exit(0);
}

