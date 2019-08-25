''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: column.bas
'
'  Summary: Return the number of the last column in the range.
'
'  Adapted: Mon 18 Nov 2002 12:44:32 (Bob Heckel -- VBA Help)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub PrintColNum
  Dim the_range As Range

  Set the_range = Range("a1:c1")

  ' Will print 3 b/c a is 1, b is 2, c is 3
  debug.print the_range.Columns(the_range.Columns.Count).Column
End Sub
