''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: file_exists.bas 
'
' Summary: Does a single file exist?
'
' Adapted: Sun, 25 Feb 2001 14:08:49 (Bob Heckel -- from John Walkenbach
'                               http://www.j-walk.com/ss/excel/tips/index.htm)
' Modified: Wed 13 Aug 2003 12:33:35 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Unused.
Private Function FileExists(fname) As Boolean
  Dim x As String

  x = Dir(fname)
  If x <> "" Then 
    FileExists = True 
  Else 
    FileExists = False
  End If
End Function


' Better
Function FileExists2(sFile as String) as Boolean
  'If exists, Dir returns basename so length of sFile will be > 0.
  FileExists2 = (Len(Dir(sFile)) > 0)
End Function


Sub Main()
  Dim f As String
  Dim fexist As Boolean
  
  f = Environ("TMP") & "\junk.txt"
  fexist = FileExists2(f)
  MsgBox ("File exists: " & fexist)
End Sub
