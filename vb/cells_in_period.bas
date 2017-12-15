Option Explicit

Sub Test()
  Dim wantb As Date
  Dim wante As Date
  Dim srow As Integer
  Dim erow As Integer

  CellsInPd 3, wantb, wante, srow, erow
  Debug.Print wantb & "|" & wante & "|" & srow & "|" & erow
End Sub


' Return (via references) the date to start and the date to end the range
' based on the period (1,3,6,12) and the row number of the first and last rows
' in that range.
Sub CellsInPd(month_pd As Integer, _
              wanted_beg As Date, wanted_end As Date, _
              startrow As Variant, endrow As Variant)
  Dim c as Range
  '''Dim the_botrow as Integer   ' last cell in col B
  '''Dim activerng as Variant    ' holds concatenated range

  ' E.g. on 9/2/2002 with month_pd being 3:
  ' ?CDate(DateSerial(Year(Now), Month(Now) - 3, 1))
  ' 6/1/2002
  wanted_beg = CDate(DateSerial(Year(Now), Month(Now) - month_pd, 1))
  ' ?CDate(DateSerial(Year(Now), Month(Now), 0))
  ' 8/31/2002
  wanted_end = CDate(DateSerial(Year(Now), Month(Now), 0))

  '''the_botrow = Cells.SpecialCells(xlCellTypeLastCell).Row
  ' The first row number containing the desired starting date.
  ' TODO de-hardcode
  For Each c In [b1:b9999]
  ' TODO doesn't work
  '''activerng = "[b1:b" & the_botrow & "]"
  '''For Each c In activerng
    ' Skip header row and unanticipated garbage in the Date column.
    If IsDate(c.Value) Then
      If c.Value >= wanted_beg Then
        startrow = c.Row
        ' Only want the first one.
        Exit For
      End If
    End If
  Next
  
  ' The last row number with the desired ending date.
  If month_pd = 1 Then
    ' 1 mo budget always goes to the most recent line entered in checkbook.
    '''endrow = Sheets("Centura").Cells.SpecialCells(xlCellTypeLastCell).Row
  Else
    For Each c In [b1:b9999]
      ' Skip header row and unanticipated garbage in the Date column.
      If IsDate(c.Value) Then
        If c.Value = wanted_end Then
          endrow = c.Row
        End If
      End If
    Next
  End If
End Sub
