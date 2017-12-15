''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: comment_popups.bas
'
' Summary: Demo of using objects in Excel.  Counts Excel comments, highlights
'          the cells containing comments and writes a new worksheet listing
'          the comments it found.
'
' Adapted: Tue 18 Jun 2002 16:29:57 (Bob Heckel -- John Walkenback Excel 2000
'                                    VBA Power Programming)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub ManipulatePopupComments()
  Dim CommentCount As Integer

  CommentCount = 0

  For Each cell In ActiveSheet.UsedRange
    On Error Resume Next
    x = cell.Comment.Text
    If Err = 0 Then CommentCount = CommentCount + 1
  Next cell

  If CommentCount = 0 Then
    MsgBox "The active worksheet does not contains any comments.", _
            vbInformation
  Else
    MsgBox "The active worksheet contains " & CommentCount & _
           " comments.", vbInformation
  End If
  
  ' Highlight commented cells.
  Cells.SpecialCells(xlCellTypeComments).Select
  
  ' Create new workbook with one sheet.
  On Error GoTo 0
  Set CommentSheet = ActiveSheet
  OldSheets = Application.SheetsInNewWorkbook
  Application.SheetsInNewWorkbook = 1
  Workbooks.Add
  Application.SheetsInNewWorkbook = OldSheets
  ActiveWorkbook.Windows(1).Caption = "Comments for " & _
                       CommentSheet.Name & " in " & CommentSheet.Parent.Name
  
  ' List the comments.
  Row = 1
  Cells(Row, 1) = "Address"
  Cells(Row, 2) = "Contents"
  Cells(Row, 3) = "Comment"
  Range(Cells(Row, 1), Cells(Row, 3)).Font.Bold = True

  For Each cell In CommentSheet.UsedRange
    On Error Resume Next
    x = cell.Comment.Text
    If Err = 0 Then
      Row = Row + 1
      Cells(Row, 1) = cell.Address(rowabsolute:=False, columnabsolute:=False)
      Cells(Row, 2) = " " & cell.Formula
      Cells(Row, 3) = cell.Comment.Text
    End If
  Next cell

  Columns("B:B").EntireColumn.AutoFit
  Columns("C:C").ColumnWidth = 34
  Cells.EntireRow.AutoFit
End Sub
