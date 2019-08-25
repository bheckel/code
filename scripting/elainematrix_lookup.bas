''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: elainematrix_lookup.bas
'  Summary: For all spdshts in directory, look for cell text that is not
'           wanted, deleting the row in which it is found.
'           Then reformat to a more readable layout based on Elaine's lookup
'           table.
'  Created: Tue 12/01/98 12:39:36 (Bob Heckel)
' Modified: Mon Dec 21 1998 09:48:57 (Bob Heckel)
'           Mon Jan 11 1999 10:16:14 (Bob Heckel -- protect from failure due
'                                     to bad lookup.xls)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit
'''Const sPATH = "C:\todel\tmp\" 'DEBUG
Const sPATH = "C:\macros\elainematrix\"
'''Const sLOOKUP = "C:\todel\tmplook\lookup.xls" 'DEBUG
Const sLOOKUP = "C:\macros\elainematrix\lookup\lookup.xls"
Const sCOMPLETE = "C:\macros\elainematrix\complete\"
Const sELAINE = "lookup.xls"
Const sCOLTHREE = "B/(W) View"
Const sCOLFOUR = "YTD"
Const sCOLFIVE = "B/(W) Budget"

Sub MAIN()
  'Assumes starting cell is A1.
  On Error GoTo BOBHERRHANDLER
'''On Error Goto TMP           'DEBUG but also good for falling thru after
  Dim iWhereami As Long     'implosionerror finishes.
  Dim iTopRowNo As Integer
  Dim iBotRowNo As Long
  Dim vTrasheadrs As Variant
  Dim bCtr As Byte
  Dim bCtr2 As Byte
  Dim sCurrentval As String
  Dim iTesting As Integer
  Dim sRptgmo As String
  Dim iWhatToDo As Integer
  Dim sDefaultmo As String
  Dim vMyNow As Variant
  Dim sFile As String

  Application.ScreenUpdating = False  'Toggle for DEBUG.
  sFile = Dir(sPATH & "*.XLS")       'List a file in directory of interest.
  'Prepare the lookup table for later.  It should be in a different dir so
  'that this macro doesn't consume it.
  Workbooks.Open FileName:=sLOOKUP

  While sFile > ""               'Loop over each .xls in directory.
    Workbooks.Open FileName:=sPATH & sFile
    iWhatToDo = MsgBox("Macro will reformat each spreadsheets in " & _
                       sPATH & (Chr(13) & Chr(10)) & (Chr(13) & Chr(10)) & _
                       "Please make sure that only the desired spreadsheets are in that directory.", _
                       vbOKCancel, "Caution -- Macro Beginning")
    If iWhatToDo = vbCancel Then
      Exit Sub
    End If
    
    iBotRowNo = BottomRow()
    Range("A1").Select
    iTopRowNo = ActiveCell.Row     'Initialize.
    iWhereami = ActiveCell.Row     'Initialize.
    sCurrentval = ActiveCell.Value 'Initialize.

    'TODO use Const for these elements...
    vTrasheadrs = Array("User:  ganfield", "Group:  CUSTOMER", "Currency: USB")
    ' Determine top of array.
    bCtr = (UBound(vTrasheadrs) + 1)

    While iWhereami <= iBotRowNo
      bCtr2 = 0
      While (bCtr2 < bCtr)
        sCurrentval = ActiveCell.Value
        ' Looking for User: ganfield, Group: CUST... so that can delete row.
        iTesting = InStr(1, sCurrentval, vTrasheadrs(bCtr2), 1)
        ' If find string, it's greater than zero.
        If iTesting > 0 Then
          Selection.EntireRow.Clear
          GoTo OUTWHILE
        End If
        bCtr2 = bCtr2 + 1
      Wend
OUTWHILE:
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend
      
    'Elim. Current Month=SEP-98 (or whatever) that is always in Col C.
    Range("C1").Select
    iWhereami = ActiveCell.Row
    While iWhereami <= iBotRowNo
      sCurrentval = ActiveCell.Value
      iTesting = InStr(1, sCurrentval, "Current Period:", 1)
        If iTesting > 0 Then
          Selection.EntireRow.Delete
        End If
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend

    vMyNow = Now()
    sDefaultmo = Convert_Mo(Month(vMyNow))
    'Col headings in proper cells.
    sRptgmo = InputBox("Enter Month:   e.g. September", _
                        "Reporting Month", sDefaultmo)
    Range("A1").Select
    iWhereami = ActiveCell.Row
    'Look for row starting w/ Current Month... to reformat.
    While iWhereami <= iBotRowNo
      sCurrentval = ActiveCell.Value
      iTesting = InStr(1, sCurrentval, "Current Month", 1)
        If iTesting > 0 Then
          Selection.EntireRow.Clear
          Selection.EntireRow.Font.FontStyle = "bold"
          Selection.EntireRow.HorizontalAlignment = xlCenter
          ActiveCell.Offset(0, 1).Value = sRptgmo
          ActiveCell.Offset(0, 2).Value = sCOLTHREE
          ActiveCell.Offset(0, 3).Value = sCOLFOUR
          ActiveCell.Offset(0, 4).Value = sCOLFIVE
          'Remove rows below with dashes/blank.
          ActiveCell.Offset(1, 0).Select
          Selection.EntireRow.Delete
          Selection.EntireRow.Delete
          'Correct the down movement that occurs after delete occurs.
          ActiveCell.Offset(-1, 0).Select
        End If
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend

    'Run thru headers, changing values to lookup table.
    Range("A1").Select
    iWhereami = ActiveCell.Row
    While iWhereami <= iBotRowNo
      sCurrentval = ActiveCell.Value
      iTesting = InStr(1, sCurrentval, "Ent-Dept=", 1)
        If iTesting > 0 Then
          ' Replace Ent-Dept... with Elaine's lookup table.
          ' StrConvrt will often return with an error based on a failed find.
          On Error Resume Next
          Call StrConvrt(sFile)
        End If
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend

    Range("A1").Select
    ' Close lookup.xls
    Application.DisplayAlerts = False
    Windows(sELAINE).Activate
    ActiveWorkbook.Close
    ' Close and save newly created file (formerly text format).
    ActiveWorkbook.SaveAs sCOMPLETE & "Formatted" & sFile, FileFormat:=xlWorkbookNormal

    '''ActiveWorkbook.Save 'DEBUG
    ActiveWorkbook.Close
    Application.DisplayAlerts = True

    Application.ScreenUpdating = True

    sFile = Dir      'Open next file in directory, if more exist.
  Wend             'Closes main loop over .xls in the directory.
  MsgBox "Macro is finished.  Formatted file is in " & sCOMPLETE _
         & (Chr(13) & Chr(10)) & (Chr(13) & Chr(10)) & _
         "Do not save this macro if prompted.", vbOKOnly
 Exit Sub
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "MAIN"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
TMP:
  Debug.Print Err.Description
End Sub


Sub StrConvrt(sFile As String)
  'Assumes activecell is an Ent-Dept=... cell and sFile is file of interest.
  'Use Elaine's spdsht for lookup.

  'This protects against missing lookups.
  '''On Error Resume Next
  On Error GoTo NOTFOUND
  Dim sCellOrig As String
  Dim bFound As Boolean

  'If find match in lookup, replace this cell w/ lookup's value.
  sCellOrig = ActiveCell.Value
  'Lookup table name w/o path.
  Windows(sELAINE).Activate
  bFound = Cells.Find(What:=sCellOrig, LookAt:=xlWhole).Activate
  'If lookup.xls doesn't contain the cleaned up name, skip it.
  '''If bFound = True then
    ActiveCell.Offset(0, 9).Select
    Selection.Copy
    'Spdsht to be modified.
    Windows(sFile).Activate
    ActiveSheet.Paste
    Selection.EntireRow.Font.FontStyle = "Bold"
  '''Else
    '''MsgBox "Lookup entry missing: " & sCellOrig,vbOKOnly,"Manual change required"
  '''End If
  Exit Sub
NOTFOUND:
    MsgBox "Lookup entry missing: " & sCellOrig, vbOKOnly, "Manual change required"
    '''Resume Next
    Err.Clear
    'Keep showing missing lookups so that they can be keyed into lookup.xls
    'before next month's run.
    Resume Next
End Sub


'Convert Month Functions 1 thru 12 to English.  Provides current
'month in the InputBox above.  NOTE: Elaine uses 1 mo. in arrears.
Function Convert_Mo(iIncoming As Integer) As String
  On Error GoTo BOBHERRHANDLER
'''On Error Goto TMP
  Select Case iIncoming
    Case 1
      Convert_Mo = "December"
    Case 2
      Convert_Mo = "January"
    Case 3
      Convert_Mo = "February"
    Case 4
      Convert_Mo = "March"
    Case 5
      Convert_Mo = "April"
    Case 6
      Convert_Mo = "May"
    Case 7
      Convert_Mo = "June"
    Case 8
      Convert_Mo = "July"
    Case 9
      Convert_Mo = "August"
    Case 10
      Convert_Mo = "September"
    Case 11
      Convert_Mo = "October"
    Case 12
      Convert_Mo = "November"
  End Select
Exit Function
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "Convert_Mo"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
TMP:
  Debug.Print Err.Description
End Function


Function BottomRow() As Long
  On Error GoTo BOBHERRHANDLER
'''On Error Goto TMP
  'Generic function determines the bottom row of an open spreadsheet.
  'TODO -- make sure row A not misrepresentative.
  Range("IV1").Select
  Selection.End(xlDown).Select
  Selection.End(xlToLeft).Select
  Selection.End(xlUp).Select
  '''If .......rows B to IV are not "" then
    BottomRow = ActiveCell.Row
  '''else
  '''  ......do same algorithym on B, C, D...
  Range("A1").Select
  Exit Function
BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "BottomRow"
  Application.ScreenUpdating = True
  Call ImplosionError(sFailure, True)
TMP:
  Debug.Print Err.Description
End Function


Function ImplosionError( _
  Optional strProc As String = "<unknown>", _
  Optional fRespond As Boolean = False, _
  Optional objErr As ErrObject) _
  As Boolean
    ' In:
    '   strProc: Name of the procedure calling this function
    '   fRespond: If True the dialog includes OK and Cancel buttons
    '   objErr: VBA ErrObject containing error information (optional)
    ' Out:
    '   Return Value: True if the user clicks the OK button,
    '       False otherwise
    ' Example:
    '   Call ImplosionError("ThisProc", True)
 
    Dim strMessage As String
    Dim strTitle As String
    Dim intStyle As Integer
    
    ' If the user didn't pass an ErrObject, use Err
    If objErr Is Nothing Then
      Set objErr = Err
    End If
    
    ' If there is an error, process it
    ' otherwise just return True
    If objErr.Number = 0 Then
      ImplosionError = True
    Else
      ' Build title and message
      strTitle = "Error " & objErr.Number & _
       " in " & strProc
      strMessage = "The following error has occurred:" & _
       vbCrLf & vbCrLf & objErr.Description & "  See Bob before proceeding."
        
      ' Set the icon and buttons for MsgBox
      intStyle = vbExclamation
      If fRespond Then
        intStyle = intStyle Or vbOKCancel
      End If
        
      ' Display message and return result
      ImplosionError = (MsgBox(strMessage, intStyle, strTitle) = vbOK)
    End If
End Function

