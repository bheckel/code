''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: chgpct_traverse_dir.bas
'
'  Summary: Iterate over all spreadsheets in a single directory.
'
'  Created: Thu 11 Jul 2002 09:26:52 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub ChgPct()
  'Assumes starting cell is A1.
  Dim iWhereami As Integer
  Dim iTopCell As Integer
  Dim iBotCell As Integer
  Dim sFile As String
  Const sPath = "C:\Final\"
   
  sFile = Dir(sPath & "*.XLS")  'Initialize.
  
  While sFile > ""
    Workbooks.Open FileName:=sPath & sFile

    Range("V5").Select
    Selection.End(xlDown).Select
    iBotCell = ActiveCell.Row   'Capture R C:R_C.
    Selection.End(xlUp).Select
    iTopCell = ActiveCell.Row
  
    Range("V5").Select
    iWhereami = ActiveCell.Row    'Initialize.
    While iWhereami <= iBotCell
      ActiveCell.FormulaR1C1 = "=+RC[-1]/RC[-3]"
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend
      
    Range("CH5").Select
    iWhereami = ActiveCell.Row
      While iWhereami <= iBotCell
      ActiveCell.FormulaR1C1 = "=+RC[-1]/RC[-3]"
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend
  
    Range("A1").Select
  
    ActiveWorkbook.Save
    '''ActiveWorkbook.SaveAs FileFormat:=xlExcel5
    ActiveWorkbook.Close
  
    sFile = Dir    ' open next file in directory, if there is one.
  Wend
End Sub
