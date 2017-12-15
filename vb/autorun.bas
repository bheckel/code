' This sub forces an auto-run auto run as soon as the .xls that this is
' embedded into is opened.

Const INTERACTIVE As String = "y"

Private Sub Workbook_Open()
  If  INTERACTIVE <> "y" Then
    Call Main
  End If
End Sub
