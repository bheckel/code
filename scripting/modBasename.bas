Attribute VB_Name = "modBasename"
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: basename.bas
'
'      Summary: Extract the basename from a given fully qualified path.
'
'      Created: Mon Jun 14 1999 09:30:40 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function Basename(sFullPath As String) As String
  Dim lPos As Long, lStart As Long
  Dim sFilename As String

  lStart = 1
  Do
    lPos = InStr(lStart, sFullPath, "\")
    If lPos = 0 Then
      sFilename = Right(sFullPath, Len(sFullPath) - lStart + 1)
    Else
      lStart = lPos + 1
    End If
  Loop While lPos > 0

  Basename = sFilename
End Function
