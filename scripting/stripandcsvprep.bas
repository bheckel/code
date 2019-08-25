Attribute VB_Name = "Module1"

'Summary:  Descends specified directory, opening XLS files and removing
'first 4 rows and last row.  Then saves as .csv .  Using :so it's possible to
'read in multiple csv spdshts.

'Created: Fri 08/21/98 02:17:00 (Bob Heckel)


Sub StripHdrFtrSaveCsv()
'''Attribute RemoveMostHdrFtr.VB_ProcData.VB_Invoke_Func = " \n14"

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
'    iTopCell = ActiveCell.Row
  
'    iWhereami = ActiveCell.Row           'Initialize.
'    While iWhereami <= iBotCell
'      ActiveCell = RTrim(ActiveCell)     'Action to perform on range of cells.
'      ActiveCell.Offset(1, 0).Select     'Do next cell down.
'      iWhereami = ActiveCell.Row
'    Wend
   
'   iWhereami = ActiveCell.Row           'Initialize.
    rows("1:4").Select                   'Wipe out headers.
    Selection.delete shift:=xlUp
    Selection.End(xldown).Select         'Wipe out footers.
    ActiveCell.Offset(1, 0).Select      'One row down to summed row.
    Selection.EntireRow.delete
    Range("A1").Select

    '''ActiveWorkbook.Save
    application.displayalerts = false    'Don't ask to save it.
    'TODO saves to c:\todel, how to overwrite existing files in c:\keep_empty?
    ActiveWorkbook.SaveAs FileFormat:=xlCSV
    ActiveWorkbook.Close
    application.displayalerts = true
  
    sFile = Dir    'Open next file in directory, if there is one.
  Wend

End Sub
