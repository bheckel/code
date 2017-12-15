' This should be inserted into a MS Objects Sheet.
' Used by checkbook.xls
' Insert current date/time in cell that user has doubleclicked.
Private Sub Worksheet_BeforeDoubleClick(ByVal Target As Range, Cancel As Boolean)
  Dim datestamp As String
  
  datestamp = Date
  ActiveCell.FormulaR1C1 = datestamp
End Sub
