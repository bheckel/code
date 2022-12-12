/*****************************************************************************
 *     Name: typedef_enum.c
 *
 *  Summary: Create a typedef on an enum.
 *
 *           See also typedef_struct.c
 *
 *  Created: Sat 31 Jan 2004 21:22:23 (Bob Heckel)
 *****************************************************************************
*/
#include <stdio.h>

typedef enum { undoNone, undoTyping, undoBackspace, undoDelete,
               undoPaste, undoCut, undoInput } UndoMode;

int main(int argc, char *argv[]) {
  UndoMode num;

  num = undoInput;

  printf("%d", num);

  return 0;
}

