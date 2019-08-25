
Private Sub Worksheet_Calculate()
  'Round Taxable Inc to a multiple of 50 so that can use
  'value as lookup on Tax Table tab.
  x = Range("b39").Value
  y = x Mod 50
  '''MsgBox x
  While y <> 0
    x = x + 1
    y = x Mod 50
  Wend
  '''MsgBox y
  '''MsgBox x
  Range("b40").Value = x
End Sub
