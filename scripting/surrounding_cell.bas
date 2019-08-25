' From checkbook.xls:

' Insert next check number in sequence based on the previously entered number.
If ActiveCell.Column = 1 Then
  i = 0
  While n = ""
    i = i - 1
    n = ActiveCell.Offset(i, 0).Value
  Wend
  ' We want the *next* available check number.
  ActiveCell.Value = n + 1
End If
