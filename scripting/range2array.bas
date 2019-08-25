''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: range2array.bas
'
' Summary: Place cell values from a specific range into an array.
'
'  Created: Mon 19 Aug 2002 11:12:00 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Range2Array()
  Dim a() As Variant
  Dim i As Integer
  Dim c As Variant
  Dim e As Variant
  
  i = 0   ' unless  Option Base 1  is set
  For Each c In Range("A1:D10")
    If c.Value <> "" Then
      ReDim Preserve a(i)
      a(i) = c.Value
      i = i + 1
    End If
  Next c

  For Each e In a
    Debug.Print e
  Next
End Sub
