''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: 
'
' Summary: 
'
' Adapted: Sun, 25 Feb 2001 14:08:49 (Bob Heckel -- from John Walkenbach
'                               http://www.j-walk.com/ss/excel/tips/index.htm)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function LASTINCOLUMN(rngInput As Range)
  Dim WorkRange As Range
  Dim i As Integer, CellCount As Integer

  Application.Volatile

  Set WorkRange = rngInput.Columns(1).EntireColumn
  Set WorkRange = Intersect(WorkRange.Parent.UsedRange, WorkRange)
  CellCount = WorkRange.Count
  For i = CellCount To 1 Step -1
      If Not IsEmpty(WorkRange(i)) Then
          LASTINCOLUMN = WorkRange(i).Value
          Exit Function
      End If
  Next i
End Function
