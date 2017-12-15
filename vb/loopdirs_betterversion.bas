''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: loodirs_betterversion.bas
'
'      Summary: Determine number of files in a potentially nested directory
'               structure.  Better version than my other, earlier attempts.
'
'      Created: Tue Feb 02 1999 08:34:17 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
Option Base 1

'Should these be Public?
Dim aFiles() As String
Dim iFile As Integer

Sub ListAllFilesInDirStructure()
  iFile = 0
  'Change the top level as you wish.
  ListFilesInDir("C:\TODEL\FINISHEDVERSIONS\") 'DEBUG
  MsgBox iFile & " files found"
  'Now you can process those files.
End Sub
  
Sub ListFilesInDir(sMyDir As String)
  Dim aDirs() As String
  Dim iDir As Integer
  Dim sFile As String
  
  ' Use Dir function to find files and directories in sMyDir
  ' look for directories and build a separate array of them
  ' note that Dir returns files as well as directories when
  ' vbDirectory specified
  iDir = 0
  sFile = sMyDir & Dir(sMyDir & "*.*", vbDirectory)
  Do While sFile <> sMyDir
    If Right(sFile, 2) = "\." Or Right(sFile, 3) = "\.." Then
      ' Do nothing - GetAttr doesn't like these directories.
    ElseIf (GetAttr(sFile) And vbDirectory) = vbDirectory Then
      ' Add to local array of directories.
      iDir = iDir + 1
      ReDim Preserve aDirs(iDir)
      aDirs(iDir) = sFile
    Else
      ' Add to global array of files.
      iFile = iFile + 1
      ReDim Preserve aFiles(iFile)
      aFiles(iFile) = sFile
    End If
    sFile = sMyDir & Dir()
  Loop
    
  ' Now, for any directories in aDirs call self recursively.
  If iDir > 0 Then
    For iDir = 1 To UBound(aDirs)
      ListFilesInDir aDirs(iDir) & Application.PathSeparator
    Next iDir
  End If
End Sub
