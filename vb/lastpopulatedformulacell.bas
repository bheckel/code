''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: lastpopulatedformulacell.bas
'
'  Summary: Find the last non-empty formula cell in a worksheet.
'
'  Created: Sat 07 Sep 2002 09:51:18 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub Test()
  Dim x
  
  x = LastPopulatedFormulaCell
  Debug.Print x
End Sub


Function LastPopulatedFormulaCell()
  Dim CurrCell As Range

  ' Look at all cells with formulas...
  For Each CurrCell In Sheets("Centura").Cells.SpecialCells(xlCellTypeFormulas)
    ' ...and capture the last one whose neighbor to the south is blank.
    If CurrCell.Offset(1, 0) = "" Then
      LastPopulatedFormulaCell = CurrCell.Value
      Exit Function
    End If
  Next
End Function
