''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: while.bas
'
'  Summary: Demo of looping a subroutine based on its truth.
'
'  Created: Mon 18 Nov 2002 11:55:26 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit


Sub Main()
  Dim n As Integer

  n = 3
  While TorF(n)
    Debug.Print n
    n = n - 1
  Wend
End Sub

Function TorF(n As Integer) As Boolean
  If n > 1 Then
    TorF = True
  Else
    TorF = False
  End If
End Function
