Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: modUtil.bas
'
' Summary: Utility procedures for tabbed configuration utility.
'          See frmMain.bas, modGlobals.bas, modErrorHandler.bas
'          Designed to be independent of the config.dat and form data.
'
' Created: Tue, 26 Sep 2000 14:11:56 (Bob Heckel -- parts adapted from Mark
'                                     Hewett's ToolManager)
' Modified: Wed, 13 Dec 2000 13:11:19 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Return an ordered array of items by opening the init file and
' reading/counting all the [section] names.
Function LoadConfigdat(filename As String) As Variant
  On Error GoTo ERRORTRAP
  Dim retBuffer As String
  Dim sectionNamesBuffer As String
  Dim bufLen As Integer
  Dim retLen As Integer
  Dim sectionarray() As String
  
  #If DEBUGFLAG Then
    Debug.Print "Loading profile from " & filename
  #End If
  ' First get [section] names.
  retBuffer = String(1024, 0)
  bufLen = 1024
  retLen = GetPrivateProfileSectionNames(retBuffer, bufLen, filename)
  sectionNamesBuffer = Left(retBuffer, retLen)

  sectionarray = Split(sectionNamesBuffer, Chr$(0))
  LoadConfigdat = sectionarray
  #If DEBUGFLAG Then
    Debug.Print "Profile Loaded Successfully.  Segment array populated."
  #End If
Exit Function
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Failure during attempt to read [segments] of " & CONFIGDAT
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "LoadConfigdat", moreinfo)
  End
End Function 'LoadConfigdat()


' Single line containing all key/value pairs for a passed section.
Function GetPairsLine(sect As Variant, configfile As String) As String
  On Error GoTo ERRORTRAP
  ' Retrieve string value of a key from a specified section of the init file.
  Dim retBuffer As String
  Dim bufLen, retLen As Integer
  
  retBuffer = String(BUFFERSZ, 0) ' Pre-extend return buffer
  bufLen = BUFFERSZ
  retLen = GetPrivateProfileSection(sect, retBuffer, bufLen, configfile)
  If ( retLen > 0 ) Then
    GetPairsLine = Left(retBuffer, retLen)
  Else
    GetPairsLine = Default
  End If
Exit Function
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Failure during attempt to parse key/value lines in " & CONFIGDAT
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "LoadConfigdat", moreinfo)
  End
End Function


' Key=Value on each line.  Actually breaking on Null strings.
Function BreakOnSpaces(keyvalstr As String)
  On Error GoTo ERRORTRAP
  Dim keyvalelems() As String
  
  keyvalelems = Split(keyvalstr, Chr$(0))
  BreakOnSpaces = keyvalelems()
Exit Function
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Failure during attempt to parse key/value lines in " & CONFIGDAT
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "BreakOnSpaces", moreinfo)
  End
End Function


' Place Key and Value on alternating lines.  (e.g. keyvalarray(2) is
' HANDLER=universal) 
Sub BreakOnEqualSign(keyvalarray, dictbreak As Dictionary)
  On Error GoTo ERRORTRAP
  Dim keyvalelems() As String
  Dim keyorval As Variant
  Dim comment As String
 
  For Each keyorval In keyvalarray
    comment = Left(keyorval, 1)
    ' Skip blanks and Perl style comments.
    If keyorval <> "" And comment <> "#" Then
      keyvalelems = Split(keyorval, "=")
      ' Hash holds all section's key/value pairs.
      dictbreak.Add keyvalelems(0), keyvalelems(1)
    End If
  Next keyorval
Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Failure during attempt to parse key/value lines in " & CONFIGDAT
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "BreakOnEqualSign", moreinfo)
  End
End Sub


Function ChangeVal(dictio As Dictionary, dictio_chg As Dictionary, _ 
                   chgkey As String, chgvalue As String) As Integer
  On Error Resume Next    ' Don't care about duplicate key errors.
  Dim oldval As String
  Dim newval As String
  
  ' Check for existence to avoid autovivification.
  ' Dictionary objects are passed by reference.
  If dictio.Exists(chgkey) Then
    oldval = dictio.Item(chgkey)
    dictio.Item(chgkey) = chgvalue
    newval = dictio.Item(chgkey)
    If oldval <> newval Then
      ' DictChangedXXX is global and is used in frmMain.
      ' If several Reverts are performed by user, this line may generate a
      ' "duplicate key" error.  Error trap ignores the error since the hash
      ' has already been created and the duplication is irrelevant.
      dictio_chg.Add chgkey, newval
      ChangeVal = 1
    Else
      ' User placed widget back to its default state.  Later we will not
      ' prompt to save changes.
      ChangeVal = 0
    End If
  End If
End Function


' Check for changes in the state of widget calling this function.
Function DiffCheck(diff As Integer)
  ' If a field has already been dirtied, don't test again.
  If DIRTY = True Then
    Exit Function
  End If

  If diff Then
    DIRTY = True
  Else
    DIRTY = False
  End If
End Function


Function FileExists(path_file As String) As Boolean
  On Error GoTo ERRORTRAP
  Dim fs As Integer

  fs = FileLen(path_file)
  ' Normal config.dat is around 2500 bytes.  If it swells too much, the
  ' BUFFERSZ will have to be increased.
  If fs > WARNSIZE Then
    MsgBox "Your config.dat size is > " & WARNSIZE & " bytes.  This may " & _ 
           "indicate a problem.  If the file gets much larger, " & _ 
           "grtweaker.exe must be adjusted and recompiled to " & _ 
           "accomodate the larger size.", _ 
           vbOKOnly, "Warning: Hard-coded buffersize: " & BUFFERSZ
  End If
  FileExists = True
  Exit Function
ERRORTRAP:
  FileExists = False
  Exit Function
End Function


' Use prefix of in-focus object variable to determine what type of control.
' Some sort of Hungarian notation is assumed.
Function DetermineObjType(objname As String) As String
  Dim whattypeobj As String

  whattypeobj = Mid(objname, 1, 3)
  DetermineObjType = whattypeobj
End Function
