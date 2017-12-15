''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name:  ListSubdirs.bas
'
'      Summary:  Lists all the subdirectories beneath the given directory.
'
'      Created:  Wed Dec 23 1998 15:41:59 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub ListSubDirs(strPath As String)
  'strPath is Directory to look in.
  Dim strFile As String
  
  ' Make sure strPath is a directory.
  If Right(strPath, 1) <> "\" Then
    strPath = strPath & "\"
  End If
  If IsAttr(strPath, vbDirectory) Then
    ' Find all the files, including directories.
    strFile = Dir(strPath, vbDirectory)
    Do Until strFile = ""
     ' If the file is a directory, print it.
     If IsAttr(strPath & strFile, vbDirectory) Then
       ' Ignore "." and ".."
       If strFile <> "." And _
         strFile <> ".." Then
         Debug.Print strFile
       End If
     End If
     ' Get the next file.
     strFile = Dir
    Loop
  End If
End Sub


Function IsAttr(strFile As String, lngAttr As Long) As Boolean
  ' Determines if the attributes of the given file exactly
  ' match those specified by lngAttr.

  ' From "VBA Developer's Handbook"
  ' by Ken Getz and Mike Gilbert
  ' Copyright 1997; Sybex, Inc. All rights reserved.

  ' In:
  '   strFile
  '       Path to an existing file.
  '   lngAttr
  '       Bitmask of VBA file attribute constants.
  ' Out:
  '   Return Value:
  '       True if attributes match, False if not.
  ' Example:
  '   fMatch = IsAttr("C:\MSDOS.SYS", vbSystem + vbHidden)
  
  ' Check the attributes of the file against the
  ' specified attributes--return True if they match
  On Error Resume Next
   IsAttr = ((GetAttr(strFile) And lngAttr) = lngAttr)
End Function
