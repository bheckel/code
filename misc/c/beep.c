/*****************************************************************************
 *     Name: beep.c
 *
 *  Summary: Make a sound and optionally popup a message and accept Yes or No,
 *           then return the button
 *
 *  Created: Tue 28 Aug 2001 14:21:18 (Bob Heckel)
// Modified: Tue 01 Apr 2014 14:53:40 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>
#include <windows.h>

int main(int argc, char *argv[]) {
  int buttonCode;

  // Pitch, duration
  Beep(500, 4000);
  // This produces the beep before the message box.
  MessageBeep(MB_ICONASTERISK);

  // A message has been passed for display.
  if ( argc == 2 ) {
    if ( !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help") ) {
      fprintf(stderr, "Usage: %s <message>\nBeeps and optionally prompts "
                      "user then returns button value.\n", argv[0]);
      exit(1);
    }

    buttonCode = MessageBox(NULL, argv[1], "beep", 
                            MB_YESNO+MB_SYSTEMMODAL+MB_DEFBUTTON2+MB_TOPMOST);


    // MFC constant 6 is yes, 7 is no
    buttonCode -= 6;

    return buttonCode;
  }

  return 0;
}

