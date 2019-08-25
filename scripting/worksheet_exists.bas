
' Determine if a worksheet exists in an Excel workbook

' In VBA, to determine if an Excel workbook contains a specific
' worksheet, add a new Module to the workbook, then enter the
' following Public Function:

Public Function SheetExists(strSearchFor As String) As Boolean
  SheetExists = False

  For Each sht In ThisWorkbook.Worksheets
    If sht.Name = strSearchFor Then
      SheetExists = True
    End If
  Next sht
End Function

