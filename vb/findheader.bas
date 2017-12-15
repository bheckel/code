'VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: findheader.bas
'
'      Summary: Find then change its font and select a col based on its header
'               value.
'
'      Created: Wed, 01 Sep 1999 10:01:38 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Findcol()
  ' Look in header row only.
  For Each c In [A1:IV1]
    ' Case-sensitive.
    If c.Value Like "Recove*" Then
      c.Font.Name = "Times New Roman"
      bob = c.Column
      Columns(bob).Select
    End If
  Next
End Sub

