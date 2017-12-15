' Calc in/out of savings total cell (from checkbook.xls).
' Created: Sat Jan 11 10:24:43 2003 (Bob Heckel)
Dim c As Range
Dim into As Double
Dim outof As Double
Dim net As Double
Dim twelvemoprior As Variant

into = 0
outof = 0
twelvemoprior = CDate(DateSerial(Year(Now), Month(Now) - 12, 1))

'                                           Category
For Each c In Sheets("Centura").UsedRange.Columns(5).Cells
  If c.Offset(0, -3).Value > twelvemoprior Then
    If c.Value = "IntoSavings" Then
      ' Number could be a Dr. or a Cr.
        into = into + c.Offset(0, 1).Value + c.Offset(0, 2).Value
    ElseIf c.Value = "OutOfSavings" Then
      outof = outof + c.Offset(0, 1).Value + c.Offset(0, 2).Value
    End If
  End If
Next c
  
net = into - outof
Sheets("Budget").Range("b36").Value = net
