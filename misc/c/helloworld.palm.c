/*****************************************************************************
 *     Name: helloworld.palm.c
 *
 *  Summary: Demo of Palm app.  Assumes tools (SDK, etc.) on Cygwin have 
 *           been set up previously.  See rme palmdev
 *
 *           Compile:
 *           $ m68k-palmos-gcc helloworld.palm.c -o hello
 *           $ m68k-palmos-obj-res hello
 *           $ build-prc hello.prc "Hello, World" RSH1 *.hello.grc
 *           $ rm *.hello.grc hello hello.prc    <---cleanup
 *
 *           Poor man's Makefile:
 *           $ m68k-palmos-gcc helloworld.palm.c -o hello && m68k-palmos-obj-res hello && build-prc hello.prc "Hello, World" RSH1 *.hello.grc && rm *.hello.grc hello
 *
 *  Adapted: Sun 25 Jan 2004 22:38:52 (Bob Heckel --
 *                            http://www.tldp.org/REF/palmdevqs/index.html)
 * Modified: Sun 05 Jun 2005 09:25:12 (Bob Heckel)
 *****************************************************************************
*/
#include <PalmOS.h>

// PilotMain is called by the startup code and implements a simple event
// handling loop.
UInt32 PilotMain(UInt16 cmd, void *cmdPBP, UInt16 launchFlags) {
  EventType event;

  if ( cmd == sysAppLaunchCmdNormalLaunch ) {
    // Display a string.
    WinDrawChars( "Hello, world!", 13, 55, 60 );

    //  Main event loop:
    do {
      // Doze until an event arrives.
      EvtGetEvent( &event, evtWaitForever );

      // System gets first chance to handle the event.
      SysHandleEvent( &event );

      // Normally, we would do other event processing here.

    // Return from PilotMain when an appStopEvent is received.
    } while ( event.eType != appStopEvent );
  }

  return;
}
