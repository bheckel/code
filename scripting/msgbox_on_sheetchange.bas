''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: msgbox_on_sheetchange.bas
'
'  Summary: Popup a message box when user enters Sheet2
'
'  Created: Mon 19 Aug 2002 13:28:31 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub WarnUser()
  MsgBox "mini-me"
End Sub

Private Sub Workbook_SheetActivate(ByVal Sh As Object)
  If ActiveSheet.Name = "Sheet2" Then
    Debug.Print "in sheet2"
    WarnUser
  End If
End Sub
