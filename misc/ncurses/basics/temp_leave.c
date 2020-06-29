#include <ncurses.h>

/* Gives a "Hello World" then drops you onto an ugly command prompt.  Do a
 * Ctrl-d to exit that shell and it gives you "Another String". 
 */
int main() {	
	initscr();			    /* start curses mode */
	printw("Hello World\n");
	refresh();		      /* print it on to the real screen */
	def_prog_mode();		/* save the tty modes		  */
	endwin();			      /* end curses mode temporarily */
	system("/bin/sh");	/* do whatever you like in cooked mode */
  /* Return to the previous tty mode which has been stored by def_prog_mode() */
	reset_prog_mode();	
	refresh();          /* do refresh() to restore the screen contents */
  /* Back to curses; use the full capabilities of curses. */
	printw("Another String\n");	
	refresh();			
	endwin();           /* end curses mode */

	return 0;
}
