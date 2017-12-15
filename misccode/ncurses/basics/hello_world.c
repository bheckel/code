#include <ncurses.h>

int main(void) {	
	initscr();		/* initialize the terminal in curses mode */
 /* Mandatory doublequotes. */
	printw("Hello World at coordinates 0,0.");
	printw(" This screen is called 'stdscr' until refresh() is called"); 
	refresh();	  /* print it on to the real screen */
  /* Clean up after the ncurses routines.  Restore tty modes to what they were
   * when initscr() was first called and moves the cursor down to the
   * lower-left corner. 
   */
	endwin();

	return 0;
}
