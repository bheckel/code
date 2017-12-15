''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: object_vs_normal_vari.bas 
'
' Summary: Benchmark two styles of coding. 
'
' Adapted: Sun, 25 Feb 2001 14:08:49 (Bob Heckel -- from John Walkenbach
'                               http://www.j-walk.com/ss/excel/tips/index.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Macro1()
 ' No object variable
  Dim i As Integer

  starttime = Timer

  For i = 1 To 5000
    ThisWorkbook.Sheets("Sheet1").Range("A1:B12").Value = i
  Next i

  MsgBox Timer - starttime
End Sub


Sub Macro2()
 ' With object variable
  Dim i As Integer
  Dim the_range As Range                                         ' ONE

  starttime = Timer

  Set the_range = ThisWorkbook.Sheets("Sheet1").Range("A1:B12")  ' TWO

  For i = 1 To 5000
    the_range.Value = i
  Next i

  MsgBox Timer - starttime
End Sub

