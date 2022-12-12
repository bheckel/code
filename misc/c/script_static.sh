#!/bin/bash
##############################################################################
#     Name: script_static.sh
#
#  Summary: Demo of static C library.
#
# Program library:  a file containing compiled code (and data) that is to be
#                   incorporated later into a program.  There are 3 types.
#
# Static library:  installed into a pgm executable before the pgm is run.
#                  Libraries end in '.a'.  Allows users to link to pgms
#                  without having to recompile.
#                  Create:
#                    $ ar rcs my_library.a file1.o file2.o  <---adds 2 object
#                    files to the static library my_library.a, creating
#                    my_library.a if needed, otherwise adding to it.
#                  Use:
#                    $ gcc ... -lmy_library
#
# Shared library:  loaded at program start-up and shared between pgms.
#                  Create:
#                    $ gcc -fPIC -c a.c
#                    $ gcc -fPIC -c b.c
#                    $ gcc -shared -Wl, -soname, libmystuff.so.1 \
#                          -o libmystuff.so.1.0.1 a.o b.o -lc
#
# Dynamic library:  can be loaded and used at any time while a pgm is
#                   running.
#
# Adapted: Fri 14 Sep 2001 14:23:02 (Bob Heckel -- Program Library HOWTO)
##############################################################################

#include "libhello.h"

int main(void) {
  hello();

  return 0;
}

# Assumes the following 3 files exist in this dir:

# libhello.c --- demonstrate library use
#   #include <stdio.h>
# 
#   void hello(void) {
#     printf("hello library world\n");
#   }

# libhello.h --- demonstrate library use
#   void hello(void);

# demo_use.c --- demonstrate direct use of the "hello" routine
#   #include "libhello.h"
#
#   int main(void) {
#     hello();
# 
#     return 0;
#   }

# Cleanup previous run.
###rm -i *.[oa]
###rm -i *.exe
ls -l *.[choa]
echo

echo "Create static library's object file, libhello-static.o"
gcc -Wall -g -c -o libhello-static.o libhello.c
echo 'After $ gcc -Wall -g -c -o libhello-static.o libhello.c'
ls -l *.[choa]
echo

echo 'Create static library, libhello-static.a'
ar -rcs libhello-static.a libhello-static.o
echo 'After $ ar -rcs libhello-static.a libhello-static.o'
ls -l *.[choa]
echo

# We'll keep libhello-static.a in the PWD for testing purposes.

echo 'Compile demo_use object file, demo_use.o'
gcc -Wall -g -c -o demo_use.o demo_use.c
echo 'After $ gcc -Wall -g -c -o demo_use.o demo_use.c'
ls -l *.[choa]
echo

echo 'Create demo_use_static_pgm.exe'
# -L. causes "." to be searched during creation of the pgm.
# This command causes the relevant object file in libhello-static.a (in PWD)
# to be incorporated into pgm demo_use_static_pgm.exe
gcc -g -o demo_use_static_pgm demo_use.o -L. -lhello-static   || exit 1
#                                              ^^^^^^^^^^^^^^
#                                           no 'lib'   no' .a'
#                                            thanks to the -l
echo 'After $ gcc -g -o demo_use_static_pgm demo_use.o -L. -lhello-static'
ls -l *.[choa]
ls -l *.exe
echo

# Test it.
./demo_use_static_pgm
