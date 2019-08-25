''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: loop_cells.bas
'
'  Summary: For each cell in worksheet, do something.
'
'  Created: Fri Jun 11 1999 15:41:33 (Bob Heckel)
' Modified: Wed 30 Jul 2008 14:12:06 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Demo #1:
Dim cell As Range
For Each cell In ActiveSheet.Cells.Range("a1:a10")
  If cell.Value = "del" Then
    Rows(cell.Row).Delete
  End If
Next cell


' Demo #2:
Sub LoopCells()
  For Each c In ActiveSheet.Cells.Range("a1:a10")
    If c.Value Like sLookfor Then
      sTrimmed = Trim(c.Value)
      ' Now know where to start Mid.
      iJustnums = InStr(sTrimmed, "540")
      ' E.g. 5401234 is 7 chars long.
      sCropped = Mid$(sTrimmed, iJustnums, 7)
      ' Populate the array.
      ReDim Preserve vaMyarray(i + 1)
      vaMyarray(i) = sCropped
      i = i + 1
      Debug.Print vaMyarray(i - 1)
    End If
  Next
End Sub


' Demo #3:
Sub x()
  Dim CurrCell As Range
  For Each CurrCell In Range("A1:e10")
    Debug.Print CurrCell.Address
    Debug.Print CurrCell.Value
    If CurrCell = "endme" Then
      Exit For
    End If
  Next
End Sub


' Demo #4:
Sub x()
  Dim CurrCell As Range
  For Each CurrCell In Range("b2:b15")
    ' Proper case, rightcase
    ' Alternative: :,$:s:\(.\)\(.*\):\1\L\2:gc
    CurrCell = Excel.WorksheetFunction.Proper(CurrCell)
    Debug.Print (CurrCell)
  Next
End Sub


' Demo #5:
' Best - most versatile - don't need to know specific range
' Iterate over all cells in spreadsheet, whether selected or 
' not.  Must be contiguous.  Blank row terminates CurrentRegion.
' Improves on Find with a weak regex-like search.
Sub LoopCells2()
  Dim c
  For Each c In ActiveCell.CurrentRegion.Cells
    If c.Value Like "Mac*OS" Then c.Value = "No Thanks"
  Next
End Sub


