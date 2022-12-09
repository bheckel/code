#include <windows.h>

// Adapted: Fri Mar 25 12:35:53 2005 (Bob Heckel --
//              http://www12.canvas.ne.jp/peters/colin/win32/dll/example.html)
//
// Build this after building the DLL from dllhello.dll.c:
//
// gcc -c -o hello.o hello.dll.c
// gcc -mwindows -o hello.exe hello.o -L. -ldllhello
//
//    - The -mwindows makes the resulting program a
//      GUI program instead of a console program. If you don't do this a
//      console window will pop up when you run the program.
//    - The -L. makes gcc look in the current directory for libraries. If you
//      don't do this you will get an error like this:
//
//    ld.exe: cannot find -ldllhello
//
// TODO gives warning under Cygwin

extern void DllHello();

int STDCALL
WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmd, int nShow) {
  DllHello();

  return 0;
}
