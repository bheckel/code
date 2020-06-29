#include <curses.h>
#include <menu.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

// compile and link: gcc <program file> -lmenu -lncurses

char *choices[] = {
  "Choice 1",
  "Choice 2",
  "Choice 3",
  "Exit",
};

int main() {	
  ITEM **my_items;
	int c;				
	MENU *my_menu;
  int n_choices, i;
	ITEM *cur_item;
  int whattodo;
	
	initscr();
  cbreak();
  noecho();
	keypad(stdscr, TRUE);
	
  n_choices = ARRAY_SIZE(choices);
  my_items = (ITEM **)calloc(n_choices + 1, sizeof(ITEM *));

  for ( i = 0; i < n_choices; ++i )
    my_items[i] = new_item(choices[i], choices[i]);
    ///my_items[i] = new_item(choices[i]);

	my_items[n_choices] = (ITEM *)NULL;

  // Attach items to the menu.
	my_menu = new_menu((ITEM **)my_items);
	post_menu(my_menu);
	refresh();

	///while ( (c = getch()) != KEY_F(1) ) {       
	///while ( (c = getch()) != 'q' ) {       
	while ( (c = getch()) != 'q' ) {       
    switch ( c ) {	
      case KEY_DOWN:
        // The workhorse.
				menu_driver(my_menu, REQ_DOWN_ITEM);
				break;
			case KEY_UP:
        // The workhorse.
				menu_driver(my_menu, REQ_UP_ITEM);
        ///printw("ok");
				break;
      default:
        ///printw("ok %s", cur_item);
        printw("ok this works but is useless");
        ///system("ls");
		}
	}	

	free_item(my_items[0]);
  free_item(my_items[1]);
	free_menu(my_menu);
	endwin();
}
