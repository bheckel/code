''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: path_exists.bas
'
' Summary: Does a path exist?
'
'          Don't use this:
'           If Not (Len(Dir("c:\temp")) > 0) Then...
'          it only works on dirs with at least one file in it
'
' Adapted: Sun, 25 Feb 2001 14:08:49 (Bob Heckel -- from John Walkenbach
'                               http://www.j-walk.com/ss/excel/tips/index.htm)
' Modified: Tue 03 Aug 2004 09:59:59 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Private Function PathExists(pname) As Boolean
  Dim x As String

  ' Keep going to return True or False, don't bomb on missing file.
  On Error Resume Next

  x = GetAttr(pname) And 0
  If Err = 0 Then 
    PathExists = True
  Else 
    PathExists = False
  End If
End Function
