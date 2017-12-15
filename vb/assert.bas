Sub Assert(condition As Boolean, Optional _
           message As String = "Assertion Failed")
  ' If condition is False, display error message and halt.
  If Not condition Then
    Msgbox message, vbCritical
    Stop
  End If
End Sub
