Attribute VB_Name = "Module1"

'Summary:  Descends specified directory, opening XLS files and removing
'first 3 rows and last row.

'Created: Thu 08/20/98 02:39:20 (Bob Heckel)


Sub RemoveMostHdrFtr()
Attribute RemoveMostHdrFtr.VB_ProcData.VB_Invoke_Func = " \n14"

 'Assumes starting cell is A1.
  Dim iWhereami As Integer
  Dim iTopCell As Integer
  Dim iBotCell As Integer
  Dim sFile As String
  Dim sTrimd As String
  Const sPath = "C:\Keep_Empty\"
  
  sFile = Dir(sPath & "*.XLS")  'Initialize.
  
 While sFile > ""
  
    Workbooks.Open FileName:=sPath & sFile

    Selection.End(xldown).Select
'    iBotCell = ActiveCell.Row   'Capture R C:R_C.
    Selection.End(xlUp).Select
    iTopCell = ActiveCell.Row
  
'    iWhereami = ActiveCell.Row           'Initialize.
'    While iWhereami <= iBotCell
'      ActiveCell = RTrim(ActiveCell)     'Action to perform on range of cells.
'      ActiveCell.Offset(1, 0).Select     'Do next cell down.
'      iWhereami = ActiveCell.Row
'    Wend
   
'   iWhereami = ActiveCell.Row           'Initialize.
    rows("1:3").Select                   'Wipe out headers except field name row.
    Selection.delete shift:=xlUp
    Selection.End(xldown).Select         'Wipe out footers.
    ActiveCell.Offset(1, 0).Select      'One row down to summed row.
    Selection.EntireRow.delete
    Range("A1").Select

    ActiveWorkbook.Save
    '''ActiveWorkbook.SaveAs FileFormat:=xlExcel5
    ActiveWorkbook.Close
  
    sFile = Dir    'Open next file in directory, if there is one.
  Wend

End Sub
