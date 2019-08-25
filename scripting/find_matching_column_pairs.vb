
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: find_matching_column_pairs.vb
'
'  Summary: Compare two colums for differences and report them in a new column
'
'           TODO imitate existing header colors, fonts
'
'  Created: Fri 06 Mar 2015 13:45:00 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Sub Find_Matches()

  Dim c, rowcnt, col1, diffcnt, nodiffcnt, myrow, mycol, mycolnum, newcolhdr
  rowcnt = 0
  diffcnt = 0
  nodiffcnt = 0
  
  myrow = InputBox("which row?")
  mycol = LCase(InputBox("which col?"))
  
  ' Calculate column number from characters ASCII. E.g. o is 111 ASCII.
  mycolnum = Asc(mycol) - 103
  
  For Each c In ActiveCell.CurrentRegion.Cells
    If c.Column = mycolnum Then
      rowcnt = c.Row
    End If
  Next
  
  ' E.g. o3:o1593
  col1 = mycol & myrow & ":" & mycol & rowcnt
  
  ' Insert new col for diff text
  Columns(mycol).EntireColumn.Offset(0, 2).Insert
  Columns(mycol).EntireColumn.Offset(0, 2).ClearFormats
  
  newcolhdr = mycol & 1
  Range(newcolhdr).Offset(0, 2).Value = "Difference?"
  
  For Each c In Range(col1)
    '''Debug.Print c.Value, c.Offset(0, 1)
    If c.Value <> c.Offset(0, 1) Then
      c.Offset(0, 2).Value = "yes"
      diffcnt = diffcnt + 1
    Else
      c.Offset(0, 2).Value = "no"
      nodiffcnt = nodiffcnt + 1
    End If
  Next

Debug.Print rowcnt & " rows"
Debug.Print diffcnt & " diffs", nodiffcnt & " nodiffs"
Debug.Print nodiffcnt / diffcnt & "% diff"

End Sub

