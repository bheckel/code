#include <ncurses.h>			/* ncurses.h includes stdio.h */  
#include <string.h> 
 
int main(void) {
  char mesg[] = "Just a string in the middle of your rxvt.";
  int row, col;

  initscr();
	/* Get the number of rows and columns. */
  getmaxyx(stdscr, row, col);

  /* Print the message at the center of the screen. */
  mvprintw(row/2,(col-strlen(mesg))/2,"%s", mesg);
  /* Give stats at bottom of screen. */
  mvprintw(row-2, 0, "This screen has %d rows and %d columns\n", row,col);
  printw("Try resizing your window and then run this program again.");

  refresh();
  getch();
  endwin();
 
  return 0;
}
