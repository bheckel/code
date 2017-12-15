
' Copy this text to /code/vb/personal.bas so that PERSONAL.XLS
' Can be recreated if necessary.
' Modified: Fri, 25 Feb 2000 11:02:33 (Bob Heckel)

Sub tile_horizontal()
  Windows.Arrange ArrangeStyle:=xlHorizontal
End Sub

Sub pgsetup()
  With ActiveSheet.PageSetup
    .LeftHeader = ""
    .CenterHeader = "&A"
    .RightHeader = ""
    .LeftFooter = "&D"
    .CenterFooter = "&P of &N"
    .RightFooter = "&F"
    .LeftMargin = Application.InchesToPoints(0.75)
    .RightMargin = Application.InchesToPoints(0.75)
    .TopMargin = Application.InchesToPoints(0.4)
    .BottomMargin = Application.InchesToPoints(0.53)
    .HeaderMargin = Application.InchesToPoints(0.23)
    .FooterMargin = Application.InchesToPoints(0.28)
    .PrintHeadings = False
    .PrintGridlines = True
    .PrintComments = xlPrintNoComments
    .PrintQuality = 600
    .CenterHorizontally = True
    .CenterVertically = False
    .Orientation = xlPortrait
    .Draft = False
    .PaperSize = xlPaperLetter
    .FirstPageNumber = xlAutomatic
    .Order = xlDownThenOver
    .BlackAndWhite = False
    .Zoom = False
    .FitToPagesWide = 1
    .FitToPagesTall = False
  End With
End Sub

Sub datestamp()
  Selection.EntireRow.Insert
  ActiveCell.FormulaR1C1 = "=TODAY()"
  '''Range("A1").Select
  '''Selection.Font.Bold = True
  ' Prevent date from changing to current date each time opened.
  Selection.Copy
  Selection.PasteSpecial Paste:=xlValues, Operation:=xlNone, SkipBlanks:= _
                         False, Transpose:=False
  Columns("A:A").ColumnWidth = 12
  Rows("1:2").Font.Bold = True
End Sub

Sub auto_fmt()
  Selection.AutoFormat Format:=xlRangeAutoFormatSimple, Number:=True, Font _
                       :=True, Alignment:=True, Border:=True, Pattern:=True, Width:=True
        
End Sub

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'    Name: deleterow.bas
' Summary: Based on specific string passed, will delete entire row.
' Created: Fri, 27 Aug 1999 14:31:20 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub deleterow()
  Dim c
  Dim myinput, mytop, mybot, myref As String
  
  Range("a1").Select

  MsgBox ("This macro will delete each row where the value is found in current worksheet.")
  mytop = InputBox("Enter top leftmost Column & Row. E.g. A1") & ":"
  mybot = InputBox("Enter bottom rightmost Column & Row. E.g. ZZ100")
  myref = mytop & mybot
  myinput = InputBox("Enter value.  It is case-sensitive.") & "*"
GETMORE:
  ''' Doesn't work for non-contiguous ranges like Edward's spreadsheet.
  '''For Each c In ActiveCell.CurrentRegion.Cells
  For Each c In ActiveSheet.Cells.Range(myref)
    If c.Value Like myinput Then
      c.EntireRow.Delete
      ' To prevent skipping another match that immediately follows a deletion,
      ' move to cell A1 and redo all remaining cells.
      GoTo GETMORE
    End If
  Next
  Range("a1").Select
End Sub

Sub zoom_to_windowsize()
  ActiveWindow.Zoom = True
End Sub

