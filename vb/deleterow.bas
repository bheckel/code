'VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: deleterow.bas
'
' Summary: Based on specific string passed, will delete entire row.
'
' Created: Fri, 27 Aug 1999 14:31:20 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub deleterow()
  Dim c
  Dim myinput

'  myinput = InputBox("Enter value.  Will delete row if value is found anywhere in current worksheet.  It is case-sensitive.")
GETMORE:
  For Each c In ActiveCell.CurrentRegion.Cells
    If c.Value Like myinput Then
      c.EntireRow.Delete
      ' To prevent skipping another match that immediately follows a deletion,"
      ' move to cell A1 and redo all remaining cells.
      GoTo GETMORE
    End If
  Next
'  Range("a1").Select
End Sub
