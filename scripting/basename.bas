VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: basename.bas
'
'  Summary: Extract the basename from a given fully qualified path.
'    Usage: Basename("c:\full\path\to\desired.basename")
'
'  Created: Mon Jun 14 1999 09:37:41 (Paul Lomax VB & VBA Nutshell)
' Modified: Thu 31 Jul 2008 13:42:13 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function Basename(byVal sFullPath as String) as String
  Dim lPos as Long, lStart as Long
  Dim sFilename as String

  ' Start at first char, usually c as in c:\...
  lStart = 1
  Do
    ' Move left to right, find location of \ until can't go further rightward.
    lPos = InStr(lStart, sFullPath, "\")
    If lPos = 0 Then
      sFilename = Right(sFullPath, Len(sFullPath) - lStart + 1)
    Else
      lStart = lPos + 1
    End If
  Loop While lPos > 0

  Basename = sFilename
End Function

