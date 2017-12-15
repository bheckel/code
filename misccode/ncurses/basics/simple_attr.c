#include <ncurses.h>

/* Highlights comments in C source file passed to it. */
int main(int argc, char *argv[]) {	
  int ch, prev;
	FILE *fp;
	int goto_prev = FALSE, y, x;

	if ( argc != 2 ) {	
    printf("Usage: %s <my_C_filename>.  Must be Unix format.\n", argv[0]);
		exit(1);
	}

	fp = fopen(argv[1], "r");
	if ( fp == NULL ) {	
    perror("Cannot open input file");
		exit(1);
	}

	initscr();		/* start curses mode */

	prev = EOF;

	while ( (ch = fgetc(fp)) != EOF ) {	
    /* If it is '/' then switch bold on. */	
    if ( prev == '/' && ch == '*' ) 	{	
      attron(A_BOLD);
      /* Go back to previous char, '/', and print it in BOLD. */
			goto_prev = TRUE; 	
		}

		if ( goto_prev == TRUE ) {	
      getyx(stdscr, y, x);
			move(y, x - 1);
      printw("%c%c", '/', ch); /* the actual printing is done here */
      /* Set it to FALSE or every thing from here will be '/' */
			goto_prev = FALSE;	
		}
		else
			printw("%c", ch);

		refresh();
		if ( prev == '*' && ch == '/' )
			attroff(A_BOLD);	/* switch it off */

		prev = ch;
	}
	
	endwin();   /* end curses mode */

	return 0;
}
