''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: windows_API.bas
'
' Summary: Demo of using Windows DLLs in VB / VBA.
'
' Adapted: Wed 19 Jun 2002 12:54:23 (Bob Heckel -- Excel2000 Power Programming
'                                    VBA John Walkenbaugh)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Must be in a module (e.g. Module1).

Declare Function GetWindowsDirectoryA Lib "kernel32" _
  (ByVal lpBuffer As String, ByVal nSize As Long) _
   As Long


Sub ShowWindowsDir()
  Dim WinPath As String
  Dim WinDir As String

  WinPath = Space(255)
  WinDir = Left(WinPath, GetWindowsDirectoryA(WinPath, Len(WinPath)))
  MsgBox WinDir, vbInformation, "Windows Directory"
End Sub
