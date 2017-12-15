''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: specialcells.bas
'
'      Summary: Return the value of the last cell in the spreadsheet.
'               Finds bottom better than other methods. Improved find bottom.
'
'      Created: Fri Jun 11 1999 15:51:50 (Bob Heckel)
'     Modified: Tue Jun 25 14:42:21 2002 (Bob Heckel -- add
'                                         IterateAllCellsWithData() )
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub Caller()
  MsgBox "Here is the return value: " & LastCell
End Sub

Function LastCell()
  Dim x, y
  
  ' Returns row number of last row with data in spdsht.
  x = Cells.SpecialCells(xlCellTypeLastCell).Row
  y = Cells.SpecialCells(xlCellTypeLastCell).Column

  LastCell = Cells(x, y).Value
End Function


Sub IterateAllCellsWithData()
  ' Not required if you have selected the sheet of interest.
  '''Workbooks("book2").Worksheets("sheet1").Activate
  Dim CurrCell As Range
  '''For Each CurrCell In ActiveSheet.Cells.SpecialCells(xlCellTypeConstants)
  For Each CurrCell In Cells.SpecialCells(xlCellTypeConstants)
    Debug.Print CurrCell.Value
  Next
End Sub
