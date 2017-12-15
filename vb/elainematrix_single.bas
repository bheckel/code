BETTER VERSION IS /code/vb/reformat_matrix.bas
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: elainematrix_single.bas
'  Summary: For open spdsht, look for cell text that is not
'           wanted and delete the row in which it is found.
'           Then reformat.
'  Created: Wed 10/21/98 11:37:04 (Bob Heckel)
' Modified: Thu 10/22/98 04:22:13 (Bob Heckel--adjusted to run single spdsht. 
'                                  and intelligence to InputBox date default.)
'           Mon 10/26/98 08:43:57 (Bob Heckel -- made loop over directory
'                                  possible & commented it out.)
'           Mon 11/02/98 10:21:37 (Bob Heckel -- minor wording changes.)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
option explicit
Sub Main()
  'Assumes starting cell is A1.
  On Error GoTo BOBHERRHANDLER
  Dim iWhereami As Integer
  Dim iTopRowNo As Integer
  Dim iBotRowNo As Integer
  Dim vTrasheadrs as variant
  dim bCtr as byte
  dim bCtr2 as byte
  dim sCurrentval as string
  dim iTesting as integer
  dim sRptgmo as string
  dim iWhatToDo as integer
  dim sDefaultmo as string
  dim vMyNow as variant 
  dim sFile as string           
  Const sPath = "C:\todel\tmp\"  

  Application.ScreenUpdating = False

 sFile = Dir(sPath & "*.XLS")  'Initialize.

while sFile > ""               'Loop over all .xls in directory.
  workbooks.open filename:=sPath & sFile

  iWhatToDo = MsgBox("Macro will reformat all spreadsheets in " & _
                     sPath & (Chr(13) & Chr(10)) & (Chr(13) & Chr(10)) & _ 
                     "Please make sure that only the desired spreadsheets are in that directory. Macro overwrites the original.", _ 
                      vbOKCancel, "Caution -- Macro Beginning")
  if iWhatToDo = vbCancel then 
    exit sub
  end if
  
    ' Since this spdsht has blank rows, must find bottom differently.
    Range("IV1").Select
    Selection.End(xlDown).Select
    Selection.End(xlToLeft).Select
    Selection.End(xlUp).Select
    ' Now at bottom leftmost cell.
    iBotRowNo = ActiveCell.Row   'Capture R C :R_C 
    Range("A1").Select
    iTopRowNo = ActiveCell.Row
 
    iWhereami = ActiveCell.Row     'Initialize.
    sCurrentval = ActiveCell.Value 'Initialize.

    vTrasheadrs = Array("User:  ganfield", "Group:  CUSTOMER", "Currency: USB")
    ' Determine top of array.
    bCtr = (UBound(vTrasheadrs) + 1)

    While iWhereami <= iBotRowNo
      bCtr2 = 0
      while (bCtr2 < bCtr)
        sCurrentval = ActiveCell.Value
        iTesting = Instr(1, sCurrentval, vTrasheadrs(bCtr2), 1)
        ' If find string, it's greater than zero.
        if iTesting > 0 then
          Selection.EntireRow.Clear
          goto OUTWHILE
        end if
        bCtr2 = bCtr2 + 1
      wend
      OUTWHILE:
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
    Wend
      
  'Elim. Current Month=SEP-98 that is always in Col C.
  range("C1").select
  iWhereami = ActiveCell.Row
  while iWhereami <= iBotRowNo
    sCurrentval = ActiveCell.Value
    iTesting = Instr(1, sCurrentval, "Current Period:", 1)
      if iTesting > 0 then
        Selection.EntireRow.Delete
      end if
    ActiveCell.Offset(1, 0).Select
    iWhereami = ActiveCell.Row
  wend

  vMyNow = now()
  sDefaultmo = convert_mo(month(vMyNow)) 
  'Col headings in proper cells.
  sRptgmo = InputBox("Enter Month:   e.g. September", _
                      "Reporting Month", sDefaultmo)
  range("A1").select
  iWhereami = ActiveCell.Row
  while iWhereami <= iBotRowNo
    sCurrentval = ActiveCell.Value
    iTesting = Instr(1, sCurrentval, "Current Month", 1)
      if iTesting > 0 then
        Selection.EntireRow.clear
        Selection.EntireRow.font.fontstyle = "bold"
        Selection.EntireRow.horizontalalignment = xlCenter
        ActiveCell.Offset(0,1).value = sRptgmo
        ActiveCell.Offset(0,2).value = "B/(W) View"
        ActiveCell.Offset(0,3).value = "YTD"
        ActiveCell.Offset(0,4).value = "B/(W) Budget"
        'Remove rows below with dashes/blank.
        ActiveCell.Offset(1,0).Select
        Selection.EntireRow.delete
        Selection.EntireRow.delete
        'Correct the down movement that occurs when loop ends.
        ActiveCell.Offset(-1,0).select
      end if
    ActiveCell.Offset(1, 0).Select
    iWhereami = ActiveCell.Row
  wend

  'Run thru headers, cropping parens, etc.
  Range("A1").Select
  iWhereami = ActiveCell.Row
  while iWhereami <= iBotRowNo
    sCurrentval = ActiveCell.Value
    iTesting = Instr(1, sCurrentval, "Ent-Dept=", 1)
      if iTesting > 0 then
        call strgconvrt(sCurrentval)
      end if
    ActiveCell.Offset(1, 0).Select
    iWhereami = ActiveCell.Row
  wend

  Range("A1").Select
  ActiveWorkbook.Save
  ActiveWorkbook.Close

  Application.ScreenUpdating = true

     sFile = Dir      'Open next file in directory, if more exist.
  wend              'Closes main loop over .xls in the directory.
  msgbox "Macro is finished."
Exit Sub

BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "Main"
  Application.ScreenUpdating = True
  Call dhError(sFailure, True)

End Sub

sub strgconvrt(sIncoming as string)
  'Assumes activecell is an Ent-Dept= cell.
  'Strips away all text outside (and including) the parens.
   dim iPosLParen as integer
   dim iPosRParen as integer
   dim iLength as integer
   dim sConverted as string
   dim iStart as integer

   iPosLParen = InStr(1, sIncoming, "(", 1)
   iPosRParen = InStr(1, sIncoming, ")", 1)
   iLength = iPosRParen - iPosLParen - 1
   iStart = iPosLParen + 1
   sConverted = Mid(sIncoming, iStart, iLength)
   Activecell.value = sConverted
   Selection.EntireRow.font.fontstyle = "bold"
 end sub

Function dhError( _
  Optional strProc As String = "<unknown>", _
  Optional fRespond As Boolean = False, _
  Optional objErr As ErrObject) _
  As Boolean
    ' Generic error handling routine that displays
    ' the error information in a dialog box.
    '
    ' In:
    '   strProc: Name of the procedure calling this function
    '   fRespond: If True the dialog includes OK and Cancel buttons
    '   objErr: VBA ErrObject containing error information (optional)
    ' Out:
    '   Return Value: True if the user clicks the OK button,
    '       False otherwise
    ' Example:
    '   Call dhError("ThisProc", True)
 
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
      dhError = True
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
      dhError = (MsgBox(strMessage, intStyle, strTitle) = vbOK)
    End If
End Function

'Convert Month Functions 1 thru 12 to English.  Provides current
'month in the InputBox above.
function convert_mo (iIncoming as integer) as string
  On Error GoTo BOBHERRHANDLER
  select case iIncoming
    case 1
      convert_mo = "January"
    case 2
      convert_mo = "February"
    case 3
      convert_mo = "March"
    case 4
      convert_mo = "April"
    case 5
      convert_mo = "May"
    case 6
      convert_mo = "June"
    case 7
      convert_mo = "July"
    case 8
      convert_mo = "August"
    case 9
      convert_mo = "September"
    case 10
      convert_mo = "October"
    case 11
      convert_mo = "November"
    case 12
      convert_mo = "December"
  end select
exit function

BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "convert_mo"
  Application.ScreenUpdating = True
  Call dhError(sFailure, True)

end function 
