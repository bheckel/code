''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: shell.bas
'
' Summary: Demo of spawning a new process from within VBA.
'
'  Adapted: Thu 20 Jun 2002 08:56:04 (Bob Heckel -- Excel2000 Power
'                                     Programming VBA John Walkenbaugh)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub LaunchProcess
  On Error Resume Next

  WinPid = Shell("notepad", 1)

  Debug.Print Pid

  If Err <> 0 Then
    MsgBox "Can't start program."
  EndIf
End Sub
