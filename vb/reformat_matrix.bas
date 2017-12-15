
Option Explicit
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: reformat_matrix.bat
'
'  Summary: For directory of spdshts, look for cell text that is not
'           wanted and delete the row in which it is found.
'           Then reformat.
'           TODO Macro makes assumptions about cell contents and locations,
'           make less fragile with better error checking.
'
'  Created: Wed 10/21/98 11:37:04 (Bob Heckel)
'
' Modified: Fri, 03 Mar 2000 08:58:34 (Bob Heckel -- for Clint Hyden)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Sub Main()
  On Error GoTo BOBHERRHANDLER
  Dim iWhereami As Integer
  Dim iTopRowNo As Integer
  Dim iBotRowNo As Integer
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
  Dim sPath As String
  Const USER = "User:  "
  Const GROUP = "Group:  CUSTOMER"
  Const CURRNCY = "Currency: US"
  Const ENTDEPT = "Ent-Dept="

  Range("A1").Select
  ' DEBUG.
  Application.ScreenUpdating = False

  ' DEBUG.
  '''sPath = "C:\todel\tmp\"
  sPath = InputBox("Please enter directory where spreadsheet(s) to be modified.  Important - key a trailing slash", "Caution--macro beginning", "C:\")
  ' Check for mandatory trailing space.
  While Right(sPath, 1) <> "\"
    sPath = InputBox("Please enter directory where spreadsheet(s) to be modified.  IMPORTANT - KEY A TRAILING SLASH", "Caution--macro beginning", "C:\")
  Wend

  sFile = Dir(sPath & "*.XLS")  'Initialize for spreadsheets.

  While sFile > ""               'Loop over all .xls in directory.
    Workbooks.Open FileName:=sPath & sFile

    iWhatToDo = MsgBox("Macro will reformat all spreadsheets in " & _
                       sPath & (Chr(13) & Chr(10)) & (Chr(13) & Chr(10)) & _
                       "Please make sure that only the desired spreadsheets are in that directory. Macro overwrites the original.", _
                        vbOKCancel, "Caution -- Macro Beginning")
    If iWhatToDo = vbCancel Then
      Exit Sub
    End If
    
    ' Since Matrix reports have blank rows, must find bottom differently.
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

    '''vTrasheadrs = Array("User:  ", "Group:  CUSTOMER", "Currency: US")
    ' Using constants for easier maintenance.
    vTrasheadrs = Array(USER, GROUP, CURRNCY)
    ' Determine top of array.
    bCtr = (UBound(vTrasheadrs) + 1)

    While iWhereami <= iBotRowNo
      bCtr2 = 0
      While (bCtr2 < bCtr)
        sCurrentval = ActiveCell.Value
        iTesting = InStr(1, sCurrentval, vTrasheadrs(bCtr2), 1)
        ' If find string, it's greater than zero.
        If (iTesting) Then
          Selection.EntireRow.Clear
          GoTo OUTWHILE
        End If
        bCtr2 = bCtr2 + 1
      Wend
OUTWHILE:
        ActiveCell.Offset(1, 0).Select
        iWhereami = ActiveCell.Row
      Wend
        
    ' TODO use Const at top of code.
    'Elim. Current Month=SEP-98 that is always in Col C.
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
    sDefaultmo = ConvertMonth((Month(vMyNow) - 1))
    'Col headings in proper cells.
    sRptgmo = InputBox("Enter Full Month Name and Year:   e.g. May 1998", _
                        "Reporting Month", sDefaultmo)
    Range("A1").Select
    iWhereami = ActiveCell.Row
    
    '''ActiveSheet.PageSetup.Orientation = xlLandscape
    '''ActiveSheet.PageSetup.PrintArea = ""
    '''ActiveSheet.PageSetup.FitToPagesWide = 1
    '''ActiveSheet.PageSetup.FitToPagesTall = False
    While iWhereami <= iBotRowNo
      sCurrentval = ActiveCell.Value
      ' Garbage header has '   Current   Month   ...' in it.
      iTesting = InStr(1, sCurrentval, "Current    Month", 1)
        If (iTesting) Then
          Selection.EntireRow.Clear
          '''Selection.Rows.PageBreak = xlPageBreakManual


          '''ActiveSheet.PageSetup.FitToPagesWide = 1
          '''Columns("a:j").PageSetup.FitToPagesWide = 1
          ActiveCell.Offset(-1, 0).Rows.PageBreak = xlPageBreakManual
          Selection.EntireRow.Font.FontStyle = "bold"
          Selection.EntireRow.HorizontalAlignment = xlCenter
          '''ActiveCell.Offset(-1, 0).PageBreak = xlPageBreakManual
          ActiveCell.Offset(0, 0).Value = sRptgmo
          ActiveCell.Offset(0, 1).Value = "Prior Month"
          ActiveCell.Offset(0, 2).Value = "Current Month"
          ActiveCell.Offset(0, 3).Value = "Month B/(W) Budget"
          ActiveCell.Offset(0, 4).Value = "Month B/(W) View"
          ActiveCell.Offset(0, 5).Value = "YTD Actuals"
          ActiveCell.Offset(0, 6).Value = "YTD B/(W) Budget"
          ActiveCell.Offset(0, 7).Value = "YTD B/(W) View"
          Columns("A:A").ColumnWidth = 40
          Columns("b:b").ColumnWidth = 13
          Columns("b:b").WrapText = True
          Columns("c:c").ColumnWidth = 13
          Columns("c:c").WrapText = True
          Columns("d:d").ColumnWidth = 13
          Columns("d:d").WrapText = True
          Columns("e:e").ColumnWidth = 13
          Columns("e:e").WrapText = True
          Columns("f:f").ColumnWidth = 13
          Columns("f:f").WrapText = True
          Columns("g:g").ColumnWidth = 13
          Columns("g:g").WrapText = True
          Columns("h:h").ColumnWidth = 13
          Columns("h:h").WrapText = True
          'Remove rows below with dashes/blank.
          ActiveCell.Offset(1, 0).Select
          Selection.EntireRow.Delete
          Selection.EntireRow.Delete
          'Correct the down movement that occurs when loop ends.
          ActiveCell.Offset(-1, 0).Select
        End If
      ActiveCell.Offset(1, 0).Select
      iWhereami = ActiveCell.Row
  Wend

  '''Dim Entdept_ctr
  '''Entdept_ctr = 0
  'Run thru headers, cropping parens, etc.
  Range("A1").Select
  iWhereami = ActiveCell.Row
  While iWhereami <= iBotRowNo
    sCurrentval = ActiveCell.Value
    iTesting = InStr(1, sCurrentval, ENTDEPT, 1)
      If iTesting > 0 Then
        Call StringConvert(sCurrentval)
        '''Entdept_ctr = Entdept_ctr + 1
      End If
    ActiveCell.Offset(1, 0).Select
    iWhereami = ActiveCell.Row
  Wend

  ' Add blank columns.
  Columns("c").EntireColumn.Insert
  Columns("c").ColumnWidth = 4
  Columns("g").EntireColumn.Insert
  Columns("g").ColumnWidth = 4

  ' Elim 3 blank lines at top (avoid blank page).
  Rows("1:3").EntireRow.Delete
 
  With ActiveSheet.PageSetup
      .Zoom = 75
      '''.FitToPagesWide = 1
      '''.FitToPagesTall = Entdept_ctr
      ' TODO why can't use Landscape and specify page breaks??? Zoom problem??
      .Orientation = xlLandscape
  End With

  Range("A1").Select
  ActiveWorkbook.Save
  ActiveWorkbook.Close

'''  Dim cell As Object
'''  For Each cell In ActiveSheet.Cells
'''    If cell.Value = "-------" Then
'''      cell.HorizontalAlignment = xlRight
'''    End If
'''  Next

  Application.ScreenUpdating = True

     sFile = Dir      'Open next file in directory, if more exist.
  Wend              'Closes main loop over .xls in the directory.
  MsgBox "Macro is finished."
Exit Sub

BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "Main"
  Application.ScreenUpdating = True
  Call dhError(sFailure, True)

End Sub

Sub StringConvert(sIncoming As String)
  'Assumes activecell is an Ent-Dept= cell.
  'Strips away all text outside the parenthesis and the parens themselves.
   Dim iPosLParen As Integer
   Dim iPosRParen As Integer
   Dim iLength As Integer
   Dim sConverted As String
   Dim iStart As Integer

   iPosLParen = InStr(1, sIncoming, "(", 1)
   iPosRParen = InStr(1, sIncoming, ")", 1)
   iLength = iPosRParen - iPosLParen - 1
   iStart = iPosLParen + 1
   sConverted = Mid(sIncoming, iStart, iLength)
   ActiveCell.Value = sConverted
   Selection.EntireRow.Font.FontStyle = "bold"
 End Sub

'Convert Month Functions 1 thru 12 to English.  Provides current
'month in the InputBox above.
Function ConvertMonth(iIncoming As Integer) As String
  On Error GoTo BOBHERRHANDLER
  Select Case iIncoming
    Case 1
      ConvertMonth = "January " & Year(Now())
    Case 2
      ConvertMonth = "February " & Year(Now())
    Case 3
      ConvertMonth = "March " & Year(Now())
    Case 4
      ConvertMonth = "April " & Year(Now())
    Case 5
      ConvertMonth = "May " & Year(Now())
    Case 6
      ConvertMonth = "June " & Year(Now())
    Case 7
      ConvertMonth = "July " & Year(Now())
    Case 8
      ConvertMonth = "August " & Year(Now())
    Case 9
      ConvertMonth = "September " & Year(Now())
    Case 10
      ConvertMonth = "October " & Year(Now())
    Case 11
      ConvertMonth = "November " & Year(Now())
    Case 12
      ConvertMonth = "December " & Year(Now())
  End Select
Exit Function

BOBHERRHANDLER:
  Dim sFailure As String
  sFailure = "ConvertMonth"
  Application.ScreenUpdating = True
  Call dhError(sFailure, True)

End Function

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




