''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: loop_cells_like.bas
'
'  Summary: Demo of reading an open workbook searching for a string using
'           LIKE and writing the results to an external textfile.
'
'           Searches every cell in the workbook
'
'  Created: Wed 30 Jul 2008 14:33:42 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub LoopCells()
  Dim fnum As Integer
  fnum = FreeFile

  Open "c:\temp\testfile" For Output As #fnum

  Dim c
  For Each c In ActiveCell.CurrentRegion.Cells
    If c.Value Like "5ZM0090-040000124969*" Then
     Print #fnum, "This is a test " & c.Value
    End If
  Next
  
  Close #fnum
End Sub
