
Sub Button1_Click()
  'Round Taxable Inc to whole dollars
  x = Sheet1.Range("b39").Value
  'Round rounded Taxable Inc to a multiple of 50 so that can use
  'value as lookup on Tax Table tab.
  ' 1 rounds to tenths (e.g. 1111.2), -2 rounds to hundreds (e.g. 1100),
  ' -3 rounds to thousands (e.g. 1000), etc.
  y = rounder(x, -2)
  Range("b40").Value = y
  
  
  'Find appropriate tax due based on the Taxable Inc.
  '''Set myrange = Worksheets("TaxTable").Range("a1:b500")
  For Each thing In Sheet6.Range("b1:b1604")
    If thing.Value = y Then
      If thing.Offset(0, 1).Value <> "" Then
        unroundedtaxdue = thing.Offset(0, 1).Value
      Else
        unroundedtaxdue = thing.Offset(1, 1).Value
      End If
    End If
  Next thing

  taxdue = rounder(unroundedtaxdue, 0)
  Sheet1.Range("b42").Value = taxdue
End Sub

Function rounder(vRoundme As Variant, iDecimals As Integer)
  ' Adapted from VBA Developers Handbook Getz Gilbert.
  Dim dblFactor As Double
  Dim dblTemp As Double
  
  dblFactor = 10 ^ iDecimals
  dblTemp = vRoundme * dblFactor + 0.5
  rounder = Int(dblTemp) / dblFactor
End Function

