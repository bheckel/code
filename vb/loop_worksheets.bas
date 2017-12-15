
Sub WkSheetList()
  Dim ws As Worksheet

  For Each ws In ActiveWorkbook.Worksheets
    Debug.Print ws.Name
  Next ws
End Sub

