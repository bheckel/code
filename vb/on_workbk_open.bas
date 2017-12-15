' Should go in MS Excel Objects ThisWorkbook, not in Module1

Private Sub Workbook_Open()
  Dim iGo As Integer
  
  'Allow graceful exit for maintenance, etc.
  iGo = MsgBox("Begin Macro?", vbYesNo, "CombineRgnIndep")
  If iGo = vbYes Then
    Call MAIN
  Else
    MsgBox "Operation Cancelled. Macro can be run only via Tools:Macro:Macros."
  End If
End Sub



' Other approach:

Private Sub Workbook_Open()
  Dim iGo As Integer
  Dim SendOpFi As Byte

  'Allow graceful exit for maintenance, etc.
  iGo = MsgBox("Begin Macro?", vbYesNo, "FormatChop_OpFi")
  If iGo = vbYes Then
    SendOpFi = InputBox("Run Open 1 or Final 2?", "Choose Process Type", 1)
    If SendOpFi = 1 Or 2 Then
      Call MAIN(SendOpFi)
    Else
      MsgBox "Macro cancelled."
      Exit Sub
    End If
  Else
    MsgBox "Macro can be run only via Tools:Macro:Macros.", , "Operation Cancelled"
  End If
End Sub
