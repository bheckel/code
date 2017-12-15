'VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: deleterowgeneric.bas
'
' Summary: Based on specific start, end and string passed, this will 
'          delete the entire row.
'
' Created: Thu, 23 Sep 1999 15:11:06 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub deleterow()
  Dim c
  Dim myinput, mytop, mybot, myref As String
  
  Range("a1").Select

  MsgBox ("This macro will delete each row where the value is found in current worksheet.")
  mytop = InputBox("Enter top leftmost Column & Row. E.g. A1") & ":"
  mybot = InputBox("Enter bottom rightmost Column & Row. E.g. ZZ100")
  myref = mytop & mybot
  myinput = InputBox("Enter value.  It is case-sensitive.") & "*"
GETMORE:
  ' Doesn't work for non-contiguous ranges like Edward's spreadsheet.
  '''For Each c In ActiveCell.CurrentRegion.Cells
  For Each c In ActiveSheet.Cells.Range(myref)
    If c.Value Like myinput Then
      c.EntireRow.Delete
      ' To prevent skipping another match that immediately follows a deletion,
      ' move to cell A1 and redo all remaining cells.
      GoTo GETMORE
    End If
  Next
    
  Range("a1").Select
End Sub

