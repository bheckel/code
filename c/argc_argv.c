/*****************************************************************************
 *     Name: argc_argv.c
 *
 *  Summary: Demo of extracting elements from argument vector argv.
 *           E.g. $ ./a.exe foo bar
 *
 *  Created: Wed 05 Dec 2001 11:19:17 (Bob Heckel)
 * Modified: Wed 09 Oct 2002 14:49:20 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

int Parse(char *the_args[]) {
  puts("in Parse()");
  printf("argv[1] is: %s\n", &(the_args[1][0]));
  printf("argv[1][1] is: %s\n", &(the_args[1][1]));
  printf("argv[2] is: %s\n", &(the_args[2][0]));
  the_args[2] = "this is the new value of the_args[2]";

  return 0;
}


int main(int argc, char *argv[]) {
  int i;

  puts("in main()");

  if ( argc < 2 ) { 
    puts("Error: must pass something to this pgm.");
    puts("Exiting.");
    exit(1); 
  }

  for ( i=0; i != argc; i++ ) {
    printf("argv[%d] is:", i);
    puts(argv[i]);
  }

  puts("Here's another way to determine the name of this pgm: ");
  puts(*argv);
  puts("\n");

  puts("Now walk the string: ");
  puts(++(*argv));
  puts(++(*argv));
  puts("\n");
  puts("Rewound: ");
  puts(--(*argv));
  puts(--(*argv));
  puts("\n");

  Parse(argv);
  printf("back in main(): %s\n", argv[2]);

  return 0;
}
