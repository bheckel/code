''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: delimited_quoting_fix.bas
'
' Summary: Fixes the MS mandatory enquoting of embedded commas in tab
'          delimited textfiles.  Prompts you for name of textfile.
'          Currently hardcoded for only tab-delimited Excel input.
'
' Adapted: Tue May 07 14:49:55 2002 (Bob Heckel --
'                                 http://www.cpearson.com/excel/imptext.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public Sub ExportToTextFile(FName As String, Sep As String, _
                            SelectionOnly As Boolean)
  Dim WholeLine As String
  Dim FNum As Integer
  Dim RowNdx As Long
  Dim ColNdx As Integer
  Dim StartRow As Long
  Dim EndRow As Long
  Dim StartCol As Integer
  Dim EndCol As Integer
  Dim CellValue As String

  Application.ScreenUpdating = False
  On Error GoTo EndMacro:
  FNum = FreeFile

  If SelectionOnly = True Then
    With Selection
      StartRow = .Cells(1).Row
      StartCol = .Cells(1).Column
      EndRow = .Cells(.Cells.Count).Row
      EndCol = .Cells(.Cells.Count).Column
    End With
  Else
    With ActiveSheet.UsedRange
      StartRow = .Cells(1).Row
      StartCol = .Cells(1).Column
      EndRow = .Cells(.Cells.Count).Row
      EndCol = .Cells(.Cells.Count).Column
    End With
  End If

  Open FName For Output Access Write As #FNum

  For RowNdx = StartRow To EndRow
    WholeLine = ""
    For ColNdx = StartCol To EndCol
      If Cells(RowNdx, ColNdx).Value = "" Then
        CellValue = Chr(34) & Chr(34)
      Else
       CellValue = _
       Application.WorksheetFunction.Text _
        (Cells(RowNdx, ColNdx).Value, _
            Cells(RowNdx, ColNdx).NumberFormat)
      End If
      WholeLine = WholeLine & CellValue & Sep
    Next ColNdx
    WholeLine = Left(WholeLine, Len(WholeLine) - Len(Sep))
    Print #FNum, WholeLine
  Next RowNdx

  EndMacro:
  On Error GoTo 0
  Application.ScreenUpdating = True
  Close #FNum

End Sub

Public Sub DoTheExport()
  Dim FName As Variant
  Dim Sep As String

  FName = Application.GetSaveAsFilename()
  If FName = False Then
    MsgBox "You didn't select a file"
    Exit Sub
  End If

  '''Sep = InputBox("Enter a single delimiter character (e.g., comma or semi-colon)", _
  '''        "Export To Text File")
  Sep = Chr(9)

  ExportToTextFile CStr(FName), Sep, FALSE
End Sub
