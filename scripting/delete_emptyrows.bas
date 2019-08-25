''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: delete_emptyrows.bas
'
' Summary: Delete all empty rows from spreadsheet.
'
' Adapted: Sun, 25 Feb 2001 14:08:49 (Bob Heckel -- from John Walkenbach
'                               http://www.j-walk.com/ss/excel/tips/index.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub DeleteEmptyRows()
  LastRow = ActiveSheet.UsedRange.Row - 1 + ActiveSheet.UsedRange.Rows.Count

  Application.ScreenUpdating = False

  For r = LastRow To 1 Step -1
    If Application.CountA(Rows(r)) = 0 Then Rows(r).Delete
  Next r
End Sub 

