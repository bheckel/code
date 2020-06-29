#include <ncurses.h>			/* ncurses.h includes stdio.h */  
#include <string.h> 
 
int main(void) {
 char mesg[] = "Enter a string: ";
 char str[80];
 int row,col;

 initscr();           				/* start the curses mode */
 getmaxyx(stdscr,row,col);		/* get the number of rows and columns */
 /* Print the request for input at the center of the screen. */
 mvprintw(row/2, (col-strlen(mesg))/2, "%s", mesg);
 
 getstr(str);
 mvprintw(23, 0, "You Entered: %s", str);
 getch();
 endwin();

 return 0;
}
