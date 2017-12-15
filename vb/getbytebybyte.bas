'This counts number of bytes (characters) in a previously Opened file.
'Discovered that it is much faster to use j = LOF(1) for filehandle #1

Function Ctr(strFreeFileno As String) As Long
  Dim j As Long
  Dim x As String
  
  j = 0
  'Get char by char.
  x = String(1, " ")
  Do While Not EOF(strFreeFileno)
    Get #strFreeFileno, , x
    j = j + 1
    '''Debug.Print j
    '''Debug.Print x
  Loop
  'Extra count must be elim.
  Ctr = j - 1
End Function
