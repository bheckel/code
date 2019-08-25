''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: simple_readwrite.bas
'
'  Summary: Demo of doing I/O read write operations on a file.
'
'  Created: Wed 13 Aug 2003 12:47:39 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Function FileExists(sFile As String) As Boolean
  'If exists, Dir returns filename and length of str will be > 0.
  FileExists = (Len(Dir(sFile)) > 0)
End Function


Sub Main()
  Dim f As String
  Dim fexist As Boolean
  
  ' Determine temp dir from the environment.
  f = Environ("TMP") & "\junk.txt"
  fexist = FileExists(f)
  If fexist Then
    iFNUM = FreeFile
    '''Open f For Append As #iFNUM
    Open f For Output As #iFNUM
    Print #iFNUM, "ok"
    Close #iFNUM
  End If
End Sub
