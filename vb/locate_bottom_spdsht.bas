Obsolete...see specialcells.bas or find_matching_column_pairs.vb
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: locate_bottom_spdsht.bas
'
'      Summary: Generic function determines the bottom row (digits) of an
'               open spreadsheet.
'
'      Created: Thu Dec 17 1998 16:09:42 (Bob Heckel)
'     Modified: Tue Jan 12 1999 10:19:09 (Bob Heckel--make sure row A is
'                                         really the bottom by checking
'                                         rows B to IV)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function BottomRow() As Integer
   On Error GoTo TMP
  'Initialized to 0 so if empty spdsht, will return a valid zero
  Range("IV1").Select
  Selection.End(xlDown).Select
  Selection.End(xlToLeft).Select
  Selection.End(xlUp).Select
  ActiveCell.Offset(1, 0).Select

  'Make sure row A is not misrepresentative by checking Cols B thru IV.
  Do Until ActiveCell.Value <> "" Or ActiveCell.Column = 256
    ActiveCell.Offset(0, 1).Select
  Loop
  'Move up one to the last row containing data if the row is really empty.  
  'If Col B, C, etc. has it, ok as is.
  If ActiveCell.Column = 256 Then
    ActiveCell.Offset(-1, 0).Select
    BottomRow = ActiveCell.Row
  Else
    'Col B, C, etc has it.
    BottomRow = ActiveCell.Row
  End If

  Range("A1").Select
  Debug.Print BottomRow
  Exit Function
TMP:
  Debug.Print Err.Description
End Function
