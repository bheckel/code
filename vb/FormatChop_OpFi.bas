Attribute VB_Name = "FormatChop"
'-----------------------------------------------------------------------------
'    Name: FormatChop_OpFi.bas
' Summary: Takes each region's text file, opens with Excel, adds headers,
'          calculates sums and formats then Chops OMs into separate
'          spreadsheets.  Works for Open or Final based on user's selection.
'
'           TODO auto populate week msgbox.
'           TODO use For Each instead of whiles for looping arrays.
'
' Created: 05/01/98 (Bob Heckel)
' Revised: 08/14/98 (Bob Heckel - Changed directory name, no screen update,
'                    OM structure)
'          09/29/98 (Bob Heckel -- New printer causes runtime error.
'                    Added new error trap.)
'          10/02/98 (Bob Heckel -- Adjust for badly needed memory savings.
'                    Adjust Select Case.)
'          10/27/98 (Bob Heckel -- Change labels from ...Complete to ...B/(W)
'                    Added OM77 to IOC's array.
'                    Changed Application.Calculation to xlAutomatic before
'                    saving.)
'          12/22/98 (Bob Heckel -- Year-end date modifications and add new
'                    regions C214 and C218 in Select Case)
'          01/18/99 (Bob Heckel -- Correct error where 9901 reports as 991 in
'                    the output files)
'          01/25/99 (Bob Heckel -- Correct NonEAE label and % complete calc
'                    error.)
'          Thu Feb 11 1999 10:07:53 (Bob Heckel--minor naming convention;
'                                     added StatusBar)
'          Mon Feb 15 1999 11:15:49 (Bob Heckel--automated textfile d/l.)
'          Tue Mar 02 1999 13:51:56 (Bob Heckel--modi NonEAE to capture non
'                                    EAE, SDE.  Major revision to speed code
'                                    and consolidate Open + Final.)
'          Modified: Fri Jul 09 1999 12:02:01 (Bob Heckel--close macro without
'                                              prompting)
'          Modified: Thu, 16 Dec 1999 13:30:40 (Bob Heckel--elim C218, add C219)
'-----------------------------------------------------------------------------
Option Explicit

'Two digit reporting week must be String to accomodate week 01, 02, etc.
Public sRptgwk As String
Public aRgns As Variant    ' Array of 12 files.
Public bOMCtr As Byte      ' Array counter. Must be public b/c Formator uses it.
Public sPath As String     ' Use for either Op or Fi.
Const sOpnpath As String * 8 = "C:\Open\"
Const sChopath As String * 13 = "C:\Open\by_OM"
Const sFinpath As String * 9 = "C:\Final\"
Const sChopathf As String * 14 = "C:\Final\by_OM"

'''Const bytOpFi = 1   ' DEBUG  Determine if running Open or Final.

Sub Main(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  Dim bToparray2 As Byte
  Dim sXlsname2 As String     'e.g. ALDop.xls (actually a downloaded text file).
  Dim sTitle As String        'e.g. AMT Week 02,99 on whole & chops.
  Dim sOorFfiles As String

  sRptgwk = InputBox("This is a memory-intensive process.  Close all other programs. Please enter two digit week number:", _
                     "Enter Reporting Week", "##")
  ' Allow multiple attempts for rptg wk but bail out if user hits Cancel button.
  If sRptgwk = "" Then
    MsgBox "Operation Cancelled."
    Exit Sub
  End If
  While sRptgwk = "##"
    MsgBox "Please enter valid two digit week."
    sRptgwk = InputBox("This is a memory-intensive process.  Close all other programs. Please enter two digit week number:", _
                        "Enter Reporting Week", "##")
    If sRptgwk = "" Then
      Exit Sub
      MsgBox "Operation Cancelled."
    End If
  Wend

  ' Prepare for proper textfiles to be used.
  If bytOpFi = 1 Then
    sOorFfiles = "op.xls"
    sPath = sOpnpath
  Else
    sOorFfiles = "fi.xls"
    sPath = sFinpath
  End If
  Application.Calculation = xlManual
  'Allow for debugging if you already have textfiles.  Normal process is to begin d/l.
  If MsgBox("Begin download of text files?", vbYesNo) = vbYes Then
    Call Downloadtxt(bytOpFi)
  End If
  Application.StatusBar = "Now processing Job Costing text files..."
  Application.ScreenUpdating = False

  ' Added C218 ISPN and C214 BAT for '99.  Eliminated BAS and BAN.'
  ' Elim C218 ISPN for late '99.  Add C219.
  aRgns = Array("ALD", "AMT", "BAT", "BST", "CLEC", "CTNR", "GTE", "IOC", "PAC", "SBC", "SPR", "USW", "ZZZ")
  '''aRgns = Array("ALD", "AMT")  'DEBUG TOGGLE.
  bToparray2 = (UBound(aRgns) + 1)
  bOMCtr = 0

  ' For each Region's textfile in the array:
  While (bOMCtr < bToparray2)
    sXlsname2 = sPath & aRgns(bOMCtr) & sOorFfiles
    Workbooks.Open FileName:=sXlsname2
    sTitle = aRgns(bOMCtr) & " - Week " & sRptgwk & ", 1999"           'Change yearly.
    Call InsertTitle(bytOpFi, sTitle)
    Call NonEAESDE(bytOpFi)  'Create a section at far right of spdsht.
    ' Function Numrows returns 0 if only one row exists.
    If Numrows = 0 Then Call Formator(bytOpFi) Else Call Sumcolumns(bytOpFi)
    Call SaveWholeRgn(bytOpFi)
  Wend

  ' Chops requires Whole Region spdsht to be saved previously & closed.  So
  ' this must be outside the MAIN loop.
  Call Chops(bytOpFi)
  Call Killtrash(bytOpFi)

  aRgns = Empty
  bOMCtr = Empty
  sRptgwk = Empty
  Application.StatusBar = False
  Application.Calculation = xlAutomatic
  Application.ScreenUpdating = True
  If bytOpFi = 1 Then
    MsgBox "Macro is finished.  Text files have been deleted.  Processed files are located in " & sPath & " and " & sChopath & ".  Do not save if prompted.", vbInformation, "Complete"
    ' Be sure to comment this out when debugging/maintaining code.
    Application.DisplayAlerts = False
    Application.ThisWorkbook.Close
    Application.DisplayAlerts = True
  Else
    MsgBox "Macro is finished.  Text files have been deleted.  Processed files are located in " & sFinpath & " and " & sChopathf & ".  Do not save if prompted.", vbInformation, "Complete"
    ' Be sure to comment this out when debugging/maintaining code.
    Application.DisplayAlerts = False
    Application.ThisWorkbook.Close
    Application.DisplayAlerts = True
  End If
Exit Sub
   
FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "MAIN"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub

Sub InsertTitle(bytOpFi As Byte, sTitleIn As String)
  ' Header on whole rgn spdsht.
  On Error GoTo FILEERRORHANDLER
  Rows("1:3").Select
  Selection.Insert shift:=xlDown
  Range("G1").Select
  If bytOpFi = 1 Then
    ActiveCell.FormulaR1C1 = "DART Open Jobs Job-To-Date"
  Else
    ActiveCell.FormulaR1C1 = "DART Final Jobs Job-To-Date"
  End If
  Range("G2").Select
  '''OLD WAY---ActiveCell.FormulaR1C1 = aRgns(bOMCtr) & " - Week " & sRptgwk & ", 1999" 'Change yearly.
  ActiveCell.FormulaR1C1 = sTitleIn
  Range("F1:G2").Select
  With Selection
    .Font.Name = "Times New Roman"
    .Font.FontStyle = "Bold"
    .Font.Size = 14
    .Font.Underline = xlNone
    .HorizontalAlignment = xlCenter
    .VerticalAlignment = xlBottom
    .WrapText = False
    .Orientation = xlHorizontal
  End With
  Range("A1").Select
Exit Sub ' Return to MAIN() or Chops()
   
FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "InsertTitle"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


Sub NonEAESDE(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  'Create block of summed FE, OTHR, PAE, SAE, SSE on far right.
  'Assumes cursory formatting has been performed.
  Dim iWhereami As Integer
  Dim i As Integer
  Dim j As Integer
  Dim sngAct As Single
  Dim sngTgt As Single
  Dim sngPctCompl As Single
  Dim iTopCell As Integer
  Dim iBotCell As Integer
  Dim bytLoop As Byte
  '''Dim sCellFrmula as String
  
  Range("A1").Select
  Selection.End(xlDown).Select
  Selection.End(xlToRight).Select
  'Capture bottom; return to top.
  Selection.End(xlDown).Select
  iBotCell = ActiveCell.Row   'Capture R C:R_C.
  Selection.End(xlUp).Select
  iTopCell = ActiveCell.Offset(0, 1).Row
  ' Sitting at SSE % header cell.
  If bytOpFi = 1 Then
    With ActiveCell
      .Offset(0, 1).Value = "Tot Eng w/o EAE&SDE Tgt Hrs"
      .Offset(0, 2).Value = "Tot Eng w/o EAE&SDE Act Hrs"
      .Offset(0, 3).Value = "Tot Eng w/o EAE&SDE Hrs Remain"
      .Offset(0, 4).Value = "Tot Eng w/o EAE&SDE Tgt Cost"
      .Offset(0, 5).Value = "Tot Eng w/o EAE&SDE Act Cost"
      .Offset(0, 6).Value = "Tot Eng w/o EAE&SDE Complete"
      'Want to go to leftmost NonEAESDE to start loops below.
      .Offset(0, 1).Select
    End With
      ' Sum the non EAE&SDE block; 5 cols to the right for Open, 6 for Final.
    bytLoop = 5
  Else
    With ActiveCell
      .Offset(0, 1).Value = "Tot Eng w/o EAE&SDE Tgt Hrs"
      .Offset(0, 2).Value = "Tot Eng w/o EAE&SDE Act Hrs"
      .Offset(0, 3).Value = "Tot Eng w/o EAE&SDE Hrs Variance"
      .Offset(0, 4).Value = "Tot Eng w/o EAE&SDE Tgt Cost"
      .Offset(0, 5).Value = "Tot Eng w/o EAE&SDE Act Cost"
      .Offset(0, 6).Value = "Tot Eng w/o EAE&SDE B/(W)"
      .Offset(0, 7).Value = "Tot Eng w/o EAE&SDE Variance"
      'Want to go to leftmost NonEAESDE to start loops below.
      .Offset(0, 1).Select
    End With
    bytLoop = 6
  End If

    For i = 1 To bytLoop
      iWhereami = ActiveCell.Row    'Initialize.
      ' Populate rows with FE + PAE...
      While iWhereami < iBotCell
        ActiveCell.Offset(1, 0).Select
        ' Add only FE, PAE, SAE, SSE, OTHR to get Tot minus EAE&SDE
        '''ActiveCell.FormulaR1C1 = "=+RC[-6]+RC[-18]+RC[-24]+RC[-30]+RC[-36]"
        '''DOESNT WORKActiveCell.FormualR1C1 = sCellFrmula
        If bytOpFi = 1 Then
          ' Pick up FE, PAE, etc.
          ActiveCell.FormulaR1C1 = "=+RC[-6]+RC[-18]+RC[-24]+RC[-30]+RC[-36]"
        Else
          ActiveCell.FormulaR1C1 = "=+RC[-7]+RC[-21]+RC[-28]+RC[-35]+RC[-42]"
        End If

        iWhereami = ActiveCell.Row
      Wend
      'Go to start of next column.
      Selection.End(xlUp).Select
      ActiveCell.Offset(0, 1).Select
    Next i
    
    'Loop thru % complete w/ new formula.
    'Cell is header for % complete at this point.
    'No outer loop b/c only one column of %s.
    iWhereami = ActiveCell.Row      'Initialize.
    While iWhereami < iBotCell
      ActiveCell.Offset(1, 0).Select
      'Find pct complete of FE, OTHR, PAE, SAE, SSE.
      'Prevent div by 0.
      If (bytOpFi = 1 And ((ActiveCell.Offset(0, -1).Value = 0 Or ActiveCell.Offset(0, -2).Value = 0))) _
         Or ((bytOpFi <> 1) And ((ActiveCell.Offset(0, -3) = 0))) Then
        ActiveCell.Value = 0
        iWhereami = ActiveCell.Row
      Else:
        ' Sub provides %.
        Call ElimSums(bytOpFi)
        iWhereami = ActiveCell.Row
      End If
    Wend
    'Sitting at bottom rightmost cell.
    'Format the current column.
    ' TODO don't hardcode.
      If bytOpFi = 1 Then
        Columns("BV:BV").Select
      Else
        Columns("CH:CH").Select
      End If
    With Selection
      .NumberFormat = "0%"
      .End(xlDown).Select
      .End(xlDown).Select
    End With
    Range("A1").Select
    
    Exit Sub
    'Return to MAIN.

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "NonEAESDE"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


Sub SaveWholeRgn(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  Dim sNewfname As String     'e.g. OPNJBS_9815_ALD.xls (real spreadsheet)

  If bytOpFi = 1 Then
    sNewfname = sPath & "OPNJBS_" & "99" & sRptgwk & "_" & aRgns(bOMCtr) & ".xls"
  Else
    sNewfname = sPath & "FINJBS_" & "99" & sRptgwk & "_" & aRgns(bOMCtr) & ".xls"
  End If
  Range("A1").Select
  Application.Calculation = xlAutomatic    'Turn on calc so spdsht is saved that way.
  ' Don't want msgbox to ask for Excel version to Save As.
  ActiveWorkbook.SaveAs FileName:=sNewfname, FileFormat:=xlExcel5
  ' Prevent complaints from Excel regarding save.
  Application.DisplayAlerts = False
  ' Must close then open in Chops() b/c macro fails after 1st spdsht since
  ' others aren't open already like the 1st.
  ActiveWorkbook.Close
  Application.DisplayAlerts = True
  Application.Calculation = xlManual
  bOMCtr = bOMCtr + 1
  'Return to Sub MAIN.
  Exit Sub

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "SaveWholeRgn"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub
  

Sub Formator(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  Rows("3:3").RowHeight = 12
  'Format header row.
  Rows("4:4").Select
  With Selection
      .RowHeight = 37.5
      .HorizontalAlignment = xlCenter
      .VerticalAlignment = xlBottom
      .WrapText = True
      .Font.Name = "Times New Roman"
      .Font.FontStyle = "Bold"
      .Font.Size = 10
      .Font.Shadow = False
      .Font.ColorIndex = xlAutomatic
  End With
  
  If bytOpFi = 1 Then
    'Format rest of worksheet.
    Range("A:A,B:B,F:F,H:H,I:I").Select
    Selection.HorizontalAlignment = xlCenter
    Range("A1").Select
    'Common header for character fields only.
    Columns("A:A").ColumnWidth = 7.1
    Columns("B:B").ColumnWidth = 5
    Columns("C:C").ColumnWidth = 9.3
    Columns("D:D").ColumnWidth = 25
    Columns("E:E").ColumnWidth = 5
    Columns("F:F").ColumnWidth = 6.2
    Columns("G:G").ColumnWidth = 9.5
    Columns("H:H").ColumnWidth = 7.3
    Columns("I:I").ColumnWidth = 7.7
    Columns("J:J").ColumnWidth = 6.1
    Columns("K:K").ColumnWidth = 6.1
    Columns("L:L").ColumnWidth = 9.8
    Columns("M:M").ColumnWidth = 6.6
    'Can't use With ... End With
    ActiveSheet.PageSetup.PrintArea = ""
    ActiveSheet.PageSetup.Orientation = xlLandscape
    ActiveSheet.Columns("M").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("T").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AA").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AG").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AM").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AS").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AY").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("BE").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("BK").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("BQ").PageBreak = xlPageBreakManual
  Else
    Range("A:A,B:B,C:C,D:D,H:H,J:J").Select
    Selection.HorizontalAlignment = xlCenter
    Range("A1").Select
    ' Required for Final Jobs macros.  Handles whole regions.
    Range("V:V, AD:AD, AK:AK, AR:AR, AY:AY, BF:BF, BM:BM, BT:BT, CA:CA").Select
    Selection.NumberFormat = "0%"
    Range("A1").Select
    'Common header for character fields only.
    Columns("A:A").ColumnWidth = 7.1
    Columns("B:B").ColumnWidth = 6
    Columns("C:C").ColumnWidth = 7
    Columns("D:D").ColumnWidth = 5.5
    Columns("E:E").ColumnWidth = 9.5
    Columns("F:F").ColumnWidth = 12
    Columns("G:G").ColumnWidth = 6
    Columns("H:H").ColumnWidth = 7
    Columns("I:I").ColumnWidth = 9
    Columns("J:J").ColumnWidth = 6.1
    Columns("K:K").ColumnWidth = 6.5
    Columns("L:L").ColumnWidth = 8
    Columns("M:M").ColumnWidth = 9.5
    Columns("N:N").ColumnWidth = 8
    'For the numerics, defaults ok.
    ActiveSheet.PageSetup.PrintArea = ""
    ActiveSheet.PageSetup.Orientation = xlLandscape
    ActiveSheet.Columns("O").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("W").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AE").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AL").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AS").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("AZ").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("BG").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("BN").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("BU").PageBreak = xlPageBreakManual
    ActiveSheet.Columns("CB").PageBreak = xlPageBreakManual
  End If

  Exit Sub
  'Return to Sub Sumcolumns or Sub MAIN or Sub Chops.

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "Formator"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


Sub Sumcolumns(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  Dim iAddfromtopX As Integer 'Top of row to be summmed.
  Dim iAddfrombotX As Integer 'Bottom of row to be summed.
  Dim sClump As String        'Combine iAddfromtopX & botX for R1C1 reference.
  Dim sTest As String         'Determine when run out of columns to the right.
  Dim sngTgt As Single        'Target cell.
  Dim sngAct As Single        'Actual cell.
  Dim sngPctCompl As Single   'Result of (Tgt-Act)/Tgt or BW/Tgt.
  
  'Assumes starting cell is 1st numeric at top of column.
  If bytOpFi = 1 Then
    ActiveCell.Offset(4, 13).Select   'This is location of 1st summable col."
  Else
    ActiveCell.Offset(4, 15).Select   'This is location of 1st summable col."
  End If
  iAddfromtopX = ActiveCell.Row     'Capture R_C:R C
  Selection.End(xlDown).Select
  iAddfrombotX = ActiveCell.Row     'Capture R C:R_C.
  ActiveCell.Offset(1, 0).Select    'Cell in which formula will reside.
  sClump = "R" & iAddfrombotX & "C:R" & iAddfromtopX & "C"
  ActiveCell.FormulaR1C1 = "=SUM(" & sClump & ")"   'This col. is now complete.
  ActiveCell.Offset(0, 1).Select
  Selection.End(xlUp).Select
  Selection.End(xlUp).Select        'Move to top of col (row 5).
  ActiveCell.Offset(1, 0).Select    'Move down off the header row.
  
  sTest = ActiveCell.Value          'Will contain SOME value if more cols exist to the right.
  While (sTest > "")
    Selection.End(xlDown).Select
    ' Don't use a With ... End With here.
    ActiveCell.Offset(1, 0).Select  'Move to cell in which formula will reside again.
    ActiveCell.FormulaR1C1 = "=SUM(" & sClump & ")"   'This col. is now complete again.
    ActiveCell.Offset(0, 1).Select
    Selection.End(xlUp).Select
    Selection.End(xlUp).Select      'Move to top of col (row 5) again.
    sTest = ActiveCell.Value        'Either SOME value or "".
  Wend
  
  Range("A1").Select
  Selection.End(xlDown).Select
 'Test for 2 rows of jobs. Bailout if only one b/c that one is
 'data, not a calc field.
  ActiveCell.Offset(2, 0).Select

  ' More cells than desired have sums; elim the useless ones.
  Range("A1").Select
  Call ZapPctSums(bytOpFi)
  Range("A1").Select
  Call Formator(bytOpFi)

  Exit Sub
  'Return to Sub InsertTitle or Sub Chops.

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "Sumcolumns"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


Sub Killtrash(bytOpFi As Byte)
  ' Delete intermediate downloaded textfiles.
  On Error GoTo FILEERRORHANDLER
  If bytOpFi = 1 Then
    Kill "C:\Open\*op.xls"
  Else
    Kill "C:\Final\*fi.xls"
  End If
  Exit Sub
  'Return to Sub Main.
  
FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "Killtrash"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


'Important -- this macro assumes that OMs are fed to it in alphabetical order.
'This alphabetizing occurs in custfin.sas.  The exception is that the unusual
'OM's such as C208, etc. are hardcoded last in custfin.sas' arrays and fall
'to the bottom of the output textfiles generated by custfin.sas
Sub Chops(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  Dim iCtrRgns As Integer             'Used in loop over regions.
  Dim iToparray3 As Integer        'Highest element of the region array.
  Dim sXlsname3 As String          'New chopped file's name.
  Dim aOpsmgr As Variant           'Used in case statement to determine appropriate array.
  Dim iCtrOMarray As Integer             'Used in nested search for OM.
  Dim iNoOfOMsInArray As Integer   'Used in nested search for OM.
  Dim iBeg As Integer              'Used in OM selection and copy.
  Dim iEndd As Integer             'Used in OM selection and copy.
  Dim sChopTitle As String         'Used as title in first few rows.
  
  iToparray3 = (UBound(aRgns) + 1)    'Determine # of regions.
  iCtrRgns = 0
  
  While (iCtrRgns < iToparray3)          'Outer loop begins.
    'Open each whole region's .xls, one at a time, to chop out OMs.
    On Error GoTo FILEERRORHANDLER

  If bytOpFi = 1 Then
    sXlsname3 = sPath & "OPNJBS_99" & sRptgwk & "_" & aRgns(iCtrRgns) & ".xls"
  Else
    sXlsname3 = sPath & "FINJBS_99" & sRptgwk & "_" & aRgns(iCtrRgns) & ".xls"
  End If

    Workbooks.Open FileName:=sXlsname3

    'Check for empty textfile:
    If Range("A5").Value = "No records found" Then
      Exit Sub
    End If

    Range("A1").Select
    'Find appropriate array of OMs.
    'From "ISS Structure - Updated 5/19/98" printout from K. Stuchman.
    Select Case aRgns(iCtrRgns)
      Case "ALD"
      aOpsmgr = Array("OM25")
      
      Case "AMT"
      aOpsmgr = Array("OM20", "OM21", "OM22", "OM23", "OM24", "OM29", "C202")
      
      '''Case "BAN"
      '''aOpsmgr = Array("OM83", "OM84", "OM85", "OM86", "OM87", "OM88", "OM89", "C208")
      
      '''Case "BAS"
      '''aOpsmgr = Array("OM80", "OM81", "OM90", "C213")

      'BAS and BAN consolidated to BAT 1/1/99.
      Case "BAT"
      aOpsmgr = Array("OM83", "OM84", "OM85", "OM86", "OM87", "OM88", "OM89", "OM80", "OM81", "OM90", "C213", "C208", "C214")

      Case "BST"
      aOpsmgr = Array("OM10", "OM11", "OM13", "OM17", "OM18", "OM94", "C201")
      
      Case "CTNR"
      aOpsmgr = Array("OM04", "C204")
      
      Case "GTE"
      aOpsmgr = Array("OM40", "OM41", "OM42", "OM43", "OM44", "OM45", "OM46", "OM95", "OM96", "OM97", "C211")
      
      Case "IOC"
      aOpsmgr = Array("OM14", "OM33", "OM38", "OM63", "OM70", "OM71", "OM72", "OM73", "OM74", "OM75", "OM76", "FM33", "OM82", "C203", "OM77")

      Case "PAC"
      aOpsmgr = Array("OM60", "OM61", "OM62", "OM66", "OM67", "OM69", "C206")

      Case "SBC"
      aOpsmgr = Array("OM30", "OM31", "OM32", "OM34", "OM35", "OM36", "OM37", "C212")

      Case "SPR"
      aOpsmgr = Array("OM12", "OM15", "OM16", "OM26", "C210")

      Case "USW"
      aOpsmgr = Array("OM19", "OM64", "OM65", "OM91", "C209")

      ''' New for '99.
      '''Case "ISPN"
      '''aOpsmgr = Array("OM93")
      ' New for late '99.
      Case "CLEC"
      aOpsmgr = Array("OM59")
      
      ' Error trap for researching new OMs; usually only contains OM68.
      Case "ZZZ"
        aOpsmgr = Empty
        ActiveWorkbook.Close
        GoTo RGNINDEPS
    End Select
    
      'Use FIND to locate each OM's subset from whole region .xls
      iCtrOMarray = 0
      iNoOfOMsInArray = (UBound(aOpsmgr) + 1)
      
      While (iCtrOMarray < iNoOfOMsInArray)  'Nested loop through array of OMs.
        On Error GoTo FILEERRORHANDLER
        If bytOpFi = 1 Then
          Range("A:A").Select
        Else
          ' In Final, col A is the ISS Rgn.
          Range("B:B").Select
        End If
        On Error Resume Next
        Selection.Find(What:=aOpsmgr(iCtrOMarray), After:=ActiveCell, LookIn:=xlValues, _
                       LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext _
                       , MatchCase:=True).Activate
        ActiveCell.Select   'You've found first instance of OMxx.
        'Snake downward.
        If ActiveCell.Value > "" Then
          iBeg = ActiveCell.Row
          While ActiveCell.Value = ActiveCell.Offset(1, 0).Value
            ActiveCell.Offset(1, 0).Range("A1").Select
          Wend
          iEndd = ActiveCell.Row
          Rows("" & iBeg & ":" & iEndd & "").Select
          Selection.Copy
          
          ' Get focus on a new worksheet.
          Workbooks.Add
          ActiveSheet.Paste
          
         ' With focus still on small OM chop, put header at top, sum columns.
         ' TODO use variable at top of code for 1999...
         sChopTitle = aOpsmgr(iCtrOMarray) & " - Week " & sRptgwk & ", 1999"  'Change yearly.
         Call InsertTitle(bytOpFi, sChopTitle)

         Range("A1").Select
         Call ChopsHeader(bytOpFi)    'Need it here so that Function Numrows has header row.
         Range("A1").Select
         
         '''If Numrows = 0 Then GoTo SKIP2  'Function returns 0 if only ONE row.
         If Numrows = 0 Then   'Function returns 0 if only ONE row.
           Call Formator(bytOpFi)
         Else
           Call Sumcolumns(bytOpFi)  'Multiple rows require summation.
         End If
      
         Range("A1").Select
 
        ' Finished with this OM's chop.
        Application.Calculation = xlAutomatic    'Turn on calc so spdsht is saved that way.
        If bytOpFi = 1 Then
          ActiveWorkbook.SaveAs FileName:=sChopath & "\OPNJBS_99" & sRptgwk & "_" & aRgns(iCtrRgns) & "_" & aOpsmgr(iCtrOMarray) & ".xls", FileFormat:=xlExcel5
        Else
          ActiveWorkbook.SaveAs FileName:=sChopathf & "\FINJBS_99" & sRptgwk & "_" & aRgns(iCtrRgns) & "_" & aOpsmgr(iCtrOMarray) & ".xls", FileFormat:=xlExcel5
        End If
        Application.Calculation = xlManual
        Application.DisplayAlerts = False
        ActiveWorkbook.Close
        Application.DisplayAlerts = True
          
        End If
        
        iCtrOMarray = iCtrOMarray + 1   'Go back to next OM for ALD..., create another spdsht.
      Wend    'End nested loop.
      
       'Close original whole region .xls .
        Application.DisplayAlerts = False
        ActiveWorkbook.Close
        Application.DisplayAlerts = True
              
RGNINDEPS:
    'Drop to here if ZZZ is looping.
    iCtrRgns = iCtrRgns + 1   'Start on next whole region .xls .
    Wend                'End outer loop.
      
    ' Return to Sub Main.
    Exit Sub

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "Chops"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)

End Sub


Sub ChopsHeader(bytOpFi As Byte)
  ' Headers used for OM spreadsheets.
  On Error GoTo FILEERRORHANDLER
  ' Chops have one fewer rows than wholes; must add.
  Rows("3:3").Select
  Selection.Insert shift:=xlDown

  If bytOpFi = 1 Then
    Range("A4").FormulaR1C1 = "Ops Mgr"
    Range("B4").FormulaR1C1 = "Class"
    Range("C4").FormulaR1C1 = "Job"
    Range("D4").FormulaR1C1 = "Location"
    Range("E4").FormulaR1C1 = "State"
    Range("F4").FormulaR1C1 = "Holdco"
    Range("G4").FormulaR1C1 = "Supervisor"
    Range("H4").FormulaR1C1 = "Product Line"
    Range("I4").FormulaR1C1 = "Product Code"
    Range("J4").FormulaR1C1 = "Sched DCI"
    Range("K4").FormulaR1C1 = "H-Date"
    Range("L4").FormulaR1C1 = "Committed K-Date"
    Range("M4").FormulaR1C1 = "Inst Source"
    Range("N4").FormulaR1C1 = "Inst Tgt Hrs"
    Range("O4").FormulaR1C1 = "Inst Act Hrs"
    Range("P4").FormulaR1C1 = "Inst Hrs Remain"
    Range("Q4").FormulaR1C1 = "Inst Tgt Cost"
    Range("R4").FormulaR1C1 = "Inst Act Cost"
    Range("S4").FormulaR1C1 = "Inst B/(W)"
    
    Range("T4").FormulaR1C1 = "Tot Eng Source"
    Range("U4").FormulaR1C1 = "Tot Eng Tgt Hrs"
    Range("V4").FormulaR1C1 = "Tot Eng Act Hrs"
    Range("W4").FormulaR1C1 = "Tot Eng Hrs Remain"
    Range("X4").FormulaR1C1 = "Tot Eng Tgt Cost"
    Range("Y4").FormulaR1C1 = "Tot Eng Act Cost"
    Range("Z4").FormulaR1C1 = "Tot Eng B/(W)"

    Range("AA4").FormulaR1C1 = "EAE Tgt Hrs"
    Range("AB4").FormulaR1C1 = "EAE Act Hrs"
    Range("AC4").FormulaR1C1 = "EAE Hrs Remain"
    Range("AD4").FormulaR1C1 = "EAE Tgt Cost"
    Range("AE4").FormulaR1C1 = "EAE Act Cost"
    Range("AF4").FormulaR1C1 = "EAE B/(W)"

    Range("AG4").FormulaR1C1 = "FE Tgt Hrs"
    Range("AH4").FormulaR1C1 = "FE Act Hrs"
    Range("AI4").FormulaR1C1 = "FE Hrs Remain"
    Range("AJ4").FormulaR1C1 = "FE Tgt Cost"
    Range("AK4").FormulaR1C1 = "FE Act Cost"
    Range("AL4").FormulaR1C1 = "FE B/(W)"

    Range("AM4").FormulaR1C1 = "OTHR Tgt Hrs"
    Range("AN4").FormulaR1C1 = "OTHR Act Hrs"
    Range("AO4").FormulaR1C1 = "OTHR Hrs Remain"
    Range("AP4").FormulaR1C1 = "OTHR Tgt Cost"
    Range("AQ4").FormulaR1C1 = "OTHR Act Cost"
    Range("AR4").FormulaR1C1 = "OTHR B/(W)"

    Range("AS4").FormulaR1C1 = "PAE Tgt Hrs"
    Range("AT4").FormulaR1C1 = "PAE Act Hrs"
    Range("AU4").FormulaR1C1 = "PAE Hrs Remain"
    Range("AV4").FormulaR1C1 = "PAE Tgt Cost"
    Range("AW4").FormulaR1C1 = "PAE Act Cost"
    Range("AX4").FormulaR1C1 = "PAE B/(W)"

    Range("AY4").FormulaR1C1 = "SAE Tgt Hrs"
    Range("AZ4").FormulaR1C1 = "SAE Act Hrs"
    Range("BA4").FormulaR1C1 = "SAE Hrs Remain"
    Range("BB4").FormulaR1C1 = "SAE Tgt Cost"
    Range("BC4").FormulaR1C1 = "SAE Act Cost"
    Range("BD4").FormulaR1C1 = "SAE B/(W)"

    Range("BE4").FormulaR1C1 = "SDE Tgt Hrs"
    Range("BF4").FormulaR1C1 = "SDE Act Hrs"
    Range("BG4").FormulaR1C1 = "SDE Hrs Remain"
    Range("BH4").FormulaR1C1 = "SDE Tgt Cost"
    Range("BI4").FormulaR1C1 = "SDE Act Cost"
    Range("BJ4").FormulaR1C1 = "SDE B/(W)"

    Range("BK4").FormulaR1C1 = "SSE Tgt Hrs"
    Range("BL4").FormulaR1C1 = "SSE Act Hrs"
    Range("BM4").FormulaR1C1 = "SSE Hrs Remain"
    Range("BN4").FormulaR1C1 = "SSE Tgt Cost"
    Range("BO4").FormulaR1C1 = "SSE Act Cost"
    Range("BP4").FormulaR1C1 = "SSE B/(W)"

    Range("BQ4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Tgt Hrs"
    Range("BR4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Act Hrs"
    Range("BS4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Hrs Remain"
    Range("BT4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Tgt Cost"
    Range("BU4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Act Cost"
    Range("BV4").FormulaR1C1 = "Tot Eng w/o EAE&SDE B/(W)"

  Else
    Range("A4").FormulaR1C1 = "ISS Rgn"
    Range("B4").FormulaR1C1 = "Ops Mgr"
    Range("C4").FormulaR1C1 = "Catgy"
    Range("D4").FormulaR1C1 = "Class"
    Range("E4").FormulaR1C1 = "Job"
    Range("F4").FormulaR1C1 = "Location"
    Range("G4").FormulaR1C1 = "State"
    Range("H4").FormulaR1C1 = "Holdco"
    Range("I4").FormulaR1C1 = "Supervisor"
    Range("J4").FormulaR1C1 = "Product Line"
    Range("K4").FormulaR1C1 = "Product Code"
    Range("L4").FormulaR1C1 = "D-Date"
    Range("M4").FormulaR1C1 = "Committed K-Date"
    Range("N4").FormulaR1C1 = "FTS Dt"

    Range("O4").FormulaR1C1 = "Inst Source"
    Range("P4").FormulaR1C1 = "Inst Tgt Hrs"
    Range("Q4").FormulaR1C1 = "Inst Act Hrs"
    Range("R4").FormulaR1C1 = "Inst Hrs Variance"
    Range("S4").FormulaR1C1 = "Inst Tgt Cost"
    Range("T4").FormulaR1C1 = "Inst Act Cost"
    Range("U4").FormulaR1C1 = "Inst $ B/(W)"
    Range("V4").FormulaR1C1 = "Inst Variance"
    Columns("V:V").Select
    '''Selection.Style = "Percent"
    Selection.NumberFormat = "0%"
    
    Range("W4").FormulaR1C1 = "Tot Eng Source"
    Range("X4").FormulaR1C1 = "Tot Eng Tgt Hrs"
    Range("Y4").FormulaR1C1 = "Tot Eng Act Hrs"
    Range("Z4").FormulaR1C1 = "Tot Eng Hrs Variance"
    Range("AA4").FormulaR1C1 = "Tot Eng Tgt Cost"
    Range("AB4").FormulaR1C1 = "Tot Eng Act Cost"
    Range("AC4").FormulaR1C1 = "Tot Eng $ B/(W)"
    Range("AD4").FormulaR1C1 = "Tot Eng Variance"
    Columns("AD:AD").Select
    Selection.NumberFormat = "0%"

    Range("AE4").FormulaR1C1 = "EAE Tgt Hrs"
    Range("AF4").FormulaR1C1 = "EAE Act Hrs"
    Range("AG4").FormulaR1C1 = "EAE Hrs Remain"
    Range("AH4").FormulaR1C1 = "EAE Tgt Cost"
    Range("AI4").FormulaR1C1 = "EAE Act Cost"
    Range("AJ4").FormulaR1C1 = "EAE $ B/(W)"
    Range("AK4").FormulaR1C1 = "EAE Variance"
    Columns("AK:AK").Select
    Selection.NumberFormat = "0%"

    Range("AL4").FormulaR1C1 = "FE Tgt Hrs"
    Range("AM4").FormulaR1C1 = "FE Act Hrs"
    Range("AN4").FormulaR1C1 = "FE Hrs Remain"
    Range("AO4").FormulaR1C1 = "FE Tgt Cost"
    Range("AP4").FormulaR1C1 = "FE Act Cost"
    Range("AQ4").FormulaR1C1 = "FE $ B/(W)"
    Range("AR4").FormulaR1C1 = "FE Variance"
    Columns("AR:AR").Select
    Selection.NumberFormat = "0%"

    Range("AS4").FormulaR1C1 = "OTHR Tgt Hrs"
    Range("AT4").FormulaR1C1 = "OTHR Act Hrs"
    Range("AU4").FormulaR1C1 = "OTHR Hrs Remain"
    Range("AV4").FormulaR1C1 = "OTHR Tgt Cost"
    Range("AW4").FormulaR1C1 = "OTHR Act Cost"
    Range("AX4").FormulaR1C1 = "OTHR $ B/(W)"
    Range("AY4").FormulaR1C1 = "OTHR Variance"
    Columns("AY:AY").Select
    Selection.NumberFormat = "0%"

    Range("AZ4").FormulaR1C1 = "PAE Tgt Hrs"
    Range("BA4").FormulaR1C1 = "PAE Act Hrs"
    Range("BB4").FormulaR1C1 = "PAE Hrs Remain"
    Range("BC4").FormulaR1C1 = "PAE Tgt Cost"
    Range("BD4").FormulaR1C1 = "PAE Act Cost"
    Range("BE4").FormulaR1C1 = "PAE $ B/(W)"
    Range("BF4").FormulaR1C1 = "PAE Variance"
    Columns("BF:BF").Select
    Selection.NumberFormat = "0%"

    Range("BG4").FormulaR1C1 = "SAE Tgt Hrs"
    Range("BH4").FormulaR1C1 = "SAE Act Hrs"
    Range("BI4").FormulaR1C1 = "SAE Hrs Remain"
    Range("BJ4").FormulaR1C1 = "SAE Tgt Cost"
    Range("BK4").FormulaR1C1 = "SAE Act Cost"
    Range("BL4").FormulaR1C1 = "SAE $ B/(W)"
    Range("BM4").FormulaR1C1 = "SAE Variance"
    Columns("BM:BM").Select
    Selection.NumberFormat = "0%"

    Range("BN4").FormulaR1C1 = "SDE Tgt Hrs"
    Range("BO4").FormulaR1C1 = "SDE Act Hrs"
    Range("BP4").FormulaR1C1 = "SDE Hrs Remain"
    Range("BQ4").FormulaR1C1 = "SDE Tgt Cost"
    Range("BR4").FormulaR1C1 = "SDE Act Cost"
    Range("BS4").FormulaR1C1 = "SDE $ B/(W)"
    Range("BT4").FormulaR1C1 = "SDE Variance"
    Columns("BT:BT").Select
    Selection.NumberFormat = "0%"

    Range("BU4").FormulaR1C1 = "SSE Tgt Hrs"
    Range("BV4").FormulaR1C1 = "SSE Act Hrs"
    Range("BW4").FormulaR1C1 = "SSE Hrs Remain"
    Range("BX4").FormulaR1C1 = "SSE Tgt Cost"
    Range("BY4").FormulaR1C1 = "SSE Act Cost"
    Range("BZ4").FormulaR1C1 = "SSE $ B/(W)"
    Range("CA4").FormulaR1C1 = "SSE Variance"
    Columns("CA:CA").Select
    Selection.NumberFormat = "0%"

    Range("CB4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Tgt Hrs"
    Range("CC4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Act Hrs"
    Range("CD4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Hrs Remain"
    Range("CE4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Tgt Cost"
    Range("CF4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Act Cost"
    Range("CG4").FormulaR1C1 = "Tot Eng w/o EAE&SDE $ B/(W)"
    Range("CH4").FormulaR1C1 = "Tot Eng w/o EAE&SDE Variance"
  End If

  Exit Sub
  'Return to Chops.

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "Commonheader"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


Function Numrows() As Integer
  'See c:/code/vb for improved algorithm.
  On Error GoTo FILEERRORHANDLER
  Dim iFlag As Integer            '1=multiple rows; 0=single row.
  
  Range("A1").Select              'Make sure you know the starting point.
  iFlag = 1                       'Assume more than 1 row exist.
  Selection.End(xlDown).Select    'On header row.
  ActiveCell.Offset(2, 0).Select  'Will have data in offset (1,0) -- question is whether
                                  'have a line below it.
  
  If ActiveCell.Value = "" Then iFlag = 0   'Only one row exists; no sum required.
  If iFlag = 0 Then Numrows = 0             'Return Numrows to Sub.
  If iFlag = 1 Then Numrows = 1             '"Normal" multiline spdsht.
  Range("A1").Select
  
  Exit Function

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "Numrows"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Function
  

Sub ZapPctSums(bytOpFi As Byte)
  On Error GoTo FILEERRORHANDLER
  'Remove meaningless percent sum cells for each section.
  Dim i As Integer

  Range("A1").Select
  Selection.End(xlDown).Select
  Selection.End(xlDown).Select
  ActiveCell.Offset(1, 0).Select  'Now at one row past last data row.
  Selection.End(xlToRight).Select 'Should be at Inst Tgt Hrs cell.

  If bytOpFi = 1 Then
    'S/b on Inst Variance cell after this select.
    ActiveCell.Offset(0, 5).Select  'Inst has more cols than EAE, FE...
  Else
    ActiveCell.Offset(0, 6).Select  'Inst has more cols than EAE, FE...
  End If
  ' Check for potential DIV/O.
  ' Don't want Tgt (i.e. -2) or Act (i.e. -1) to be a zero for Open.
  ' Don't want Tgt (i.e. -3) or BW (i.e. -1) to be a zero for Final.
  If (bytOpFi = 1 And ((ActiveCell.Offset(0, -1).Value = 0 Or ActiveCell.Offset(0, -2).Value = 0))) _
     Or ((bytOpFi <> 1) And ((ActiveCell.Offset(0, -3) = 0))) Then
    Selection.ClearContents
    '''Else: Selection.FormulaR1C1 = "=(+RC[-1]/RC[-2])"  'Since can't sum col, use totals.
    Else
    Call ElimSums(bytOpFi)
  End If
  ' Wipe meaningless sum of Source cell.
  ActiveCell.Offset(0, 1).Select
  Selection.ClearContents                      'Want to del sum of Eng Source.

  If bytOpFi = 1 Then
    ActiveCell.Offset(0, 6).Select     'Eng has more cols than EAE, FE...
  Else
    ActiveCell.Offset(0, 7).Select     'Eng has more cols than EAE, FE...
  End If

  If (bytOpFi = 1 And ((ActiveCell.Offset(0, -1).Value = 0 Or ActiveCell.Offset(0, -2).Value = 0))) _
     Or ((bytOpFi <> 1) And ((ActiveCell.Offset(0, -3) = 0))) Then
    Selection.ClearContents
    '''Else: Selection.FormulaR1C1 = "=(+RC[-1]/RC[-2])"  'Since can't sum col, use totals.
    Else
    Call ElimSums(bytOpFi)
  End If
  'Finished with Tot Inst & Tot Eng.
  
  ' 7 tests for EAE, PAE... % col.
  For i = 0 To 7
    If bytOpFi = 1 Then
      ActiveCell.Offset(0, 6).Select
    Else
      ActiveCell.Offset(0, 7).Select
    End If
    If (bytOpFi = 1 And ((ActiveCell.Offset(0, -1).Value = 0 Or ActiveCell.Offset(0, -2).Value = 0))) _
        Or ((bytOpFi <> 1) And ((ActiveCell.Offset(0, -3) = 0))) Then
      Selection.ClearContents
    Else
      Call ElimSums(bytOpFi)
    End If
  Next i
  
  Exit Sub
  'Return to Sub Sumcolumns.

FILEERRORHANDLER:
  Dim sFailure As String
  sFailure = "ZapPctSums"
  Application.ScreenUpdating = True
  Application.Calculation = xlAutomatic
  Call dhError(sFailure, True)
End Sub


Sub ElimSums(bytOpFi As Byte)
  ' Total the % oriented columns.
  Dim sngTgt As Single        'Target cell.
  Dim sngAct As Single        'Actual cell.
  Dim sngBW As Single
  Dim sngPctCompl As Single   'Result of (Tgt-Act)/Tgt.

  If bytOpFi = 1 Then
    sngAct = ActiveCell.Offset(0, -1).Value
    sngTgt = ActiveCell.Offset(0, -2).Value
    sngPctCompl = (sngTgt - sngAct) / sngTgt
  Else
    sngTgt = ActiveCell.Offset(0, -3).Value
    sngBW = ActiveCell.Offset(0, -1).Value
    sngPctCompl = sngBW / sngTgt
  End If
  Selection.FormulaR1C1 = sngPctCompl
End Sub


Sub Downloadtxt(bytOpFi As Byte)
  'Uses a predefined .BAT file to retrieve *.xls prior to starting the
  'processing part of this macro.
  Dim bResponse As Byte
  Dim bMsgboxstyle As Byte
  Dim vRetVal As Variant

  '''MsgBox "Click to begin textfile download from DART" & (Chr(13) & Chr(10)) & "Please wait for file download to complete before clicking Yes at the next prompt.", vbInformation
  If bytOpFi = 1 Then
    Application.StatusBar = "Now downloading Open Jobs texfiles..."
    ChDir ("c:\shared\chops\")
    vRetVal = Shell("c:\shared\chops\op_dl1.bat", 1)
  Else
    Application.StatusBar = "Now downloading Final Jobs texfiles..."
    ChDir ("c:\shared\chops\")
    vRetVal = Shell("c:\shared\chops\fi_dl1.bat", 1)
  End If
  bMsgboxstyle = vbQuestion + vbYesNo
  bResponse = MsgBox("Has download completed?", bMsgboxstyle)
  'Error free run completed.
  If bResponse = vbYes And vRetVal <> 0 Then
    Application.StatusBar = False
    Exit Sub
  Else
    'Do nothing and hope they don't ok this one prematurely as well.  TODO use better
    'programming logic here.
    MsgBox "Please wait until files have completed downloading, then click this OK button."
  End If
  Application.StatusBar = False
End Sub


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
    
    ' If there is an error, process it otherwise just return True.
    If objErr.Number = 0 Then
      dhError = True
    Else
      ' Build title and message.
      strTitle = "Error " & objErr.Number & _
       " in " & strProc
      strMessage = "The following error has occurred:" & _
       vbCrLf & vbCrLf & objErr.Description
        
      ' Set the icon and buttons for MsgBox.
      intStyle = vbExclamation
      If fRespond Then
        intStyle = intStyle Or vbOKCancel
      End If
        
      ' Display message and return result.
      dhError = (MsgBox(strMessage, intStyle, strTitle) = vbOK)
    End If
End Function

