Option Compare Database
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: import_spd_to_access.bas
'
'      Summary: Takes spreadsheet, turns it to text so that Import
'               Specification will work, then pulls it into an Access table.
'
'      Created: Wed Feb 17 1999 15:59:41 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function basImportSpdsht()
  On Error GoTo mcrImportSpdsht_Err
  
  Dim sFile As String
  
  sFile = "c:\home\bh1\rsh\jc_using_access\combine5.xls"
  
  MsgBox "Now importing " & sFile
  'Turn xls into txt.
  '''Open "c:\misc\jc_using_access\combine5.xls"
  '''ActiveWorkbook.SaveAs "c:\misc\jc_using_access\combine5.xls.txt, FileFormat:=xlText"
  '''workbooks.Close
  Dim xlApp As Object ' Declare variable to hold the reference.
    
  Set xlApp = CreateObject("excel.application")
  xlApp.Visible = True
  ' Use xlApp to access Microsoft Excel's other objects.
  xlApp.workbooks.Open sFile
  xlApp.activeworkbook.saveas Filename= sFile, FileFormat:=xlText
  xlApp.Quit          'Use the Quit method to close
  Set xlApp = Nothing 'the application, then release the reference.

  'Pull in the textfile beast.
  DoCmd.TransferText acImport, "combine5 Import Specification", "combine5", _
                     sFile, True, ""
      
     MsgBox "Succesful Import of combine5.txt"

mcrImportSpdsht_Exit:
  Exit Function

mcrImportSpdsht_Err:
  MsgBox Error$
  Resume mcrImportSpdsht_Exit

End Function
