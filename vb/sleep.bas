' S/b symlinked as wait.bas

' Used with user status message resets.
Function Sleep(seconds As Integer) As Boolean
  Dim start  As Single
  Dim finish As Single

  start = Timer
  finish = start + seconds
  Do Until Timer > finish
    DoEvents
  Loop 
  Sleep = True
End Function
