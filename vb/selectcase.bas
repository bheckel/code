''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: selectcase.bas (s/b symlinked as switch.bas)
'
'  Summary: Switch statment.
'
'  Created: Tue 18 May 2004 12:35:26 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit


Dim Number
Number = 8

Select Case Number
  ' Number between 1 and 5, inclusive.
  Case 1 To 5
    Debug.Print "Between 1 and 5"
  ' The following is the only Case clause that evaluates to True.
  Case 6, 7, 8
    Debug.Print "Between 6 and 8"
  Case 9 To 10
    Debug.Print "Greater than 8"
  Case Else
    Debug.Print "Not between 1 and 10"
End Select
