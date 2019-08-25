''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: split_ent_dept.bas
'
'      Summary: For each cell in specified range, split entity and dept.
'               For Edward Lloyd-Evans
'
'      Created: Tue, 30 Nov 1999 13:31:52 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub splitter()
  msgbox("Be sure to adjust range in the code itself")
  For Each cell In ActiveSheet.Cells.Range("a1:a10")
    ent = Left(cell, 3)
    dept = Right(cell, 4)
    ActiveCell.Offset(0, 1).Select
    ActiveCell.Value = ent
    ActiveCell.Offset(0, 1).Select
    ActiveCell.Value = dept
    ActiveCell.Offset(1, -2).Select
  Next
End Sub

