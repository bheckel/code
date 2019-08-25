''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: pastevals.bas
'
' Summary: For each xls in specified directory, remove the formulas and paste
'          values.  Originally designed to prevent large xls crashes due to
'          spdsht links.  Also process hidden sheets, if any.
'
' Created: Mon Mar 01 1999 14:04:20 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub PasteVals()
  Dim sDirectory As String
  Dim sWherenow as String
  Dim sSpec As String
  Dim sBook As String
  Dim oBook As Workbook
  Dim oSheet As Worksheet

  sWherenow = InputBox("Please enter full path of spreadsheet(s) to be modified.", "Caution -- Macro Beginning", "C:\")
  If sWherenow = "C:\" Then
    MsgBox "Must enter path."
    Exit Sub
  Else
    Application.ScreenUpdating = False
    sDirectory = sWherenow
    sSpec = "*.XLS"
    sBook = Dir(sDirectory & "\" & sSpec)
    Do
      Set oBook = Workbooks.Open(sDirectory & "\" & sBook)
      For Each oSheet In oBook.Worksheets
        If oSheet.Visible = False Then
          oSheet.Activate
          oSheet.Visible = True
          oSheet.Cells.Copy
          ' DOESN'T WORK.
          '''Selection.Copy
          '''Selection.PasteSpecial Paste:=xlValues
          oSheet.Cells.PasteSpecial Paste:=xlValues
          Range("A1").Select
          ' Return sheet to original, hidden status.
          oSheet.Visible = False
          GoTo ITSHIDN
        End If
        oSheet.Activate
        oSheet.Cells.Copy
        oSheet.Cells.PasteSpecial Paste:=xlValues
        'Leave sheet at std position.
        Range("A1").Select
  ITSHIDN:
      Application.CutCopyMode = False
      Next oSheet
                                                           
      Application.DisplayAlerts = False
      oBook.Save
      oBook.Close
      Application.DisplayAlerts = True
      sBook = Dir()
    Loop Until sBook = ""
    Application.ScreenUpdating = True
  End If
  MsgBox "Macro is finished."
End Sub

