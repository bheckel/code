''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: dload.bas
'
'      Summary: Kickoff predefined .BAT FTP to retrieve textfiles.
'
'      Created: Thu Feb 25 1999 08:42:37 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Downloadtxt()
  Dim bResponse As Byte
  Dim bMsgboxstyle As Byte
  Dim vRetVal As Variant

  MsgBox "Beginning textfile download from 47.228.44.108" & (Chr(13) & Chr(10)) & "Please wait for file download to complete before pressing Yes at the next prompt.", vbInformation
  Application.StatusBar = "Now downloading Open Jobs texfiles..."
  ChDir ("c:\shared\chops\")
  vRetVal = Shell("c:\shared\chops\op_dl1.bat", 1)
  bMsgboxstyle = vbQuestion + vbYesNo
  bResponse = MsgBox("Has download completed?", bMsgboxstyle)
  'Error free run completed.
  If bResponse = vbYes And vRetVal <> 0 Then
    Application.StatusBar = False
    Exit Sub
  Else
    'Do nothing and hope they don't ok this one prematurely as well.
    MsgBox "Please wait until files have been downloaded."
  End If
  Application.StatusBar = False
End Sub
