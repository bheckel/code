/*****************************************************************************
 *     Name: lmit-unix-menu.c
 *
 *  Summary: Provide users with a menu to launch Vitalnet.
 *
 *           Assuming Putty screen used by the statisticians will ALWAYS be
 *           80x24
 *
 *           To compile:  $ gcc lmit-unix-menu.c -lmenu -lncurses
 *           Useful to debug with a non-solid black background to see where
 *           the windows lie.
 *           DEBUG mvprintw(1,1,"foo");
 *
 *           Make sure to chmod 775 vnet_usage_log so that all users in the
 *           'staff' group can append to the logfile.
 *
 *           Note: won't compile under Cygwin, use Debian box.
 *
 *  Created: Fri 28 Jun 2002 11:14:58 (Bob Heckel -- with ideas 
 *                                     from Pradeep Padala's NCURSES HOWTO )
 * Modified: Sun Jun 30 13:53:58 2002 (Bob Heckel -- add flush files
 *                                     to /tmp capability)
 * Modified: Wed Jul 10 13:20:40 2002 (Bob Heckel -- add usage statistic log)
 *****************************************************************************
*/
#include <stdio.h>
#include <curses.h>
#include <menu.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))
#define OPTIMAL_ROWS 24
#define CYAN  1
#define GREEN 2
#define RED   3
#define BLUE  4
// Symlinks will point to EHDP's actual, and always changing, name and
// location (e.g. /usr/local/ehdp/vn/ro/cur-exe/usu1-eg2)
#define VNET_UC_EXECUTABLE "/usr/local/bin/vnet_eg_version"
#define VNET_MC_EXECUTABLE "/usr/local/bin/vnet_mc_version"

void display_popup(char *popmsg);
void func(char *name);
char *getenv(const char *envname);
void print_in_middle(WINDOW *win, int starty, int startx, int width, 
                     char *headerstr, chtype color);
void write_usage(void);

const char *choices[] = { 
  "1.",
  "2.",
  "3.",
  "4.",
  "5.",
  (char *)NULL,
};
const char *descriptions[] = { 
  "EHDP's Vitalnet Underlying Cause",
  "EHDP's Vitalnet Multiple Cause (not yet available)",
  "Export your Vitalnet output log files to your PC",
  "Help",
  "Exit",
  (char *)NULL,
};


int main(void) {	
  ITEM **my_items;
	MENU *my_menu;
  WINDOW *my_menu_win;
  int c, n_choices, i, row, col;
  char *username = getenv("USER");
  char *welcome = "Welcome to the NCHS DAEB Mortality Data Analysis "
                  "Main Menu";

  write_usage();  // track who just opened this menu
	initscr();      // initialize curses 
	start_color();  // allow colors to be used
  cbreak();       // turn off buffering of characters
  noecho();       // also turns off buffering (good for portability)
  // stscr is the main, implicit, window.
	keypad(stdscr, TRUE);  // allow use of arrow keys, etc.
  // Mapped these numbers to colors in #defines above.
	init_pair(1, COLOR_CYAN, COLOR_BLACK);  // create COLOR_PAIR
	init_pair(2, COLOR_GREEN, COLOR_BLACK);
	init_pair(3, COLOR_RED, COLOR_BLACK);
	init_pair(4, COLOR_BLUE, COLOR_BLACK);

  attron(A_BOLD);
  attron(COLOR_PAIR(CYAN));
  getmaxyx(stdscr, row, col);
  if ( row != OPTIMAL_ROWS ) {
    mvprintw(17, 20, "You are displaying %d rows", row);
    mvprintw(18, 20, "This application is best viewed at %d rows", OPTIMAL_ROWS);
    mvprintw(19, 20, "You may want to reconfigure PuTTY");
  }
  mvprintw((row/2)-9, (col-strlen(welcome))/2, "%s", welcome);
  attroff(COLOR_PAIR(CYAN));
  attron(COLOR_PAIR(BLUE));
  mvprintw(0, 0, "Logged in as: %s", username);
  attroff(COLOR_PAIR(BLUE));
  attroff(A_BOLD);
  refresh();

	// Create menu items.
  n_choices = ARRAY_SIZE(choices);
  my_items = (ITEM **)calloc(n_choices + 1, sizeof(ITEM *));

  for ( i = 0; i < n_choices; ++i ) {
    my_items[i] = new_item(choices[i], descriptions[i]);
		// Set the ncurses user pointer.
		set_item_userptr(my_items[i], func);
	}
	my_items[n_choices] = (ITEM *)NULL;

	// Create the menu.
	my_menu = new_menu((ITEM **)my_items);

  // Create window to be associated with the menu.
  //                   r   c     y     x               
  ///my_menu_win = newwin(10, 60, (12)-5, 10);
  my_menu_win = newwin(10, 60, 7, 10);

  set_menu_win(my_menu, my_menu_win);
  // Lengthen the line that the "Vitalnet..." blurb goes on.
  set_menu_sub(my_menu, derwin(my_menu_win, 6, 58, 3, 1));

  set_menu_mark(my_menu, " * ");
  // Print a border around the sub window.
  box(my_menu_win, 0, 0);
  print_in_middle(my_menu_win, 0, 0, 70, "", COLOR_PAIR(GREEN));
	post_menu(my_menu);
	wrefresh(my_menu_win);

	while ( (c = getch()) != 'q' ) {
    switch( c ) {	
      case KEY_DOWN:
				menu_driver(my_menu, REQ_DOWN_ITEM);
				break;
			case KEY_UP:
				menu_driver(my_menu, REQ_UP_ITEM);
				break;
			case 10:  // the Enter key was pressed
        {	
          ITEM *cur;
          void (*p)(char *);

          cur = current_item(my_menu);
          p = item_userptr(cur);
          p((char *)item_name(cur));
          pos_menu_cursor(my_menu);
          break;
        }
      case 49:  // the 1 key was pressed
        func("1.");
        break;
      case 50:
        func("2.");
        break;
      case 51:
        func("3.");
        break;
      case 52:
        func("4.");
        break;
      case 53:
        func("5.");
        break;
		}
    // Bring the menu window back into focus after popping up and removing
    // the warning window. 
    touchwin(my_menu_win);
    wrefresh(my_menu_win);  // keypad keys won't work without this
	}	

	unpost_menu(my_menu);

	for ( i = 0; i < n_choices; ++i )
		free_item(my_items[i]);

	free_menu(my_menu);
	endwin();

  return 0;
}


// How to respond to menu selection:
// These should rely on external programs if they become too complex.
void func(char *name) {	
  ///char *command;
  // TODO a little more elegant, please
  ///char command[] = "this is fooooooooooooooooooooo initialization timeeeeeeee";
  char *command;
  char *username = getenv("USER");

  // Run Vitalnet Underlying Cause
  if ( strcmp(name, "1.") == 0 ) {
     endwin();                          // end curses mode temporarily
     ///system("/usr/local/bin/usu1-eg2"); // do whatever you like in cooked mode
     system(VNET_UC_EXECUTABLE);        // do whatever you like in cooked mode
     reset_prog_mode();                 // return to the previous tty mode
     refresh();                         // restore the screen contents
  }
  // Run Vitalnet Multiple Cause
  else if ( strcmp(name, "2.") == 0 ) {
    display_popup("Sorry, not yet available");
    touchwin(stdscr);
    refresh();
  }
  // Flush Vitalnet results to e.g. /tmp/vitalnet_output/bboswell
  else if ( strcmp(name, "3.") == 0 ) {
    // TODO make it mv
    asprintf(&command, "cp ~%s/* /tmp/vitalnet_output/%s/", 
                        username, username);
    system(command); 
    attron(COLOR_PAIR(GREEN));
    //        r   c
    mvprintw(18, 17, "%s", "Files have been moved and are ready to view.");
    ///mvprintw(19, 17, "%s", "Now run K:\\CABINETS\\EVERYONE\\map_to_daeb.bat");
    mvprintw(19, 5, "%s", "Now click Start:Programs:Lockheed Martin IT:Vitalnet:View_Vitalnet_Data");
    attroff(COLOR_PAIR(GREEN));
    touchwin(stdscr);
    refresh();
  }
  // Help
  else if ( strcmp(name, "4.") == 0 ) {
    attron(COLOR_PAIR(GREEN));
    // TODO use the right combo of screen refreshes
    mvprintw(18, 5, "%s", "                                                                        ");
    mvprintw(19, 5, "%s", "                                                                        ");
    mvprintw(18, 20, "%s", "Help is available via LMITHELP@cdc.gov, ");
    mvprintw(19, 20, "%s", "919-541-0458 or 919-541-3098");
    attroff(COLOR_PAIR(GREEN));
    refresh();
  }
  else if ( strcmp(name, "5.") == 0 ) {
    endwin();    // end curses mode permanently
    exit(0);
  }
  else {
    attron(COLOR_PAIR(RED));
    mvprintw(LINES - 4, 0, "Error: %s is not available.", name);
    attroff(COLOR_PAIR(RED));
  }
}	


// Display window in center of screen.
void print_in_middle(WINDOW *win, int starty, int startx, int width, 
                     char *headerstr, chtype color) {   
  int length, x, y;
  float temp;

  if ( win == NULL )
    win = stdscr;

  getyx(win, y, x);

  if ( startx != 0 )
    x = startx;

  if ( starty != 0 )
    y = starty;

  if ( width == 0 )
    width = 80;

  length = strlen(headerstr);
  temp = (width - length)/ 2;
  x = startx + (int)temp;
  wattron(win, color);
  mvwprintw(win, y, x, "%s", headerstr);
  wattroff(win, color);
  refresh();
}


// Display a short message to user until a key is pressed to dismiss it.
void display_popup(char *popmsg) {
  WINDOW *popup_ptr;

  //                  r   c  y  x 
  popup_ptr = newwin(11, 29, 8, 8);
  box(popup_ptr, '|', '-');
  mvwprintw(popup_ptr, 5, 2, "%s", popmsg);
  wrefresh(popup_ptr);
	getch();   // hang here and do nothing but let user read message
  delwin(popup_ptr);
}


// Write date, time, length of session to logfile.
// TODO this should probably fail silently since the user's aren't aware of
// usage tracking.
void write_usage(void) {
  time_t tval;
  char *fname = "/var/local/vnet_usage_log";  // chmod 775
  FILE *fptr;

  tval = time(NULL);

  //                    append
  if ( (fptr = fopen(fname, "a")) == NULL ) {
    printf("cannot open %s.  Exiting\n", fname);
    ///exit(1);
  }

  fprintf(fptr, "User: %s logged in at: %s", getenv("USER"), ctime(&tval));

  if ( fclose(fptr) == EOF ) {
    printf("cannot close %s.  Exiting.\n", fname);
    exit(1);
  }
}
