#include <windows.h>

// Adapted: Fri Mar 25 12:35:53 2005 (Bob Heckel --
//              http://www12.canvas.ne.jp/peters/colin/win32/dll/example.html)
//
// Run these before building hello.dll.c:
//
// gcc -c -o dllhello.o dllhello.dll.c
// gcc -shared -o dllhello.dll dllhello.o -Wl,--out-implib,libdllhello.a

void DllHello () {
  MessageBox(NULL, "Hello, DLL world!", "Hello", MB_OK);

  return;
}
