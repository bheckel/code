' Insert current date/time in cell that user has doubleclicked.
Private Sub Worksheet_BeforeDoubleClick(ByVal Target As Range, Cancel As Boolean)
  Dim datestamp As String
  
  '                   col B
  If ActiveCell.Column = 2 Then
    datestamp = Date
    ActiveCell.FormulaR1C1 = datestamp
  End If
End Sub
