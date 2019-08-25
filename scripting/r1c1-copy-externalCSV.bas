''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: r1c1-copy-externalCSV.bas
'
'  Summary: Open a CSV, copy its contents and paste into a new workSHEET in
'           the host spreadsheet.
'
'  Created: Mon 03 Apr 2006 13:24:29 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub OpenExternalAndPaste()
  Workbooks.Open "C:\cygwin\home\bheckel\tmp\testing\t.csv"
  
  x = Cells.SpecialCells(xlCellTypeLastCell).Row
  y = Cells.SpecialCells(xlCellTypeLastCell).Column

  Range(Cells(1, 1), Cells(x, y)).Copy
  Worksheets.Add
  ActiveSheet.Paste
End Sub


' t.csv:
' one,two,3,four
' five,six,7,eight
' nine,ten,11,twelve


' This version from Gary Minor is probably better: 

 Sub CommaDelimitSource(pstrWorklistID As String)

    Dim lstrCSVFile As String
        
    lstrCSVFile = "C:\ALT_IDE\LIMs\" & pstrWorklistID & ".csv"
              
    Workbooks.Open (lstrCSVFile)
    Worksheets(1).Copy Before:=Workbooks(1).Worksheets(1)
    Workbooks(1).Worksheets(1).Name = "Source"
    Workbooks(1).Activate
End Sub
