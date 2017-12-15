'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: PutGetLgFiles.bas
' Summary: Takes large spreadsheets that exceed memory (i.e. not paste-able)
'          and writes to a temporary harddrive file as a form of pseudo
'          memory.  Especially useful for appending spreadsheets.
'          This version only deals with a single spreadsheet.
' Created: Wed 12/02/98 02:47:07 (Bob Heckel)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

Type Record            ' Create user-defined type.
  ID As String * 15    ' Define elements of data type.
  Name As String * 15
  Address As String * 15
End Type

' Use to determine bottom of old spdsht in Sub CreateRecord and as loop 
' counter during Sub RetrieveRecord.
Global botm As Integer
Const origpath As String = "C:\todel"
Const newpath As String = "C:\todel"
Const origfile As String = "nssoutput.xls"
Const newfile As String = "stabilus.xls"

Sub MAIN()
  MsgBox "Macro will write to " & newpath & ". Continue?", vbYesNo, "Macro beginning"
  'TODO if says No, cancel macro...
  Call CreateRecord
  Call RetrieveRecord
  Kill(".\TEMPFILE")
  MsgBox "Macro is finished.  New file " & newpath & "\" & newfile & " has been created.", vbOKOnly
exit sub
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "MAIN"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
End Sub


Sub CreateRecord()
  Dim MyRecord As Record  ' Declare variable.
  Dim rnga As String
  Dim rngb As String
  Dim rngc As String

  Open "TEMPFILE" For Random As #1 Len = Len(MyRecord)
  Workbooks.Open FileName:=origpath & "\" & origfile

  botm = BottomRow()
  
  While ActiveCell.Row <= botm

    rnga = ActiveCell.Offset(0, 0).Value
    ActiveCell.Offset(0, 0).Select
    MyRecord.ID = rnga ' Assign a value to an element.

    rngb = ActiveCell.Offset(0, 1).Value
    ActiveCell.Offset(0, 1).Select
    MyRecord.Name = rngb

    rngc = ActiveCell.Offset(0, 1).Value
    ActiveCell.Offset(0, 1).Select
    MyRecord.Address = rngc

    ActiveCell.Offset(1, -2).Select

    Put #1, , MyRecord
  Wend
    Close #1
    ActiveWorkbook.Close
exit sub
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "CreateRecord"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
End Sub


Sub RetrieveRecord()
  Dim MyRecord As Record
  ' Position of Record in temp file TEMPFILE.
  Dim i As Integer
  ' Holding places for individual values of MyRecord.
  Dim tmp_a, tmp_b, tmp_c As String
  Dim botmplus As Integer

  Open "TEMPFILE" For Random As #1 Len = Len(MyRecord)
  Workbooks.Add
  ' Can't use a 0 in the Get statement.
  botmplus = botm + 1

  For i = 1 To botm      ' Read each Record to end of file created above.
    Get #1, i, MyRecord 
    tmp_a = MyRecord.ID
    ActiveCell.Value = tmp_a
    ActiveCell.Offset(0, 1).Select
    tmp_b = MyRecord.Name
    ActiveCell.Value = tmp_b
    ActiveCell.Offset(0, 1).Select
    tmp_c = MyRecord.Address
    ActiveCell.Value = tmp_c
    ActiveCell.Offset(1, -2).Select
  Next i

  Close #1
  ActiveWorkbook.SaveAs FileName:=newpath & "\" & newfile
  ActiveWorkbook.Close
exit sub
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "RetrieveRecord"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
End Sub


Function BottomRow() As Integer
  '''TODO -- on error goto BOBHERRHANDLER
  'Generic function determines the bottom row of spreadsheet.
  Range("IV1").Select
  Selection.End(xlDown).Select
  Selection.End(xlToLeft).Select
  Selection.End(xlUp).Select
  BottomRow = ActiveCell.Row
  Range("A1").Select
exit Function
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "BottomRow"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
End Function

Function ImplosionError( _
  Optional strProc As String = "<unknown>", _
  Optional fRespond As Boolean = False, _
  Optional objErr As ErrObject) _
  As Boolean
    ' Generic error handling routine that displays
    ' the error information in a dialog box.
    ' In:
    '   strProc: Name of the procedure calling this function
    '   fRespond: If True the dialog includes OK and Cancel buttons
    '   objErr: VBA ErrObject containing error information (optional)
    ' Out:
    '   Return Value: True if the user clicks the OK button, False otherwise
    ' Example: Call ImplosionError("ThisProc", True)
    Dim strMessage As String
    Dim strTitle As String
    Dim intStyle As Integer
    
    ' If the user didn't pass an ErrObject, use Err.
    If objErr Is Nothing Then
      Set objErr = Err
    End If
    
    ' If there is an error, process it otherwise just return True.
    If objErr.Number = 0 Then
      ImplosionError = True
    Else
      ' Build title and message.
      strTitle = "Error " & objErr.Number & _
       " in " & strProc
      strMessage = "The following error has occurred:" & _
       vbCrLf & vbCrLf & objErr.Description & "  See Bob before proceeding."
        
      ' Set the icon and buttons for MsgBox.
      intStyle = vbExclamation
      If fRespond Then
        intStyle = intStyle Or vbOKCancel
      End If
        
      ' Display message and return result.
      ImplosionError = (MsgBox(strMessage, intStyle, strTitle) = vbOK)
    End If
End Function
