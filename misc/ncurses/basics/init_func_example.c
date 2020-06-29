#include <ncurses.h>

/* Display a single formatted character. */
int main(void) {	
  int ch;

	initscr();
	raw();				          /* line buffering disabled         */
	keypad(stdscr, TRUE);		/* we get access to F1, F2, etc... */
	noecho();			          /* don't echo() while we do getch  */
  /* If raw() hadn't been called we would have had to press enter before it
   * gets to the program.
   */
	ch = getch();

	if ( ch == KEY_F(1) )	{
    /* TODO not working, doesn't see F1 as special */
    /* Assumes keypad() has been called previously. */
		printw("F1 Key pressed");
	} else {	
    /* Without noecho() some ugly escape characters might have been printed on
     * screen.
     */
    printw("The pressed key is ");
    /* OPTION 1 */
    /* Switch on attribute (stays on until explicitly turned off). */
		///attron(A_BOLD);     
		///printw("this: %c", ch);
		///attroff(A_BOLD);    /* switch off attribute */

    /* OPTION 2 */
    /* Alternative display and formatting method. */
    ///move(10, 5);
    /* Print ch in bold and underlined. */
    ///addch(ch | A_BOLD | A_UNDERLINE);

    /* OPTION 3 */
    /* Most concise: */
    mvaddch(10, 5, ch | A_BOLD | A_UNDERLINE);
	}

	refresh();	/* print it to the real screen (only works on stdscr) */
	endwin();

	return 0;
}
