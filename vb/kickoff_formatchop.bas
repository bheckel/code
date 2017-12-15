''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: kickoff_formatchop.bas
'
'  Summary: Begin processing / prompt user for Open or Final jobs and pass 
'           that info and the NT week number to the main pgm.
'
'  Created: Created: Fri, 1 May 1998 14:50:47 (Bob Heckel)
' Modified: Thu, 27 Jan 2000 14:51:15 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit

Private Sub Workbook_Open()
  On Error GoTo WrongProcessType
  Dim SendOpFi As Byte

  ' Allow graceful exit for maintenance, etc.
  If MsgBox("Begin Macro?", vbYesNo, "FormatChop_OpFi") = vbYes Then
    SendOpFi = InputBox("Run Open--> 1 or Final--> 2?", "Choose Process Type", 1)
    If (SendOpFi < 3) Then
      Call Main(SendOpFi)
    Else
      MsgBox "Macro cancelled.  Program accepts only 1 (open) or 2 (final)."
      Exit Sub
    End If
  Else
    MsgBox "Macro can now be run only via Tools:Macro:Macros.", , "Operation Cancelled"
  End If
Exit Sub

WrongProcessType:
  ' Protect against Type Mismatch if an alpha char is keyed instead of 1 or 2.
  If Err = 13 Then MsgBox "Macro cancelled.  Program accepts only 1 (open) or 2 (final)."
End Sub

