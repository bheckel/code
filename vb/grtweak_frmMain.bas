
Option Explicit

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: frmMain.bas
'
' Summary: Load a tabbed configuration utility and allow edits to a
'          centralized INI-format text file.
'          See modUtils.bas, modGlobals.bas, modErrorHandler.bas
'
'          To add new elements to form:
'            1 - Add gui widget, with Name property similar to the others, Tag
'                property equal to the corresponding element in config.dat
'
'            2 - If it requires initialization (e.g. comboboxes, listboxes,
'                etc.), add an array to SetWidgetDefaults() and loop over it.
'
'            3 - Add a line to InitFromConfig() that adds the widget's element
'                to the global Dict hash (be sure to increase array size in
'                the Dim statement).
'
'            4 - Add an Event Handler -- _LostFocus() for
'                combobox/listbox/textbox, _Click() for checkbox.
'
' Created: Tue, 26 Sep 2000 14:11:56 (Bob Heckel -- parts adapted from Mark
'                                     Hewett's ToolManager)
' Modified: Fri 05 Oct 2001 15:05:30 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' main()
Private Sub Form_Load()
  #If DEBUGFLAG Then
    Debug.Print Chr(13) & "______Start_______" & Chr(13) & Time() & _
                " DEBUGFLAG is set to 1 in Project properties"
    VB.App.HelpFile = "P:\Projects\grtweak\WinHelp\GRTWEAK.HLP"
  #Else
    Debug.Print Chr(13) & "____DEBUG is off____" & Chr(13) & Time() & _
                " DEBUGFLAG is set to 0 in Project properties"
    VB.App.HelpFile = "C:\local\bin\GRTWEAK.HLP"
  #End If
  ProcessConfig
  SetWidgetDefaults
  InitFromConfig
End Sub
  

Private Sub ProcessConfig()
  On Error GoTo ERRORTRAP
  ' key/value pair line.
  Dim key_eq_val     As Variant
  ' For Each iterator.
  Dim bracket_item   As Variant
  ' Array of section names.
  Dim aSegs()        As String
  ' To create config.dat.bak
  Dim oFile          As FileSystemObject
  ' Make backup indicator.
  Dim OverwriteFiles As Boolean
 
  If FileExists(configdat) Then
    Set oFile = New FileSystemObject
    OverwriteFiles = True
    oFile.CopyFile configdat, CONFIGDATBAK, OverwriteFiles
    #If DEBUGFLAG Then
      Debug.Print "Copy of " & configdat & " made successfully."
    #End If
    ' Then load config.dat to populate defaults.  Return array of each
    ' [segment].
    aSegs = LoadConfigdat(configdat)
    For Each bracket_item In aSegs
      If bracket_item <> "" Then
        key_eq_val = BreakOnSpaces(GetPairsLine(bracket_item, configdat))
        BreakOnEqualSign key_eq_val, Dict
      End If
    Next
  Else
    Dim moreinfo As String
    moreinfo = "Make sure the file " & configdat & " exists."
    '         dummy
    Err.Raise 12345, "a missing initialization file"
    End
  End If
Exit Sub
ERRORTRAP:
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "ProcessConfig", moreinfo)
  Unload Me
  End
End Sub 'ProcessConfig()


Private Sub SetWidgetDefaults()
  On Error GoTo ERRORTRAP
  Dim i        As Integer
  Dim arrtmp     As Variant
  Dim arr_elem As Variant

  ' TAB1 -- Initialize valid combobox values for the Ports Tab widgets.
  For i = 1 To 10
    cmbBarcodePort.AddItem "COM" & i
    cmbHandlerPort.AddItem "COM" & i
    cmbQNXPort.AddItem "COM" & i
  Next
  
  arrtmp = Array("110", "150", "300", "600", "1200", "2400", "4800", "9600", "19200")
  For Each arr_elem In arrtmp
    cmbSetBarcodeBaud.AddItem arr_elem
    cmbSetHandlerBaud.AddItem arr_elem
    cmbSetQNXBaud.AddItem arr_elem
  Next
  
  arrtmp = Array("n", "e", "o", "m", "s")
  For Each arr_elem In arrtmp
    cmbSetBarcodeParity.AddItem arr_elem
    cmbSetHandlerParity.AddItem arr_elem
    cmbSetQNXParity.AddItem arr_elem
  Next

  arrtmp = Array("5", "6", "7", "8")
  For Each arr_elem In arrtmp
    cmbSetBarcodeData.AddItem arr_elem
    cmbSetHandlerData.AddItem arr_elem
    cmbSetQNXData.AddItem arr_elem
  Next

  arrtmp = Array("1", "1.5", "2")
  For Each arr_elem In arrtmp
    cmbSetBarcodeStop.AddItem arr_elem
    cmbSetHandlerStop.AddItem arr_elem
    cmbSetQNXStop.AddItem arr_elem
  Next
  
  arrtmp = Array("on", "off", "hs")
  For Each arr_elem In arrtmp
    cmbSetBarcodeDTR.AddItem arr_elem
    cmbSetHandlerDTR.AddItem arr_elem
    cmbSetQNXDTR.AddItem arr_elem
  Next
  
  arrtmp = Array("on", "off", "hs")
  For Each arr_elem In arrtmp
    cmbSetBarcodeRTS.AddItem arr_elem
    cmbSetHandlerRTS.AddItem arr_elem
    cmbSetQNXRTS.AddItem arr_elem
  Next
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' TAB2 -- Initialize valid combobox values for the BoardWatch Tab widgets.

  arrtmp = Array("always", "never", "prompt at login")
  For Each arr_elem In arrtmp
    cmbBwWant_BW.AddItem arr_elem
  Next

  arrtmp = Array("prod", "prog", "maint", "user_check")
  For Each arr_elem In arrtmp
    cmbBwMode.AddItem arr_elem
  Next

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' TAB3 -- Initialize valid combobox values for the Automation Tab widgets.

  ' These values represent the state table hashes in automation.bat (e.g.
  ' %HandlerTableAFSHiDensity).  The state table names must be changed to
  ' mirror these elements.
  '''arrtmp = Array("Standalone", "AFS_TSL", "AFS_TSLHiDensity", "Universal", "--none--")
  arrtmp = Array("Standalone", "TSL_AFS500", "TSL_AFS500L", "Universal", "--none--")
  For Each arr_elem In arrtmp
    cmbAutomHandler.AddItem arr_elem
  Next

  ' 08/30/01 QNX no longer in use at this location.  Code can be removed.  For
  ' now, the widget has been rendered invisible on frmMain.
  arrtmp = Array("always", "never", "prompt at login")
  For Each arr_elem In arrtmp
    cmbAutomQNX.AddItem arr_elem
  Next

 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 ' TAB4 -- Initialize valid combobox values for the Grsuite Tab widgets.
 ' (none)

 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 ' TAB5 -- Initialize valid listbox values for the Default Settings Tab
 ' widget.
 ' Avoid listing the orig.dats more than once.
  If DIRTY = False And SECONDPASS = False Then
    Dim origconfig As Variant
    Dim configarray() As Variant
    Dim j As Integer
    Dim array_elem As Variant

    j = 0
    ' E.g. c:\local\bin\*.orig.dat
    origconfig = Dir(LOCALBIN & ORIGDATS)  'Initialize.
  
    While origconfig > ""
      ReDim Preserve configarray(j)
      configarray(j) = origconfig
      j = j + 1
      origconfig = Dir    'Open next file in directory, if there is one.
    Wend

    For Each array_elem In configarray
      lstDefaultDAT.AddItem array_elem
    Next
  End If
Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Error occured during initialization of comboboxes.  " & _
             "config.dat has not yet been read."
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "SetWidgetDefaults", moreinfo)
  End
End Sub 'SetWidgetDefaults()


' Populate _all_ widgets with config.dat values.
' Use widget's Tag as a _key_ to find related _value_.
Private Sub InitFromConfig()
  On Error GoTo ERRORTRAP
  Dim i As Integer
  Dim elem As Variant

  ' TAB1
  ' Ultimately, this is the desired result from this Sub:
  ' cmbBarcodePort.Text = Dict.Item(cmbBarcodePort.Tag)
  ' --- Start Barcode TAB1 frame
  ' Keep Dims near Sets to avoid subscript out of range mistakes.
  Dim cmbArrBarcd(7) As ComboBox
  Dim chkArrBarcd(2) As CheckBox
  ' Each widget is contained within its related array.
  '                    -------------- Combobox widget's NAME property
  Set cmbArrBarcd(0) = cmbBarcodePort
  Set cmbArrBarcd(1) = cmbSetBarcodeBaud
  Set cmbArrBarcd(2) = cmbSetBarcodeParity
  Set cmbArrBarcd(3) = cmbSetBarcodeData
  Set cmbArrBarcd(4) = cmbSetBarcodeStop
  Set cmbArrBarcd(5) = cmbSetBarcodeDTR
  Set cmbArrBarcd(6) = cmbSetBarcodeRTS
  Set chkArrBarcd(0) = chkSetBarcodeXON
  Set chkArrBarcd(1) = chkSetBarcodeTimeout
  ' Populate TEXT property.
  For i = 0 To UBound(cmbArrBarcd) - 1
    cmbArrBarcd(i) = Dict.Item(cmbArrBarcd(i).Tag)
    If cmbArrBarcd(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      '                          __grey___
      cmbArrBarcd(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      cmbArrBarcd(i).Enabled = True
    End If
  Next
  For i = 0 To UBound(chkArrBarcd) - 1
    chkArrBarcd(i) = Dict.Item(chkArrBarcd(i).Tag)
  Next

  ' Cleanup.
  For Each elem In cmbArrBarcd
    Set elem = Nothing
  Next
  For Each elem In chkArrBarcd
    Set elem = Nothing
  Next

  ' --- Start Handler TAB1 frame
  Dim cmbArrHndl(7) As ComboBox
  Dim chkArrHndl(2) As CheckBox

  Set cmbArrHndl(0) = cmbHandlerPort
  Set cmbArrHndl(1) = cmbSetHandlerBaud
  Set cmbArrHndl(2) = cmbSetHandlerParity
  Set cmbArrHndl(3) = cmbSetHandlerData
  Set cmbArrHndl(4) = cmbSetHandlerStop
  Set cmbArrHndl(5) = cmbSetHandlerDTR
  Set cmbArrHndl(6) = cmbSetHandlerRTS
  Set chkArrHndl(0) = chkSetHandlerXON
  Set chkArrHndl(1) = chkSetHandlerTimeout
  For i = 0 To UBound(cmbArrHndl) - 1
    cmbArrHndl(i) = Dict.Item(cmbArrHndl(i).Tag)
    If cmbArrHndl(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      cmbArrHndl(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      cmbArrHndl(i).Enabled = True
    End If
  Next
  For i = 0 To UBound(chkArrHndl) - 1
    chkArrHndl(i) = Dict.Item(chkArrHndl(i).Tag)
  Next

  ' Cleanup.
  For Each elem In cmbArrHndl
    Set elem = Nothing
  Next
  ' Cleanup.
  For Each elem In chkArrHndl
    Set elem = Nothing
  Next


  ' --- Start QNX TAB1 frame
  Dim cmbArrQnx(7) As ComboBox
  Dim chkArrQnx(2) As CheckBox
  Set cmbArrQnx(0) = cmbQNXPort
  Set cmbArrQnx(1) = cmbSetQNXBaud
  Set cmbArrQnx(2) = cmbSetQNXParity
  Set cmbArrQnx(3) = cmbSetQNXData
  Set cmbArrQnx(4) = cmbSetQNXStop
  Set cmbArrQnx(5) = cmbSetQNXDTR
  Set cmbArrQnx(6) = cmbSetQNXRTS
  Set chkArrQnx(0) = chkSetQNXXON
  Set chkArrQnx(1) = chkSetQNXTimeout
  For i = 0 To UBound(cmbArrQnx) - 1
    cmbArrQnx(i) = Dict.Item(cmbArrQnx(i).Tag)
    If cmbArrQnx(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      cmbArrQnx(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      cmbArrQnx(i).Enabled = True
    End If
  Next
  For i = 0 To UBound(chkArrQnx) - 1
    chkArrQnx(i) = Dict.Item(chkArrQnx(i).Tag)
  Next

  ' Cleanup.
  For Each elem In cmbArrQnx
    Set elem = Nothing
  Next
  For Each elem In chkArrQnx
    Set elem = Nothing
  Next

  ' TAB2
  Dim cmbArrBw(2)  As ComboBox
  Dim chkArrBw(2)  As CheckBox
  Dim txtArrBw(23) As TextBox

  Set cmbArrBw(0) = cmbBwWant_BW
  Set cmbArrBw(1) = cmbBwMode
  Set chkArrBw(0) = chkBwManual
  Set chkArrBw(1) = chkBwStop
  Set txtArrBw(0) = txtBwPath
  Set txtArrBw(1) = txtBwHost
  Set txtArrBw(2) = txtBwService
  Set txtArrBw(3) = txtBwInetport
  Set txtArrBw(4) = txtBwMaxtries
  Set txtArrBw(5) = txtBwCnxtimeout
  Set txtArrBw(6) = txtBwRecvtimeout
  Set txtArrBw(7) = txtBwRouting
  Set txtArrBw(8) = txtBwRepair
  Set txtArrBw(9) = txtBwLoginbox
  Set txtArrBw(10) = txtBwOperator
  Set txtArrBw(11) = txtBwPassword
  Set txtArrBw(12) = txtBwStagename
  Set txtArrBw(13) = txtBwDebug
  Set txtArrBw(14) = txtBwSpoolfile
  Set txtArrBw(15) = txtBwLogfile
  Set txtArrBw(16) = txtBwDef_windowsize
  Set txtArrBw(17) = txtBwDef_maxerrs_wdw
  Set txtArrBw(18) = txtBwDef_maxerrs_tot
  Set txtArrBw(19) = txtBwMaxerrs_dut
  Set txtArrBw(20) = txtBwQueryresultsdir
  Set txtArrBw(21) = txtBwSystem_modal
  Set txtArrBw(22) = txtBwKillsessioncmd
  For i = 0 To UBound(cmbArrBw) - 1
    cmbArrBw(i) = Dict.Item(cmbArrBw(i).Tag)
    If cmbArrBw(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      cmbArrBw(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      cmbArrBw(i).Enabled = True
    End If
  Next
  For i = 0 To UBound(chkArrBw) - 1
    chkArrBw(i) = Dict.Item(chkArrBw(i).Tag)
  Next
  For i = 0 To UBound(txtArrBw) - 1
    txtArrBw(i) = Dict.Item(txtArrBw(i).Tag)
    If txtArrBw(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      txtArrBw(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      txtArrBw(i).Enabled = True
    End If
  Next

  ' Cleanup.
  For Each elem In cmbArrBw
    Set elem = Nothing
  Next
  For Each elem In chkArrBw
    Set elem = Nothing
  Next
  For Each elem In txtArrBw
    Set elem = Nothing
  Next

  ' TAB3
  Dim cmbArrAutom(2) As ComboBox
  Dim chkArrAutom(1) As CheckBox

  Set cmbArrAutom(0) = cmbAutomHandler
  Set cmbArrAutom(1) = cmbAutomQNX
  Set chkArrAutom(0) = chkAutomDisplay
  For i = 0 To UBound(cmbArrAutom) - 1
    cmbArrAutom(i) = Dict.Item(cmbArrAutom(i).Tag)
    If cmbArrAutom(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      cmbArrAutom(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      cmbArrAutom(i).Enabled = True
    End If
  Next
  For i = 0 To UBound(chkArrAutom) - 1
    chkArrAutom(i) = Dict.Item(chkArrAutom(i).Tag)
  Next

  ' Cleanup.
  For Each elem In cmbArrAutom
    Set elem = Nothing
  Next
  For Each elem In chkArrAutom
    Set elem = Nothing
  Next

  ' TAB4
  Dim txtArrGr(6) As TextBox

  Set txtArrGr(0) = txtGrFtp_connect_attempts
  Set txtArrGr(1) = txtGrFtp_timeout
  Set txtArrGr(2) = txtGrDefserver
  Set txtArrGr(3) = txtGrDefaccount
  Set txtArrGr(4) = txtGrTest_acct
  Set txtArrGr(5) = txtGrDefworkdir
  For i = 0 To UBound(txtArrGr) - 1
    txtArrGr(i) = Dict.Item(txtArrGr(i).Tag)
    If txtArrGr(i) = "" Then
      ' Differentiate combobox if config.dat has KEY without a VALUE.
      txtArrGr(i).BackColor = &HCCCCCC
    Else
      ' Make sure don't prevent user from editing a control.
      txtArrGr(i).Enabled = True
    End If
  Next

  ' Cleanup.
  For Each elem In txtArrGr
    Set elem = Nothing
  Next

  ' TAB5
  ' Special case Defaults tab.  No init here.

Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Error while populating the widgets based on data from " & configdat & _
             ".  Check that filesize is smaller than " & WARNSIZE & _
             " and that all unused checkboxes (e.g. SET_BXON=0) contain" & _
             " zeroes instead of blanks."
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "InitFromConfig", moreinfo)
End Sub ' InitFromConfig()


Private Sub cmdHelpBtn_Click()
  On Error GoTo ERRORTRAP
  Dim x As String

  #If DEBUGFLAG Then
    Debug.Print "Helpfile is " & VB.App.HelpFile
  #End If

  x = "winhlp32.exe " & VB.App.HelpFile
  Shell (x)
Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Error while attempting to run winhlp32.exe on " & _
             VB.App.HelpFile
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "cmdHelpBtn_Click", moreinfo)
End Sub


''''''''''''''''''
Private Sub cmdSave_LostFocus()
  ReadyAgain
End Sub

Private Sub cmdRevert_LostFocus()
  ReadyAgain
End Sub

Private Sub cmdExit_LostFocus()
  ReadyAgain
End Sub

Sub ReadyAgain()
  Dim i As Byte

  For i = 0 To tabTweak.Tabs - 1
    lblStatus(i).Caption = "Ready"
    lblStatus(i).ForeColor = &H0&        ' Black.
  Next
End Sub
''''''''''''''''''

Private Sub lblStatus_Click(Index As Integer)
  Me.Caption = "GenRad Configuration Version " & App.Major & "." & App.Minor & "." & App.Revision
End Sub

' When leaving Reset area, set buttons back to normal.
Private Sub tabTweak_Click(PreviousTab As Integer)
  cmdSave.Visible = True
  cmdRevert.Visible = True
  cmdExit.Visible = True
  lblDefaultDAT.Caption = "Select a default configuration from the list"
  cmdResetDefault.Visible = False
End Sub

' TODO use control arrays??
' Begin Event Handlers for TAB1---------
Private Sub cmbBarcodePort_LostFocus()
  Dim different As Integer
  
  ' See if some kind of change has been made.
  different = ChangeVal(Dict, DictChangedPort, cmbBarcodePort.Tag, cmbBarcodePort.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetBarcodeBaud_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetBarcodeBaud.Tag, cmbSetBarcodeBaud.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetBarcodeParity_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetBarcodeParity.Tag, cmbSetBarcodeParity.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetBarcodeData_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetBarcodeData.Tag, cmbSetBarcodeData.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetBarcodeStop_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetBarcodeStop.Tag, cmbSetBarcodeStop.Text)
  DiffCheck (different)
End Sub

Private Sub chkSetBarcodeXON_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, chkSetBarcodeXON.Tag, chkSetBarcodeXON.value)
  DiffCheck (different)
End Sub

Private Sub cmbSetBarcodeDTR_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetBarcodeDTR.Tag, cmbSetBarcodeDTR.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetBarcodeRTS_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetBarcodeRTS.Tag, cmbSetBarcodeRTS.Text)
  DiffCheck (different)
End Sub

Private Sub chkSetBarcodeTimeout_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, chkSetBarcodeTimeout.Tag, chkSetBarcodeTimeout.value)
  DiffCheck (different)
End Sub
'''''
Private Sub cmbHandlerPort_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbHandlerPort.Tag, cmbHandlerPort.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetHandlerBaud_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetHandlerBaud.Tag, cmbSetHandlerBaud.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetHandlerParity_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetHandlerParity.Tag, cmbSetHandlerParity.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetHandlerData_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetHandlerData.Tag, cmbSetHandlerData.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetHandlerStop_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetHandlerStop.Tag, cmbSetHandlerStop.Text)
  DiffCheck (different)
End Sub

Private Sub chkSetHandlerXON_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, chkSetHandlerXON.Tag, chkSetHandlerXON.value)
  DiffCheck (different)
End Sub

Private Sub cmbSetHandlerDTR_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetHandlerDTR.Tag, cmbSetHandlerDTR.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetHandlerRTS_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetHandlerRTS.Tag, cmbSetHandlerRTS.Text)
  DiffCheck (different)
End Sub

Private Sub chkSetHandlerTimeout_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, chkSetHandlerTimeout.Tag, chkSetHandlerTimeout.value)
  DiffCheck (different)
End Sub
''''
Private Sub cmbQNXPort_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbQNXPort.Tag, cmbQNXPort.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetQNXBaud_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetQNXBaud.Tag, cmbSetQNXBaud.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetQNXParity_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetQNXParity.Tag, cmbSetQNXParity.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetQNXData_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetQNXData.Tag, cmbSetQNXData.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetQNXStop_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetQNXStop.Tag, cmbSetQNXStop.Text)
  DiffCheck (different)
End Sub

Private Sub chkSetQNXXON_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, chkSetQNXXON.Tag, chkSetQNXXON.value)
  DiffCheck (different)
End Sub

Private Sub cmbSetQNXDTR_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetQNXDTR.Tag, cmbSetQNXDTR.Text)
  DiffCheck (different)
End Sub

Private Sub cmbSetQNXRTS_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, cmbSetQNXRTS.Tag, cmbSetQNXRTS.Text)
  DiffCheck (different)
End Sub

Private Sub chkSetQNXTimeout_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedPort, chkSetQNXTimeout.Tag, chkSetQNXTimeout.value)
  DiffCheck (different)
End Sub

' Begin Event Handlers for TAB2---------
Private Sub cmbBwWant_BW_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, cmbBwWant_BW.Tag, cmbBwWant_BW.Text)
  DiffCheck (different)
End Sub

Private Sub cmbBwMode_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, cmbBwMode.Tag, cmbBwMode.Text)
  DiffCheck (different)
End Sub

Private Sub chkBwManual_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, chkBwManual.Tag, chkBwManual.value)
  DiffCheck (different)
End Sub

Private Sub chkBwStop_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, chkBwStop.Tag, chkBwStop.value)
  DiffCheck (different)
End Sub
'''
Private Sub txtBwPath_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwPath.Tag, txtBwPath.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwHost_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwHost.Tag, txtBwHost.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwService_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwService.Tag, txtBwService.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwInetport_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwInetport.Tag, txtBwInetport.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwMaxtries_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwMaxtries.Tag, txtBwMaxtries.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwCnxtimeout_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwCnxtimeout.Tag, txtBwCnxtimeout.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwRecvtimeout_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwRecvtimeout.Tag, txtBwRecvtimeout.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwRouting_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwRouting.Tag, txtBwRouting.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwRepair_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwRepair.Tag, txtBwRepair.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwLoginbox_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwLoginbox.Tag, txtBwLoginbox.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwOperator_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwOperator.Tag, txtBwOperator.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwPassword_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwPassword.Tag, txtBwPassword.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwStagename_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwStagename.Tag, txtBwStagename.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwDebug_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwDebug.Tag, txtBwDebug.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwSpoolfile_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwSpoolfile.Tag, txtBwSpoolfile.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwLogfile_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwLogfile.Tag, txtBwLogfile.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwDef_windowsize_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwDef_windowsize.Tag, txtBwDef_windowsize.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwDef_maxerrs_wdw_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwDef_maxerrs_wdw.Tag, txtBwDef_maxerrs_wdw.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwDef_maxerrs_tot_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwDef_maxerrs_tot.Tag, txtBwDef_maxerrs_tot.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwMaxerrs_dut_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwMaxerrs_dut.Tag, txtBwMaxerrs_dut.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwQueryresultsdir_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwQueryresultsdir.Tag, txtBwQueryresultsdir.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwSystem_modal_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwSystem_modal.Tag, txtBwSystem_modal.Text)
  DiffCheck (different)
End Sub

Private Sub txtBwKillsessioncmd_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedBw, txtBwKillsessioncmd.Tag, txtBwKillsessioncmd.Text)
  DiffCheck (different)
End Sub

' Begin Event Handlers for TAB3---------
Private Sub cmbAutomHandler_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedAutom, cmbAutomHandler.Tag, cmbAutomHandler.Text)
  DiffCheck (different)
End Sub

Private Sub cmbAutomQnx_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedAutom, cmbAutomQNX.Tag, cmbAutomQNX.Text)
  DiffCheck (different)
End Sub

Private Sub chkAutomDisplay_Click()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedAutom, chkAutomDisplay.Tag, chkAutomDisplay.value)
  DiffCheck (different)
End Sub

' Begin Event Handlers for TAB4---------
Private Sub txtGrFtp_connect_attempts_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedGrsuite, txtGrFtp_connect_attempts.Tag, txtGrFtp_connect_attempts.Text)
  DiffCheck (different)
End Sub

Private Sub txtGrFtp_timeout_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedGrsuite, txtGrFtp_timeout.Tag, txtGrFtp_timeout.Text)
  DiffCheck (different)
End Sub

Private Sub txtGrDefserver_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedGrsuite, txtGrDefserver.Tag, txtGrDefserver.Text)
  DiffCheck (different)
End Sub

Private Sub txtGrDefaccount_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedGrsuite, txtGrDefaccount.Tag, txtGrDefaccount.Text)
  DiffCheck (different)
End Sub

Private Sub txtGrTest_acct_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedGrsuite, txtGrTest_acct.Tag, txtGrTest_acct.Text)
  DiffCheck (different)
End Sub

Private Sub txtGrDefworkdir_LostFocus()
  Dim different As Integer
  
  different = ChangeVal(Dict, DictChangedGrsuite, txtGrDefworkdir.Tag, txtGrDefworkdir.Text)
  DiffCheck (different)
End Sub

' Begin Event Handler for TAB5---------
' Get a description of the config file of interest by reading ABSTRACT from
' that "orig" config file.
Private Sub lstDefaultDAT_Click()
  Dim configdat As String
  Dim fullconfigdat As String
  Dim bracket_item As String
  Dim key_eq_val As Variant

  ' Workaround -- buttons persist across tabs but don't want these choices for
  ' this tab.
  cmdSave.Visible = False
  cmdRevert.Visible = False
  cmdExit.Visible = False
  cmdResetDefault.Visible = True

  configdat = ""
  bracket_item = ""
  key_eq_val = ""
  ' User clicks on one item in dynamic list of config templates.
  configdat = lstDefaultDAT.Text
  LoadConfigdat (configdat)
  fullconfigdat = CONFIGDIR & configdat
  key_eq_val = BreakOnSpaces(GetPairsLine("default", fullconfigdat))
  BreakOnEqualSign key_eq_val, tmp_dict
  ' ABSTRACT should be the only key/value pair in [default]
  lblDefaultDAT.Caption = tmp_dict.Item("ABSTRACT")
  cmdResetDefault.Caption = "Reset to Original " & "(" & configdat & ")"
  ' Ready for next click.
  tmp_dict.RemoveAll
End Sub
  

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' These buttons persist across all tabs:
'
' Write changes to config.dat for each of the tabs where an item has been
' made dirty by the user.
Private Sub cmdSave_Click()
  On Error GoTo ERRORTRAP
  Dim successwrite      As Boolean  ' Did WritePrivateProfileString work.
  Dim value             As String   ' Hold Dictionary element.
  Dim dictionary_key    As Variant  ' User has changed these keys.
  Dim strDictionary_key As String   ' Can't "For Each" a String in VB.
  Dim i                 As Integer
  
  ' Iterate over changed widget values.  DictChangedPort holds all changes not
  ' yet saved.  Do this for each tab's hash.
  ' TAB1
  For Each dictionary_key In DictChangedPort.Keys
    strDictionary_key = dictionary_key
    value = Dict.Item(strDictionary_key)
    successwrite = WritePrivateProfileString(TAB1, strDictionary_key, _
                                             value, configdat)
  Next

  ' TAB2
  For Each dictionary_key In DictChangedBw.Keys
    strDictionary_key = dictionary_key
    value = Dict.Item(strDictionary_key)
    successwrite = WritePrivateProfileString(TAB2, strDictionary_key, _
                                             value, configdat)
  Next

  ' TAB3
  For Each dictionary_key In DictChangedAutom.Keys
    strDictionary_key = dictionary_key
    value = Dict.Item(strDictionary_key)
    successwrite = WritePrivateProfileString(TAB3, strDictionary_key, _
                                             value, configdat)
  Next
  
  ' TAB4
  For Each dictionary_key In DictChangedGrsuite.Keys
    strDictionary_key = dictionary_key
    value = Dict.Item(strDictionary_key)
    successwrite = WritePrivateProfileString(TAB4, strDictionary_key, _
                                             value, configdat)
  Next
  
  If successwrite Then
    For i = 0 To tabTweak.Tabs - 1
      lblStatus(i).Caption = "Changes have been saved to " & configdat
      ' Warning: VB starts with the least significant bit so it's BGR.
      lblStatus(i).ForeColor = &H339900    ' Green.
    Next

    ' Reset change indicator.
    DIRTY = False
  Else
    If DIRTY Then
      MsgBox "Error saving to " & configdat, vbCritical, "Critical Save Error"
    Else
      For i = 0 To tabTweak.Tabs - 1
        lblStatus(i).Caption = "No changes have been made to " & configdat & _
                               ".  Nothing to save."
        lblStatus(i).ForeColor = &HFF&       ' Dark red.
      Next
    End If
  End If
  Exit Sub

  Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Error during attempt to save to config.dat"
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "cmdSave_Click", moreinfo)
End Sub 'cmdSave_Click()


' Using the previously saved version of config.dat, restore values to widgets.
Private Sub cmdRevert_Click()
  On Error GoTo ERRORTRAP
  Dim i As Integer

  ' If user clicks Revert before doing anything.
  If Not DIRTY Then
    For i = 0 To tabTweak.Tabs - 1
      lblStatus(i).Caption = "Can't revert.  No changes have been made."
      lblStatus(i).ForeColor = &HFF&
    Next
  Else
    ' Avoid duplicate key errors.
    Dict.RemoveAll
    ProcessConfig
    InitFromConfig
    ' Reset change indicator.
    DIRTY = False
    ' Reload values stored in config.dat
    For i = 0 To tabTweak.Tabs - 1
      lblStatus(i).Caption = "Changes since last save have been abandoned."
      lblStatus(i).ForeColor = &H339900
    Next
  End If
  Exit Sub
ERRORTRAP:
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "cmdRevert_Click")
End Sub


Private Sub cmdExit_Click()
  On Error GoTo ERRORTRAP
  
  Unload Me
Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Unexpected error while exiting.  Please make sure " & _
              configdat & " contains your changes to the data."
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "cmdExit_Click", moreinfo)
End Sub 'cmdExit_Click()


' Check for unsaved data in the cell the user's cursor is in (it will not have
' LostFocus as a "normal" change would if the Exit button is clicked to exit.
Function Xdetect(promptuser As Boolean) As Boolean
  On Error GoTo ERRORTRAP
  Dim save_or_not As Integer

  If DIRTY Then
    save_or_not = MsgBox("Would you like to save before exiting?", _
                         259, "Save Changes?")
    If save_or_not = vbYes Then
      Call cmdSave_Click
    ElseIf save_or_not = vbNo Then
      End
    End If
  End If

  ' Check for changes in the cell with focus.  Compare with what is in
  ' config.dat.  Beat changes into submission.
  If Not Me.ActiveControl = Dict.Item(Me.ActiveControl.Tag) Then
    ' Don't contaminate the test with the 3 buttons at bottom.
    If Not Me.ActiveControl.Name = "cmdExit" Then
      #If DEBUGFLAG Then
        Debug.Print "!!!User clicked the x without saving " & _
                    "this dirty control: " & Me.ActiveControl.Name
        Debug.Print "Cursor is in ctrl with this value: " & Chr(13) & _
                    "     " & Me.ActiveControl
        Debug.Print "Dict.Item(Me.ActiveControl.Tag) contains this value: " & _
                    Chr(13) & "     " & Dict.Item(Me.ActiveControl.Tag)
      #End If
      If promptuser = True Then
        save_or_not = MsgBox("Would you like to save before exiting?", _
                             259, "Save Changes?")
      End If
      If save_or_not = vbYes Then
        Dim written As Boolean
        Dim widgettowrite As String
        ' Different write treatment depending on textbox or checkbox.
        If DetermineObjType(CStr(Me.ActiveControl.Name)) = "chk" Then
          widgettowrite = CStr(Me.ActiveControl.value)
        Else
          ' It's a cmbFoo or a txtFoo so the Text property is available.
          widgettowrite = CStr(Me.ActiveControl.Text)
        End If
            
        written = WritePrivateProfileString(CStr(tabTweak.Caption), _
                                            CStr(Me.ActiveControl.Tag), _
                                            widgettowrite, _
                                            configdat _
                                            )
        ' TODO There is a remote risk that config.dat will not exist and
        ' WritePrivateProfileString will happily create a new config.dat
        ' containing only this single key/value pair (and [segment]).
        If Not written Then
          Dim moreinfo As String
          moreinfo = "Changes not saved to " & configdat
          '         dummy
          Err.Raise 67890, "a save error."
          End
        Else
          Debug.Print "Probably saved " & configdat
        End If
      ElseIf save_or_not = vbNo Then
        ' Do nothing.
      'It's vbCancel.
      Else
        ' Abort the exit.
        Xdetect = False
        Exit Function
      End If
    End If
  End If
  
  ' No changes at all.
  If Not DIRTY Then
    ' TODO fix hack.
    End
  End If
Exit Function
ERRORTRAP:
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "Xdetect")
  Unload Me
  End
End Function 'Xdetect()


Private Sub Form_QueryUnload(cancel As Integer, unloadmode As Integer)
  On Error GoTo ERRORTRAP
  Static beenhere_flag As Byte
  Dim prompt As Boolean
  Dim cancelcheck As Boolean

  ' We know other control(s) have been changed by user because at least one has
  ' LostFocus.
  If DIRTY Then
    ' Make sure user didn't bail out on changes with the x.  But don't prompt
    ' twice.
    cancelcheck = Xdetect(False)
    If cancelcheck = False Then
      ' Abort unload.
      cancel = True
    End If
  End If

 ' User focus is on control with a (possible) change.
 If Not DIRTY Then
  ' Make sure user didn't bail out on changes with the x.
  cancelcheck = Xdetect(True)
  If cancelcheck = False Then
    cancel = True
  End If
 End If

Exit Sub
ERRORTRAP:
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "Form_QueryUnload")
  Unload Me
  End
End Sub 'Form_QueryUnload()

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Only appears in Default Settings Tab.
Private Sub cmdResetDefault_Click()
  On Error GoTo ERRORTRAP
  Dim y_or_n As Integer
  Dim origfile As String
  Dim oFile As FileSystemObject
  Dim OverwriteFiles As Boolean

  y_or_n = MsgBox("Are you sure that you want to reset this machine's " & _
                  "configuration to these default settings?", _
                  vbYesNo, "Apply Default Settings?")
  If y_or_n = vbYes Then
    origfile = CONFIGDIR & lstDefaultDAT.Text
    If FileExists(origfile) And FileExists(configdat) Then
      OverwriteFiles = True
      Set oFile = New FileSystemObject
      ' Make backup just in case.
      oFile.CopyFile configdat, CONFIGDATBAK, OverwriteFiles
      ' Overwrite e.g. config.dat with configSA83.orig.dat
      oFile.CopyFile origfile, configdat, OverwriteFiles
      Set Dict = Nothing
      Set DictChangedPort = Nothing
      Set DictChangedBw = Nothing
      Set DictChangedAutom = Nothing
      Set DictChangedGrsuite = Nothing
      SECONDPASS = True
      ProcessConfig
      InitFromConfig
      MsgBox "Restored successfully", , "Success"
    Else
      MsgBox "Can't locate " & configdat & " or " & origfile & _
             ".  Please check" & CONFIGDIR, vbCritical
    End If
  Else
    MsgBox "No changes were made.", , "Cancelled"
  End If

  cmdSave.Visible = True
  cmdRevert.Visible = True
  cmdExit.Visible = True
  lblDefaultDAT.Caption = "Select a default configuration from the list"
  cmdResetDefault.Visible = False
Exit Sub
ERRORTRAP:
  Dim moreinfo As String
  moreinfo = "Unexpected error while reverting.  Please make sure " & _
              configdat & " contains your changes to the data."
  Call Entropy(Err.Number, Err.Source, Err.Description, Err.HelpFile, _
               Err.HelpContext, "cmdExit_Click", moreinfo)
End Sub 'cmdResetDefault_Click()



