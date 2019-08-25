Attribute VB_Name = "Module1"

'Summary:  Descends specified directory, opening XLS files and removing
'trailing spaces from first field (col A, usually job_id).  Eliminates the
'dswrite problem.

'Created: Wed 08/12/98 09:19:55 (Bob Heckel)


Sub FixTrailingSp()

 'Assumes starting cell is A1.
  Dim iWhereami As Integer
  Dim iTopCell As Integer
  Dim iBotCell As Integer
  Dim sFile As String
  Dim sTrimd As String
  Const sPath = "C:\todel\tmpr\"
  
  sFile = Dir(sPath & "*.XLS")  'Initialize.
  
 While sFile > ""
  
    Workbooks.Open FileName:=sPath & sFile

    Selection.End(xlDown).Select
    iBotCell = ActiveCell.Row   'Capture R C:R_C.
    Selection.End(xlUp).Select
    iTopCell = ActiveCell.Row
  
    iWhereami = ActiveCell.Row           'Initialize.
    While iWhereami <= iBotCell
      '''sTrimd = LTrim(ActiveCell)           
      ActiveCell = RTrim(ActiveCell)     'Action to perform on range of cells.
      ActiveCell.Offset(1, 0).Select     'Do next cell down.
      iWhereami = ActiveCell.Row
    Wend
      
   
  
    Range("A1").Select
  
    ActiveWorkbook.Save
    '''ActiveWorkbook.SaveAs FileFormat:=xlExcel5
    ActiveWorkbook.Close
  
    sFile = Dir    'Open next file in directory, if there is one.
  Wend

End Sub
