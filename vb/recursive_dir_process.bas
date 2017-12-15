''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: recursive_dir_process.bas
'
'  Summary: Given a top-level directory, descend into all subdirectories,
'           capturing fully qualified filenames.  For Heather.
'
'  Created: Mon 11 Aug 2003 12:48:29 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

' Globals
Dim IFILE As Integer
Dim AFILES() As String

Sub Iterate()
  Dim i As Integer

  GetFilenamesRecursively("C:\tmp\diffdir\")

 ' Process those files.
  For i = 1 to UBound(AFILES)
    ' If the file is an Excel spreadsheet.  TODO this may harbor a bug
    If Right(AFILES(i), 3) = "xls" Then
      Debug.Print "file: " & AFILES(i)
      '''Workbooks.Open Filename:=AFILES(i)
      '''Call Sort
      '''Call ChangeIt
      '''ActiveWorkbook.Save
      '''ActiveWorkbook.Close
   End If
  Next
End Sub
  

Sub GetFilenamesRecursively(sMyDir As String)
  Dim aDirs() As String
  Dim iDir As Integer
  Dim sFile As String
  
  ' Use Dir function to find files and directories in sMyDir look for
  ' directories and build a separate array of them note that Dir returns files
  ' as well as directories when vbDirectory specified.
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
      IFILE = IFILE + 1
      ReDim Preserve AFILES(IFILE)
      AFILES(IFILE) = sFile
    End If
    sFile = sMyDir & Dir()
  Loop
    
  ' Now, for any directories in aDirs, call self recursively.
  If iDir > 0 Then
    For iDir = 1 To UBound(aDirs)
      GetFilenamesRecursively aDirs(iDir) & Application.PathSeparator
    Next iDir
  End If
End Sub
