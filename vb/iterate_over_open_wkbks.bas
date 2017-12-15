Dim thing As Object  ' Declared as generic object.

Sub IterateOverOpenWkbks
  'thing is an Object/Workbook
  For Each thing In Workbooks
    Range("a1").Value = "zzzzzzz"
  Next
End Sub
