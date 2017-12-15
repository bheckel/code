Sub fooz
  Dim foo

  foo = Middle50()
End Sub

Function Middle50()
  Dim agi As Variant
  Dim irs_increment As Variant
  Dim taxrate As Variant
  Dim modded As Variant
  Dim tmpnum As Variant
  Dim i As Variant
  Dim upto50 As Variant
  Dim downto0 As Variant
  Dim avgagi As Variant
  Dim firstlvl As Variant

  agi = Worksheets(1).Range("a1")
  irs_increment = 50
  taxrate = 0.15
  modded = 1
  tmpnum = agi

  i = 0
' Determine how high to go until hit first increment of 50 (i.e. the top of
' the range).
  Do While modded <> 0
    i = i + 1
    tmpnum = tmpnum + 1
    modded = tmpnum Mod 50
  Loop

  upto50 = agi + i
  downto0 = upto50 - irs_increment
  avgagi = (upto50 + downto0) / 2

  If agi < 43851 Then
    taxdue = avgagi * taxrate
  ' TODO make more robust.
  ElseIf  agi >= 43850 Then
    taxdue = ((avgagi - 43850) * 0.28) + 6577.50
  End If

  Debug.Print taxdue

  Middle50 = taxdue
  
End Function

  '''firstlvl = Worksheets(1).Range("b1")
