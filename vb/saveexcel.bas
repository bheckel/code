
Function SaveExcel(f As String)
  Dim objXL As Object
    
  If f = "C:\cygwin\home\bqh0\projects\spawnspdsht\junk2.xls" Then
    Process "C:\cygwin\home\bqh0\projects\spawnspdsht\junk2.xls"
    Process "C:\cygwin\home\bqh0\projects\spawnspdsht\junk3.xls"
  Else
    Process f
  End If
        
  SaveExcel = 1
End Function

Sub Process(g As String)
  Set objXL = CreateObject("Excel.Application")
  
  With objXL.Application
   .Visible = False
   .Workbooks.Open g
  End With

  objXL.ActiveWorkbook.Save
  objXL.Application.Quit
  
  Set objXL = Nothing
End Sub

Sub foo()
  SaveExcel ("C:\cygwin\home\bqh0\projects\spawnspdsht\junk3.xls")
End Sub
