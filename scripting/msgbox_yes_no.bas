''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: msgbox_yes_no.bas
'
'  Summary: Template for using MsgBox to begin a block of code.
'
'               MsgBox(prompt[, buttons] [, title] [, helpfile, context])
'
'  Created: Thu Mar 25 1999 14:25:31  (Bob Heckel)
' Modified: Fri Jul 12 14:22:13 2002 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Assumes no Option Explicit.
iGo = MsgBox("Begin Macro?", vbYesNo, "Ready?")
If iGo = vbYes Then
  SendOpFi = InputBox("Run Open 1 or Final 2?", "Choose Process Type", 1)
  If SendOpFi = 1 Or 2 Then
    Call Main(SendOpFi)
  Else
    MsgBox "Macro cancelled."
    Exit Sub
  End If
Else
  MsgBox "Macro can be run only via Tools:Macro:Macros.", , "Operation Cancelled"
End If
