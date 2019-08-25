
Function GetFile() As String
  dlgFile.CancelError = True
  On Error GoTo filerr
  
  dlgFile.DialogTitle = "Select da file"
  dlgFile.DefaultExt = "*.txt"
  dlgFile.Filter = "text fils (*.txt)|*.txt|all fiz (*.*) _|*.*"
  dlgFile.FilterIndex = 1
  dlgFile.MaxFileSize = 32767
  dlgFile.ShowOpen
  GetFile = dlgFile.filename
  Exit Function
filerr:
  GetFile = ""
End Function
