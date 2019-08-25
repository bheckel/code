''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: Txt2Excel.bas
'
'  Summary: Open each textfile in single directory, parse into columns 
'           and save into another directory based on the filename pattern of
'           the input textfiles.
'
'           This code recurses subdirectories even though I'm only using files
'           from a single toplevel dir for now.  If subdirs eventually are
'           needed, there may be filename collisions during output into a
'           single directory.
'
'           It can be run from an automated process (e.g. BAT file) or
'           interactively by hand.  XLS files are overwritten on each run.
'
'           There is some hard-coding required so this code will complain when
'           encountering unknown data where it doesn't expect it.  It's
'           designed to fail gracefully at least.
'
'  Created: Mon Jul 08 09:10:40 2002 (Bob Heckel)
' Modified: Wed Jul 10 10:45:29 2002 (Bob Heckel -- add msgbox to alert user
'                                     of missing trailing backslash)
' Modified: Fri Jul 12 09:20:21 2002 (Bob Heckel -- filename and directory in
'                                     which to save depend on incoming
'                                     textfile name)
' Modified: Mon Jul 15 10:02:58 2002 (Bob Heckel -- insert sheet name based
'                                     on the input txtfile name)
' Modified: Thu Jul 18 09:56:25 2002 (Bob Heckel -- allow this code to be
'                                     run without human intervention)
' Modified: Mon 03 Feb 2003 08:49:52 (Bob Heckel -- change output xls names
'                                     to 4 digit years to take advantage of
'                                     new, post 8.3 server)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Base 1  ' force array indexing to coincide with the file counter

' Globals.
Dim aFiles() As String             ' hold filenames during recursion
Const INTERACT As String = "G12"   ' interactive flag cell


' This subroutine should be attached to the Button.
Sub Main()
  On Error GoTo ENTROPY
  Const INCELL As String = "A13"        ' cell holds name of input directory
  Const OUTCELL As String = "A16"       ' cell holds name of output directory
  Static iFileCnt As Integer            ' total files seen (and array indexer)
  Static iFileCntDesiredOnly As Integer ' total files processed
  Dim sPath As String                   ' user defined or use cell A13
  Dim sOutPath As String                ' user defined or use cell A16
  Dim sInputPrompt As String            ' prompt user for path
  Dim sOutputPrompt As String           ' prompt user for path
  Dim sPlural As String                 ' make MsgBox use proper English
  Dim sPluralDesired As String          ' make MsgBox use proper English

  iFileCnt = 0
  iFileCntDesiredOnly = 0

  ' Defaults.
  sPath = Range("a13").Value
  sOutPath = Range("a16").Value

  If Range(INTERACT) = "x" Then
    ' Do the inputbox prompts.
    Interactive sPath, sOutPath, INCELL, OUTCELL
  End If

  ' Avoid weird behavior if user keys a bad path AND doesn't include backslash.
  If (Right(sPath, 1) <> "\") Or (Right(sOutPath, 1) <> "\") Then
    ' VB error "File not found (Error 53)"
    Err.Raise 53
  End If

  ' TODO use Windows file browser widget to select directory
  ' Convenience feature for the next run.
  Range(INCELL).Value = sPath
  Range(OUTCELL).Value = sOutPath
  '''Debug.Print "(sPath)get text: " & sPath
  '''Debug.Print "(sOutPath)save xls: " & sOutPath

  ' Open, parse, save as spreadsheets in the proper places.
  OperateOnFilesInDir sPath, iFileCnt, iFileCntDesiredOnly, sOutPath

  If Range(INTERACT) = "x" Then
    sPlural = IIf((iFileCnt > 1), "s" & Chr(32), Chr(32))
    sPluralDesired = IIf((iFileCntDesiredOnly > 1), "s" & Chr(32), Chr(32))
    MsgBox "Finished.  Found " & _
           iFileCnt & _
           " file" & _
           sPlural & _
           "in " & _
           sPath & _
           " and its subdirectories (if any)." & _
           Chr(13) & Chr(10) & _
           Chr(13) & Chr(10) & _
           "Opened, parsed, saved as spreadsheet and closed " & _
           iFileCntDesiredOnly & _
           " non .SD7 file" & _
           sPluralDesired & _
           "successfully."
  End If

  If Range(INTERACT) <> "x" Then
    Application.DisplayAlerts = False   ' don't ask to save me
    Excel.Application.Quit
  End If
Exit Sub
ENTROPY:
  Application.DisplayAlerts = True   ' just in case.
  Application.ScreenUpdating = True  ' just in case.
  If Err.Number = 53 Then
     MsgBox "You may be missing a trailing backslash.  Or your " & _
             "path does not exist.  Exiting.", vbCritical, "Backslash Error"
  ElseIf Err.Number = 66 Then
     MsgBox "Cannot handle this type of text input file.  " & _
            "This program needs to be modified if the filename " & _
            "specifications have changed.  Exiting.", vbCritical, _
            "Input File Error (type)"
  ElseIf Err.Number = 67 Then
    MsgBox "An input file's year is out of range (expecting years 2001+)." & _
            "  Exiting.", vbCritical, "Input File Error (year)"
  Else
    sMsg = "Error # " & Str(Err.Number) & " was generated by " _
              & Err.Source & Chr(13) & "Description: " & Err.Description
    MsgBox sMsg, , "An error has occurred in Sub Main " & _
           Erl, Err.HelpFile, Err.HelpContext
  End If
End Sub

  
' Act on all files in the directory of interest.  Calls itself recursively if
' subdirectories exist.
Sub OperateOnFilesInDir(sDir As String, iFileCnt As Integer, _
                        iFileCntDesiredOnly As Integer, _
                        Optional TopLvlsSavePath As String)
  Dim aDirs() As String     ' hold subdirs, if any
  Dim iDir As Integer       ' directory array index
  Dim sFileFQ As String     ' fully qualified path of current XLS
  Dim sSaveFQ As String     ' fully qualified path of XLS to create
  Dim sComputedFQ As String ' computed Save As name returned from Function
  
  iDir = 0   ' initialize the directory array index
  ' Use Dir() to find files and directories in sDir.  Look for directories and
  ' build an array of them.  Note that Dir() returns files as well as
  ' directories when vbDirectory is specified.
  sFileFQ = sDir & Dir(sDir & "*.*", vbDirectory)

  Do While sFileFQ <> sDir
    If Right(sFileFQ, 2) = "\." Or Right(sFileFQ, 3) = "\.." Then
      ' Do nothing - GetAttr doesn't like these pseudo directories.
    ElseIf GetAttr(sFileFQ) = vbDirectory Then
      ' Add dirname to local array of directories.
      iDir = iDir + 1
      ReDim Preserve aDirs(iDir)
      aDirs(iDir) = sFileFQ
    Else
      ' Add to global array of files.
      iFileCnt = iFileCnt + 1
      ReDim Preserve aFiles(iFileCnt)
      aFiles(iFileCnt) = sFileFQ
    End If

    sFileFQ = sDir & Dir()
    
    ' GetAttr(sFileFQ) is 32 if we are on a file, 16 (constant vbDirectory) if
    ' on a directory.
    ' This next line will crash Excel:
    '''If GetAttr(sFileFQ) <> vbDirectory Then
    If (GetAttr(sFileFQ) And vbDirectory) <> vbDirectory Then
      ' Do the text conversion on SAS output textfiles only.
      ' TODO this is a weak assumption.  how to say if has an extension, skip?
      ' Case-sensitive.
      If Not (sFileFQ Like "*.sd7") And Not (sFileFQ Like "*.SD7") Then
        '''Debug.Print "(sFileFQ)Non-SD7 text is " & sFileFQ
        ' DEBUG
        Application.ScreenUpdating = False
        sBasename = Basename(sFileFQ)
        ' DEBUG
        Application.DisplayAlerts = False    ' don't ask to save it.
        ' DEBUG
        ' sBasename must be passed by value.
        sComputedFQ = GenerateSaveAs(TopLvlsSavePath, sBasename)
        '''Debug.Print "(sComputedFQ)will be saved to: " & sComputedFQ
        Workbooks.Open Filename:=sFileFQ
        Columns("A:A").TextToColumns DataType:=xlFixedWidth
        ' Make sheetname conform to pattern.
        ActiveWorkbook.ActiveSheet.Name = GenerateSheetName(sBasename)
        ActiveWorkbook.SaveAs FileFormat:=xlNormal, Filename:=sComputedFQ
        ActiveWorkbook.Close
        Application.DisplayAlerts = True
        Application.ScreenUpdating = True
        ' TODO overcounting -- looks like it counts directories as a file
        iFileCntDesiredOnly = iFileCntDesiredOnly + 1
      End If
    End If
  Loop
    
  ' For any directories in aDirs[], call myself recursively.
  If iDir > 0 Then
    '''Debug.Print "Dropping into " & sDir & _
                                   " recursive call to OperateOnFilesInDir()"
    For iDir = 1 To UBound(aDirs)
      OperateOnFilesInDir aDirs(iDir) & Application.PathSeparator, _
                          iFileCnt, iFileCntDesiredOnly
    Next iDir
  End If
End Sub


' Strip filename portion of fully qualified path.
Function Basename(sFullPath As String) As String
  Dim lPos As Long, lStart As Long, sFilename As String

  ' Start at first char, usually the 'c' in c:\...
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


' Parse a textfile's name and return its "Save As" fully qualified filename.
' This is based on Brenda's naming conventions and the filesystem structure of
' I:\CABINETS\
Function GenerateSaveAs(sTLPath As String, ByVal sTextBasenm As String) _
                                                                  As String
  Dim sPrefix As String
  Dim sQtrN As String
  Dim sYrNN As String

  ' Determine which directory to save in.
  sPrefix = Mid(sTextBasenm, 1, 2)
  sQtrN = Mid(sTextBasenm, 3, 1)
  sYrNN = Mid(sTextBasenm, 6, 2)

  Select Case sPrefix
    Case Is = "FF"
      ' 2001 naming convention.
      If Int(sYrNN) = 1 Then
        ' E.g. Input text FF12001 becomes output QTR1F01.XLS
        GenerateSaveAs = sTLPath & "FETBYST\QTR" & sQtrN & "F" & sYrNN & ".XLS"
      ' 2002 and beyond naming convention.
      ElseIf Int(sYrNN) > 1 Then
        ' E.g. Input text FF12002 becomes output QTR1F2002.XLS
        GenerateSaveAs = sTLPath & "FETBYST\QTR" & sQtrN & "F20" & sYrNN & ".XLS"
      Else
        ' 67 is a "free" trappable error number in VB.
        Err.Raise 67
      End If

    Case Is = "MF"
      If Int(sYrNN) = 1 Then
        GenerateSaveAs = sTLPath & "MORBYST\QTR" & sQtrN & "M" & sYrNN & ".XLS"
      ElseIf Int(sYrNN) > 1 Then
        GenerateSaveAs = sTLPath & "MORBYST\QTR" & sQtrN & "M20" & sYrNN & ".XLS"
      Else
        Err.Raise 67
      End If

    Case Is = "NF"
      If Int(sYrNN) = 1 Then
        GenerateSaveAs = sTLPath & "NATBYST\QTR" & sQtrN & "N" & sYrNN & ".XLS"
      ElseIf Int(sYrNN) > 1 Then
        GenerateSaveAs = sTLPath & "NATBYST\QTR" & sQtrN & "N20" & sYrNN & ".XLS"
      Else
        Err.Raise 67
      End If

    Case Is = "SF"
      If Int(sYrNN) = 1 Then
        GenerateSaveAs = sTLPath & "MICBYST\QTR" & sQtrN & "MIC" & ".XLS"
      ElseIf Int(sYrNN) > 1 Then
        GenerateSaveAs = sTLPath & "MICBYST\Q" & sQtrN & "MIC20" & sYrNN & ".XLS"
      Else
        Err.Raise 67
      End If

    Case Is = "TF"
      If Int(sYrNN) = 1 Then
        GenerateSaveAs = sTLPath & "TRANBYST\QTR" & sQtrN & "TRAN" & ".XLS"
      ElseIf Int(sYrNN) > 1 Then
        GenerateSaveAs = sTLPath & "TRANBYST\Q" & sQtrN & "TRAN20" & sYrNN & ".XLS"
      Else
        Err.Raise 67
      End If

    Case Else
      ' 66 is a "free" trappable error number in VB.
      MsgBox "Unknown prefix: " & sPrefix, vbCritical, "Input File Error " & _
             "(type)"
      Err.Raise 66
  End Select
End Function


' Determine what name to use in ActiveSheet (the value of ActiveSheet.Name is
' used by Brenda's Excel links somehow).
Function GenerateSheetName(ByVal sTxtBasenm As String) As String
  Dim sPrefix As String
  Dim sQtrN As String
  Dim sYrNN As String

  sPrefix = Mid(sTxtBasenm, 1, 2)
  sQtrN = Mid(sTxtBasenm, 3, 1)
  sYrNN = Mid(sTxtBasenm, 6, 2)

  Select Case sPrefix
    Case Is = "FF"
      GenerateSheetName = "FET" & sQtrN & sYrNN
    Case Is = "MF"
      GenerateSheetName = "MOR" & sQtrN & sYrNN
    Case Is = "NF"
      GenerateSheetName = "NAT" & sQtrN & sYrNN
    Case Is = "SF"
      GenerateSheetName = "MIC" & sQtrN & sYrNN
    Case Is = "TF"
      GenerateSheetName = "MED" & sQtrN & sYrNN
    Case Else
      MsgBox "This file does not match the expected input patterns " & _
             "(FF, MF, NF, SF or TF prefixes): " & sTextBasenm, vbInfo
      ' I only know about the above 5 filetypes.
      ' 66 is a "free" trappable error number in VB.
      Err.Raise 66
  End Select
End Function


' Provide user prompts since we're running interactively.
Function Interactive(sPath As String, sOutPath As String, _
                     ByVal INCELL As String, ByVal OUTCELL As String)
  Dim sInputPrompt As String   ' prompt user for input files
  Dim sOutputPrompt As String  ' prompt user for output files

  sInputPrompt = "Please enter input path WITH A TRAILING BACKSLASH. "
  sPath = InputBox(sInputPrompt, Default:=Range(INCELL).Value)
  If sPath = "" Then
    MsgBox "Operation cancelled by user.  Exiting."
    Exit Function
  End If

  sOutputPrompt = "Please enter output path WITH A TRAILING BACKSLASH. " & _
                  Chr(13) & Chr(10) & Chr(13) & Chr(10) & "Click OK to " & _
                  "start parsing and saving text files as Excel workbooks."
  sOutPath = InputBox(sOutputPrompt, Default:=Range(OUTCELL).Value)
  If sOutPath = "" Then
    MsgBox "Operation cancelled by user.  Exiting."
    Exit Function
  End If
End Function


' This spreadsheet/macro will be used in two ways:
' 1.  By a user opening the .xls by hand, clicking the Go button and
'     entering paths into the inputboxes.
' 2.  By a batch file where no human intervention is desired.
Private Sub Workbook_Open()
  If Range(INTERACT).Value <> "x" Then
    Call Main
  End If
End Sub
