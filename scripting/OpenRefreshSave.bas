''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: OpenRefreshSave.bas
'
'  Summary: Open each spreadsheet in a user-specified directory
'           in order to refresh the Excel and HTML cell links.
'
'  Created: Tue May 21 15:28:47 2002 (Bob Heckel)
' Modified: Tue Jun 11 13:53:37 2002 (Bob Heckel -- include *.htm *.HTM as
'                                     well as .xls and .XLS)
' Modified: 06/17/2002 04:32:53 (Bob Heckel -- ignore a specific directory)
' Modified: Wed Jun 19 16:14:29 2002 (Bob Heckel -- added debugging info)
' Modified: Wed Jul 10 11:05:17 2002 (Bob Heckel -- add more debugging info)
' Modified: Thu Jul 18 09:56:25 2002 (Bob Heckel -- allow this code to be
'                                     run without human intervention)
' Modified: Wed 14 Aug 2002 12:28:28 (Bob Heckel -- add specific files to
'                                     be processed instead of just directories
'                                     to be traversed)
' Modified: Mon 19 Aug 2002 09:39:50 (Bob Heckel -- fix counter bug, improve
'                                     hard-coded file selection interface)
' Modified: Wed 04 Dec 2002 11:11:21 (Bob Heckel -- add excluded FILE list,
'                                     improve error handling, elminate
'                                     trailing slash requirements, write a
'                                     logfile to determine where hanging,
'                                     redesign interface)
' Modified: Fri 09 Jan 2004 17:43:54 (Bob Heckel -- change constant
'                                     'vbDirectory' to literal 48 to
'                                     accomodate an unknown/unannounced
'                                     change to the NCHS Windows network
'                                     directories.  This problem prevented
'                                     recursion of directories from occurring)
' Modified: Wed 28 Jan 2004 14:11:40 (Bob Heckel -- NCHS network is using
'                                     vbDirectory, i.e. 16, properly again)
' Modified: Thu 12 Feb 2004 15:15:19 (Bob Heckel -- fix "not found" bug where
'                                     a directory has no files)
' Modified: Tue 03 Aug 2004 09:45:01 (Bob Heckel -- fix "please create" bug
'                                     where directory has no files)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
Option Base 1   ' force array indexing to align with the file counter

' Globals.
Const INTERACT As String = "J8"          ' interactive flag cell
Const INCELL As String = "E12"           ' toplevel dir path
Const IGNORECELLS As String = "I15:I33"  ' ignore these dirs
Const SPECIFICS As String = "A15:A33"    ' also do these files
Const LOGDIR As String = "c:\temp\"
Const LOGFILE As String = "openrefreshsave.log.txt"
Const LCASEX As String = "x"             ' user-supplied flag
Const UCASEX As String = "X"             ' alternate user-supplied flag
Dim aFILES() As String                   ' hold filenames during recursion
Dim aFTYPES As Variant                   ' hold desired filetypes
Dim iFNUM As Integer                     ' win freefile number


' This subroutine should be attached to The Button.
Sub Main()
  On Error GoTo ENTROPY
  Static iFileCnt As Integer            ' total files seen (and array indexer)
  Static iFileCntXLSHTMOnly As Integer  ' total files processed
  Dim sPath As String                   ' user defined or use cell A12
  Dim sInputPrompt As String            ' prompt user for path
  Dim sPlural As String                 ' make MsgBox use proper English
  Dim sPluralXLSHTM As String           ' make MsgBox use proper English
  Dim sIgnored As String                ' dir to skip based on cell A14
  Dim iSpecificFiles As Integer         ' total specific files seen
  Dim rngIgcells As Range               ' paths to ignore
  Dim sInteractiveCkbox As String       ' "x" if interactivity requested
  Dim rngSpecifics As Range             ' cells holding the "other" filenames
  Dim c As Range                        ' iterator

  aFTYPES = Array(".htm", ".HTM", ".html", ".HTML", ".xls", ".XLS")

  iFileCnt = 0
  iSpecificFiles = 0
  iFileCntXLSHTMOnly = 0

  ' Default is previous run's path.
  sPath = Range(INCELL).Value
  sInteractiveCkbox = Range(INTERACT).Value
  Set rngSpecifics = Range(SPECIFICS)
  Set rngIgcells = Range(IGNORECELLS)

  If Not PathExists(LOGDIR) Then
    MsgBox LOGDIR & " does not exist.  " & _
           "Please create it before proceeding.", , "Missing Directory Error"
    Exit Sub
  End If

  iFNUM = FreeFile
  Open LOGDIR & LOGFILE For Output As #iFNUM

  If IsRunningInteract(sInteractiveCkbox) Then
    sInputPrompt = "Please enter the toplevel path." & _
                   Chr(13) & Chr(10) & "Click OK to start refreshing " & _
                   "Excel links."

    sPath = InputBox(sInputPrompt, Default:=Range(INCELL).Value)
  End If

  ' Avoid unpredictable behavior if user doesn't include a trailing backslash.
  '
  ' Need to check 2nd from right char first to make sure we're not accidently
  ' creating a string of "\" if the user empties the inputbox text and presses
  ' enter or cancel.
  sPath = TrailSlash(sPath)
  For Each c In rngIgcells
    ' Make sure the Ignore cells are not completely empty.
    If c.Value <> "" Then
      If GetAttr(c.Value) = vbDirectory Then
        c.Value = TrailSlash(c.Value)
      End If
      ' For the MsgBox.
      sIgnored = Chr(13) & Chr(10) & c & sIgnored & Chr(13) & Chr(10)
    End If
  Next

  If sPath <> "" Then
    ' Recurse the toplevel.
    OperateOnFilesInDir sPath, iFileCnt, iFileCntXLSHTMOnly, rngIgcells
    iSpecificFiles = OperateOnSpecificFiles(rngSpecifics)
  Else
    MsgBox "Operation cancelled by user.  Exiting."
    Exit Sub
  End If

  ' Include the hard-coded spreadsheets in the total count.
  iFileCnt = iFileCnt + iSpecificFiles
  iFileCntXLSHTMOnly = iFileCntXLSHTMOnly + iSpecificFiles

  ' For the MsgBox.
  sIgnored = IIf(sIgnored <> "", sIgnored, "<ignored nothing>")

  ' This is just a convenience feature for the user to avoid keystrokes
  ' during the next run.  It "corrects" the path.
  ' TODO use Windows file browser widgets to select directory
  Range(INCELL).Value = sPath

  Close #iFNUM

  If IsRunningInteract(sInteractiveCkbox) Then
    sPlural = IIf((iFileCnt > 1), "s" & Chr(32), Chr(32))
    sPluralXLSHTM = IIf((iFileCntXLSHTMOnly > 1), "s" & Chr(32), Chr(32))
    BuildMsg iFileCnt, sPlural, sPath, iSpecificFiles, iFileCntXLSHTMOnly, _
                                                    sPluralXLSHTM, sIgnored
  Else
    Application.DisplayAlerts = False   ' don't ask to save me
    Excel.Application.Quit
  End If
Exit Sub
ENTROPY:
  HandleErrors "Main()"
End Sub
 

' Determine what to pass to SaveUpdateClose().  Often recursive.
Sub OperateOnFilesInDir(sDir As String, iFileCnt As Integer, _
                        iFileCntXLSHTMOnly As Integer, rngIgcells As Range)
  On Error GoTo ENTROPY
  Dim aDirs() As String
  Dim iDir As Integer
  Dim sFileOrDir As String
  Dim c As Range
  
  iDir = 0   ' initialize the directory array index
  ' Use Dir() to find files and directories in sDir.  Look for directories and
  ' build an array of them.  Note that Dir() returns files as well as
  ' directories when vbDirectory is specified.
  sFileOrDir = sDir & Dir(sDir & "*.*", vbDirectory)
  
  Do While sFileOrDir <> sDir
    If Right(sFileOrDir, 2) = "\." Or Right(sFileOrDir, 3) = "\.." Then
      ' Do nothing - GetAttr doesn't like these pseudo directories.
    ElseIf IsToBeIgnored(sFileOrDir, rngIgcells) Then
      ' Do nothing - skipping the file (or directory) per the user.
    ElseIf GetAttr(sFileOrDir) = vbDirectory Then
      ' Add dirname to local array of directories.
      iDir = iDir + 1
      ReDim Preserve aDirs(iDir)
      aDirs(iDir) = sFileOrDir
    Else
      iFileCnt = iFileCnt + 1
      ReDim Preserve aFILES(iFileCnt)
      aFILES(iFileCnt) = sFileOrDir
    End If

    sFileOrDir = sDir & Dir()
    

    If GetAttr(sFileOrDir) <> vbDirectory Then
      ' Do the Open, Update and Save operation if we've found a file with the
      ' desired type.
      If (IsWantedType(sFileOrDir)) Then
        SaveUpdateClose sFileOrDir
        iFileCntXLSHTMOnly = iFileCntXLSHTMOnly + 1
      End If
    End If
  Loop
    
  ' For any directories in aDirs[], call myself recursively.
  If iDir > 0 Then
    Print #iFNUM, "Dropping into " & sDir & _
                                   " recursive call to OperateOnFilesInDir()"
    For iDir = 1 To UBound(aDirs)
      OperateOnFilesInDir aDirs(iDir) & Application.PathSeparator, _
                          iFileCnt, iFileCntXLSHTMOnly, rngIgcells
    Next iDir
  End If
Exit Sub
ENTROPY:
  HandleErrors "OperateOnFilesInDir()"
End Sub


' Don't want to recurse an entire directory just to do these few files.
Function OperateOnSpecificFiles(rng As Range)
  On Error GoTo ENTROPY
  Dim aFlist() As Variant
  Dim iFiles As Integer
  Dim i As Integer
  Dim c As Variant
  Dim f As Variant

  If Application.CountA(rng) = 0 Then
    ' No additional files requested by user.
    OperateOnSpecificFiles = 0
    Exit Function
  End If

  i = 1
  For Each c In rng
    If c.Value <> "" Then
      ReDim Preserve aFlist(i)
      aFlist(i) = c.Value
      i = i + 1
    End If
  Next c

  For Each f In aFlist
    SaveUpdateClose f
    iFiles = iFiles + 1
  Next

  OperateOnSpecificFiles = iFiles
Exit Function
ENTROPY:
  HandleErrors "OperateOnSpecificFiles()"
End Function


' Check path e.g. c:\temp to make sure it is not empty and if not, add a
' trailing slash.
Function TrailSlash(s As String)
  On Error GoTo ENTROPY

  If Right(s, 2) <> "" And Right(s, 1) <> "\" Then
    s = s & "\"
  End If
  TrailSlash = s
Exit Function
ENTROPY:
  HandleErrors "TrailSlash()"
End Function


' Final status report message box for interactive runs only.
Sub BuildMsg(iFileCnt As Integer, sPlural As String, sPath As String, _
             iSpecificFiles As Integer, iFileCntXLSHTMOnly As Integer, _
             sPluralXLSHTM As String, sIgnored As String)
  MsgBox "Finished.  Found " & _
         iFileCnt & _
         " file" & _
         sPlural & _
         "in " & _
         sPath & _
         " and its subdirectories." & _
         Chr(13) & Chr(10) & _
         Chr(13) & Chr(10) & _
         "This includes " & iSpecificFiles & " hard-coded files " & _
         "outside of that directory per cells " & SPECIFICS & _
         Chr(13) & Chr(10) & _
         Chr(13) & Chr(10) & _
         "Successfully opened, refreshed, saved and closed " & _
         iFileCntXLSHTMOnly & _
         " .XLS or .HTM file" & _
         sPluralXLSHTM & _
         "(including the hard-coded ones)" & _
         Chr(13) & Chr(10) & _
         Chr(13) & Chr(10) & _
         "Ignored per cells " & IGNORECELLS & ": " & sIgnored
End Sub


' The goal of this entire macro.
Sub SaveUpdateClose(fn As Variant)
  On Error GoTo ENTROPY

  Application.ScreenUpdating = False
  Application.AskToUpdateLinks = False

  Workbooks.Open Filename:=fn, updatelinks:=1

  Print #iFNUM, " ready to save... " & fn
  ActiveWorkbook.Save
  Print #iFNUM, "           SAVED: " & fn
  Print #iFNUM, "ready to close... " & fn
  ActiveWorkbook.Close
  Print #iFNUM, "          CLOSED: " & fn
  Application.AskToUpdateLinks = True
  Application.ScreenUpdating = True
  Print #iFNUM,
Exit Sub
ENTROPY:
  HandleErrors "SaveUpdateClose()"
End Sub


' User supplies an "x" if not running non-interactively (e.g. via a .BAT file).
Function IsRunningInteract(ckbx As String) As Boolean
  On Error GoTo ENTROPY

  If ckbx = LCASEX Or ckbx = UCASEX Then
    IsRunningInteract = True
  Else
    IsRunningInteract = False
  End If
Exit Function
ENTROPY:
  HandleErrors "IsRunningInteract()"
End Function


' Determine if dir or file is on the "to be skipped list".
Function IsToBeIgnored(ByVal f As String, r As Range) As Boolean
  On Error GoTo ENTROPY
  Dim c As Range
  
  If Application.CountA(r) = 0 Then
    Exit Function
  End If

  ' Required for dir comparisons below.
  If GetAttr(f) = vbDirectory Then
    f = TrailSlash(f)
  End If
  ' Skip user-specified unwanted directories:
  For Each c In r
    If c.Value = "" Then
      Exit For
    End If
    If f = c.Value Then
      Print #iFNUM, "IGNORED: " & c
      IsToBeIgnored = True
      Exit Function
    Else
      IsToBeIgnored = False
    End If
  Next
Exit Function
ENTROPY:
  HandleErrors "IsToBeIgnored()"
End Function


' Determine if we're working on an Excel spreadsheet or an HTML document.
' Case-sensitive.
Function IsWantedType(file As String) As Boolean
  On Error GoTo ENTROPY
  Dim ext As Variant

  For Each ext In aFTYPES
    ' E.g. *.htm
    If (file Like "*" & ext) Then
      IsWantedType = True
      Exit Function
    Else
      IsWantedType = False
    End If
  Next
Exit Function
ENTROPY:
  HandleErrors "IsWantedType()"
End Function


' Make sure the "specifics" and the "ignores" are valid files/dirs.
Sub ValidateFilesDirs(r As Range, title As String)
  On Error GoTo ENTROPY
  Dim c As Range

  ' If no includes or excludes provided by user.
  If Application.CountA(r) = 0 Then
    Exit Sub
  End If

  For Each c In r
    ' Stop if find blank cell which SHOULD indicate the end of the file list.
    If c = "" Then
      Exit For
    End If
    Debug.Print c.Value; " and " & Dir(c.Value)
    If Len(Dir(c.Value, vbDirectory)) = 0 Then
      MsgBox c.Value & " dir does not exist.  Continuing but may be a problem.", , title
      Exit Sub
    End If
  Next
Exit Sub
ENTROPY:
  HandleErrors "ValidateFilesDirs()"
End Sub


Sub HandleErrors(func As String)
  Dim sMsg As String

  Close #iFNUM                        ' just in case
  Application.DisplayAlerts = True    ' just in case
  Application.ScreenUpdating = True   ' just in case
  sMsg = "Error # " & Str(Err.Number) & " was generated by " _
            & Err.Source & Chr(13) & "Description: " & Err.Description
  MsgBox sMsg, , func
End Sub


Function PathExists(pname) As Boolean
  Dim x As String

  On Error Resume Next

  x = GetAttr(pname) And 0
  If Err = 0 Then 
    PathExists = True
  Else 
    PathExists = False
  End If
End Function


' This sub auto-runs; can't accept params.
'
' This spreadsheet/macro will be used in two ways:
' 1.  Via a user opening the .xls by hand, clicking the Go button and
'     optionally entering paths into the inputboxes.
' 2.  Via a .BAT file where no human intervention is desired.
Private Sub Workbook_Open()
  ' Warn user of any missing directories but keep going regardless.
  ValidateFilesDirs Range(SPECIFICS), "Failed Additional Files Validation"
  ValidateFilesDirs Range(IGNORECELLS), "Failed Ignore Files/Directories Validation"

  If Range(INTERACT).Value <> LCASEX And Range(INTERACT).Value <> UCASEX Then
    Call Main
  End If
End Sub
