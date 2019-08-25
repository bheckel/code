'''Option Explicit

'VB_Name
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Program Name: claire_cits.bas
'
'      Summary: Reformat & Pivot Don Ames' spdsht.
'               TODO add errortrap
'
'      Created: Wed, 01 Sep 1999 09:46:42 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub Reformat()

  ' 1. Don Ames passes spdsht with frozen panes.
  ActiveWindow.FreezePanes = False
  With ActiveWindow
      .SplitColumn = 0
      .SplitRow = 0
  End With

  ' 2. Sort on col header "Site" then "Delivery Method"
  ' TODO avoid hardcoding p1.  Findcol is not doing anything until can avoid hardcode.
  If Findcol("Site") Then
    Worksheets(1).Range("p1").Sort _
    Key1:=Worksheets(1).Columns("p"), _
    Header:=xlGuess
  End If
     
'''  If Findcol("Delivery Method") Then
'''    Worksheets(1).Range("n1").Sort _
'''    Key1:=Worksheets(1).Columns("n"), _
'''    Header:=xlGuess
'''  End If
     
  ' 3. If "self" is value, select range col A to AU, then sort col B, C, L.
  Cells.Find(What:="self", After:="P1").Activate
  iPegRowTopLeft = ActiveCell.Row
  iPegRowBotLeft = Cells.SpecialCells(xlCellTypeLastCell).Row
  iPegColFarRt = Cells.SpecialCells(xlCellTypeLastCell).Column
  
  ' Assumes want current row to bottom and farright.
  ' Assumes "Self-Paced" runs to bottom of spdsht.
  '''Range(Cells(iPegRowTopLeft, 1), Cells(iPegRowBotLeft, iPegColFarRt)).Select

  
  ' Now that "Self-Paced" range is highlighted, do multi col sorts.
'''  mysorter1 = iPegRowTopLeft
'''  myfullsorter1 = "B" & mysorter
'''  myfullsorter2 = "C" & mysorter
'''  Selection.Sort Key1:=Range(myfullsorter), Order1:=xlAscending, Key2:=Range( _
'''      "C2059"), Order2:=xlAscending, Key3:=Range(myfullsorter2), Order3:=xlAscending _
'''      , Header:=xlGuess, OrderCustom:=1, MatchCase:=False, Orientation:= _
'''      xlTopToBottom

' Now that "Self-Paced" range is highlighted, do multi col sorts on only that highlighted range.
' Sort on "USvsCnd" then "Product Type"
'''  Worksheets(1).Range("p1").Sort _
'''    Key1:=Worksheets(1).Columns("b"), _
'''    Key2:=Worksheets(1).Columns("l"), _
'''    Header:=xlGuess

  '''Dim rng As Range
  '''Set rng = Range(Cells(iPegRowTopLeft, 1), Cells(iPegRowBotLeft, iPegColFarRt))
  '''Set rng = Application.ActiveCell.Column
   colm = Application.ActiveCell.Row
   colm2 = "P" & colm
  
  '''Worksheets(1).Range("A2059:IV3567").Sort _

  '''Worksheets(1).Range("p2060").Sort _

  ' TODO this isnt sorting correctly.  use small subset...
  Worksheets(1).Range(colm2).Sort _
    Key1:=Worksheets(1).Columns("b"), _
    Key2:=Worksheets(1).Columns("l"), _
    Header:=xlGuess



  ' 4. If col L & M = "pcn", select range col A to AU, then sort AB for
  ' "contracts", then if B = "cdn", change value from "cdn" to "us"

  ' TODO

  
  ' 5. Move col header "Course Cost" & "Total Billed" after "MM-YYYY Billed"
  ' TODO use value of col header to determine what to move, don't use absolute
  ' column header letters.  Remove $ signs.
  Columns("Z:AA").Select
  Selection.NumberFormat = "#,##0.00_);(#,##0.00)"
  Selection.Cut
  Range("B1").Select
  Selection.Insert Shift:=xlToRight



  ' 7. Move col header "LOB" out of way to far right.
  Columns("L:L").Select
  Selection.Cut
  '''Range("AI2").Select
  ' Move to a1 then ctrl leftarrow to find far rightmost col.
  Selection.End(xlToRight).Select
  Selection.Insert Shift:=xlToRight

  ' 8. Move col header "Recovery Type" after "Product Type".
  Columns("AC:AC").Select
  Selection.Cut
  Range("M1").Select
  Selection.Insert Shift:=xlToRight

  ' 9. Move col header "Payment Reference" after "Recovery Type".
  Columns("AC:AC").Select
  Selection.Cut
  Range("N1").Select
  Selection.Insert Shift:=xlToRight
  ActiveWindow.LargeScroll ToRight:=-1

  ' 10. Beautify.
  Cells.Select
  Selection.Columns.AutoFit

  ' 11. Pivot.
  ActiveSheet.PivotTableWizard SourceType:=xlDatabase, SourceData:= _
      "'Billed records8-99'!C1:C47", TableDestination:="", TableName:= _
      "PivotTable1"
  ActiveSheet.PivotTables("PivotTable1").AddFields RowFields:=Array( _
      "MM-YYYY Billed", "US vs Cdn", "Product Type", "Recovery Type"), ColumnFields:= _
      "LOB with ISPN"
  With ActiveSheet.PivotTables("PivotTable1").PivotFields("Course Cost")
      .Orientation = xlDataField
      .Name = "Sum of Course Cost"
      .Function = xlSum
  End With

  ' 12. Format 1,000
  Cells.Select
  Selection.NumberFormat = "#,##0.00_);(#,##0.00)"
  ActiveSheet.PivotTables("PivotTable1").PivotSelect "'Row Grand Total'", _
      xlDataAndLabel
  Columns("E:I").Select
  Selection.NumberFormat = "#,##0.00_);(#,##0.00)"
  ActiveSheet.PivotTables("PivotTable1").PivotSelect "", xlDataAndLabel
End Sub

' Accept a col header to locate & highlight relevant col.
Function Findcol(findwhat As Variant) As Boolean
  Dim c, bob

  ' Look in header row only.
  For Each c In [A1:IV1]
    ' Case-sensitive.
    If c.Value Like findwhat Then
      bob = c.Column
      Columns(bob).Select
    End If
  Next
  
  '''iCurrRow = ActiveCell.Row
  '''iCurrCol = ActiveCell.Column
  '''iCurrFull = iCurrRow & ":" & iCurrCol
  '''Findcol = iCurrFull
  Findcol = True
End Function


