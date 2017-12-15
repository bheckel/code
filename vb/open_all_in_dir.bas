'VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: open_all_in_dir.bas
'
'      Summary: Open each spreadsheets in directory. For Matt Lane.
'               This does not recurse directories.
'               See loopdirs_betterversion.bas for a recursive dir approach.
'
'      Created: Fri, 10 Sep 1999 12:25:42 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Openthem()
  Dim sEachFile As String
  Dim sMypath

  sMypath = InputBox("Enter Path with trailing slash.")
  sEachFile = Dir(sMypath & "*.XLS")  'Initialize.
  
 While sEachFile > ""
    Workbooks.Open FileName:=sMypath & sEachFile
    sEachFile = Dir    'Open next file in directory, if there is one.
 Wend
End Sub

