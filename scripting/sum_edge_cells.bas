''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: sum_edge_cells.bas
'
' Summary: Place a formula in the rightmost column.  It will sum all columns
'          to its left and overwrite its value with this formula.
'
'  Created: Tue 25 Jun 2002 16:33:41 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub SumEdgeCells()
  Dim CurrCell As Range

  ' Look at all contiguous cells in the actively selected workbook.
  For Each CurrCell In Cells.SpecialCells(xlCellTypeConstants)
    ' Figure out which cell is to be overwritten by the R1C1 formula.
    ' Its neighbor to the right will always be blank.
    If CurrCell.Offset(0, 1) = "" Then
      ' We are trying to build something like this:  =SUM(RC[-3]:RC[-1]) 
      CurrCell.FormulaR1C1 = "=SUM(RC[-" & CurrCell.Offset(0,-1).Column & _
                             "]:RC[-1])"
    End If
  Next
End Sub
